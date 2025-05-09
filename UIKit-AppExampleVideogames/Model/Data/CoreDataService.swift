//
//  CoreDataService.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 5/5/25.
//
//

import CoreData
import Foundation
import UIKit

enum CoreDataServiceError: Error {
    case contextUnavailable
    case saveFailed(Error)
    case fetchFailed(Error)
}

class CoreDataService {

    // MARK: - Nested Structs for JSON Decoding
    private struct DeveloperJSON: Codable {
        let name: String
        let website: String
        let logo: String // This is the developer logo asset name, e.g., "mojang"
    }

    private struct VideogameJSON: Codable {
        let title: String
        let logo: String // This is the game logo asset name AND game folder name, e.g., "minecraft"
        let releaseYear: String
        let description: String
        let developer: DeveloperJSON
        let platforms: [String]
        let screenshotIdentifiers: [String]? // NEW: For ["1", "2", "3"]
    }

    // MARK: - Core Data Stack
    private static var persistentContainer: NSPersistentContainer = {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("Could not get SceneDelegate to access persistent container.")
        }
        return sceneDelegate.persistentContainer
    }()

    public var mainContext: NSManagedObjectContext {
        return CoreDataService.persistentContainer.viewContext
    }

    init() {}

    public func saveChanges(completion: @escaping (Result<Void, CoreDataServiceError>) -> Void) {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
                print("CoreDataService: saveChanges successful.")
                completion(.success(()))
            } catch {
                print("CoreDataService: Failed to save context - \(error.localizedDescription)")
                context.rollback()
                completion(.failure(.saveFailed(error)))
            }
        } else {
            print("CoreDataService: saveChanges - no changes to save.")
            completion(.success(()))
        }
    }
    
    // This fetch method is an example, repositories usually do their own fetches.
    public func fetchAllVideogameMOs(completion: @escaping (Result<[Videogame], CoreDataServiceError>) -> Void) {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let videogames = try mainContext.fetch(fetchRequest)
            completion(.success(videogames))
        } catch {
            print("CoreDataService: Error fetching videogames - \(error.localizedDescription)")
            completion(.failure(.fetchFailed(error)))
        }
    }

    static let firebaseDatabaseURL =
        "https://first-project-videogames-default-rtdb.europe-west1.firebasedatabase.app/.json"

    static func fetchDataAndStoreInCoreData() {
        print("CoreDataService: fetchDataAndStoreInCoreData - Starting Firebase fetch.")
        guard let url = URL(string: firebaseDatabaseURL) else {
            print("CoreDataService: Invalid URL for Firebase")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("CoreDataService: Error fetching from Firebase: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                print("CoreDataService: HTTP status code is \((response as? HTTPURLResponse)?.statusCode ?? 0) from Firebase")
                return
            }
            guard let data = data else {
                print("CoreDataService: No data received from Firebase")
                return
            }
            print("CoreDataService: Received data from Firebase. Attempting to decode...")

            do {
                let videogamesJSON = try JSONDecoder().decode([VideogameJSON].self, from: data)
                print("CoreDataService: Successfully decoded \(videogamesJSON.count) items from Firebase.")
                
                let backgroundContext = CoreDataService.persistentContainer.newBackgroundContext()
                backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                backgroundContext.performAndWait {
                    print("CoreDataService: Starting Core Data import on background context.")
                    deleteAllVideogamesInContext(backgroundContext)
                    deleteAllDevelopersInContext(backgroundContext)

                    var importedCount = 0
                    for videogameItemJSON in videogamesJSON {
                        var developerMO: Developer?
                        let devFetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
                        devFetchRequest.predicate = NSPredicate(format: "name == %@", videogameItemJSON.developer.name)
                        
                        if let existingDeveloper = try? backgroundContext.fetch(devFetchRequest).first {
                            updateDeveloperMO(existingDeveloper, from: videogameItemJSON.developer, context: backgroundContext)
                            developerMO = existingDeveloper
                        } else {
                            developerMO = createNewDeveloperMO(from: videogameItemJSON.developer, context: backgroundContext)
                        }

                        guard let currentDeveloperMO = developerMO else {
                            print("CoreDataService: Could not save/find developer \(videogameItemJSON.developer.name). Skipping videogame \(videogameItemJSON.title).")
                            continue
                        }
                        
                        guard let releaseDate = getDate(from: videogameItemJSON.releaseYear) else {
                            print("CoreDataService: Could not convert releaseYear for \(videogameItemJSON.title). Skipping.")
                            continue
                        }
                        createNewVideogameMO(from: videogameItemJSON, developer: currentDeveloperMO, releaseDate: releaseDate, context: backgroundContext)
                        importedCount += 1
                    }
                    print("CoreDataService: Processed \(importedCount) videogames for import.")

                    if backgroundContext.hasChanges {
                        do {
                            try backgroundContext.save()
                            print("CoreDataService: Firebase data successfully imported and saved to background context.")
                            DispatchQueue.main.async {
                                print("CoreDataService: Posting .dataUpdated notification.")
                                NotificationCenter.default.post(name: .dataUpdated, object: nil)
                            }
                        } catch {
                            print("CoreDataService: Error saving imported Firebase data: \(error.localizedDescription)")
                            backgroundContext.rollback()
                        }
                    } else {
                        print("CoreDataService: No changes to save in background context after Firebase import.")
                    }
                }
            } catch {
                print("CoreDataService: Error decoding JSON from Firebase: \(error.localizedDescription)")
                debugPrint("Raw Firebase data (first 500 bytes): \(String(data: data.prefix(500), encoding: .utf8) ?? "Could not decode as UTF-8")")
            }
        }
        task.resume()
    }
    
    private static func createNewDeveloperMO(from developerJSON: DeveloperJSON, context: NSManagedObjectContext) -> Developer {
        let newDeveloper = Developer(context: context)
        newDeveloper.uuid = UUID()
        newDeveloper.name = developerJSON.name
        newDeveloper.website = developerJSON.website
        newDeveloper.logo = developerJSON.logo // Stores "mojang", "riot", etc.
        return newDeveloper
    }

    private static func updateDeveloperMO(_ developerMO: Developer, from developerJSON: DeveloperJSON, context: NSManagedObjectContext) {
        developerMO.name = developerJSON.name
        developerMO.website = developerJSON.website
        developerMO.logo = developerJSON.logo
        if developerMO.uuid == nil {
            developerMO.uuid = UUID()
        }
    }
    
    private static func createNewVideogameMO(from videogameJSON: VideogameJSON, developer: Developer, releaseDate: Date, context: NSManagedObjectContext) {
        let newVideogame = Videogame(context: context)
        newVideogame.uuid = UUID()
        newVideogame.title = videogameJSON.title
        // 'logo' from JSON is the game's main image identifier (e.g., "minecraft")
        // This will be used by VideogameEntity.imageName
        newVideogame.logo = videogameJSON.logo
        newVideogame.releaseYear = releaseDate
        newVideogame.gameDescription = videogameJSON.description
        newVideogame.developer = developer
        newVideogame.platforms = videogameJSON.platforms
        newVideogame.isFavorite = false

        // Handle screenshots
        // The Videogame Core Data entity needs a 'screenshots' attribute (e.g., Transformable [String])
        if let screenshotIdentifiers = videogameJSON.screenshotIdentifiers, !screenshotIdentifiers.isEmpty {
            // Store them as "gameLogo/identifier", e.g., "minecraft/1", "minecraft/2"
            // This makes it easier for the ViewModel to directly use them as asset names.
            newVideogame.screenshots = screenshotIdentifiers.map { "images/\(videogameJSON.logo)/\($0)" }
        } else {
            newVideogame.screenshots = nil
        }
    }

    static func getDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: dateString)
    }

    static private func deleteAllVideogamesInContext(_ context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Videogame.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [CoreDataService.persistentContainer.viewContext])
            }
            print("CoreDataService: Deleted all videogames in provided context.")
        } catch {
            print("CoreDataService: Error deleting all Videogames in context: \(error.localizedDescription)")
        }
    }

    static private func deleteAllDevelopersInContext(_ context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Developer.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [CoreDataService.persistentContainer.viewContext])
            }
            print("CoreDataService: Deleted all developers in provided context.")
        } catch {
            print("CoreDataService: Error deleting all Developers in context: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let dataUpdated = Notification.Name("CoreDataUpdated")
}
