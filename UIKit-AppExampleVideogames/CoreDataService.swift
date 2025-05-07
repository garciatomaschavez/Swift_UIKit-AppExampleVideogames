import Foundation
import CoreData
import UIKit

class CoreDataService {
    
    // 1. Get the context
    private static var context: NSManagedObjectContext {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.persistentContainer.viewContext
        } else {
            // Handle the error: Unable to get context
            fatalError("Could not get context from SceneDelegate")
        }
    }
    
    // 2. Firebase URL
    static let firebaseDatabaseURL = "https://first-project-videogames-default-rtdb.europe-west1.firebasedatabase.app/.json"
    
    // MARK: - Fetch Data from Firebase and Store in Core Data
    
    static func fetchDataAndStoreInCoreData() {
        // 3. Construct the URL object.
        guard let url = URL(string: firebaseDatabaseURL) else {
            print("Error: Invalid URL")
            return
        }
        
        // 4. Create a URLSession data task.
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // 5. Handle errors.
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check the HTTP response status code.
            if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                print("Error: HTTP status code is \(httpResponse.statusCode)")
                return
            }
            
            // 6. Handle the successful response.
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            // 7. Process the data.  Decode the JSON and store it in Core Data.
            do {
                // Define the structs for decoding the JSON
                struct DeveloperJSON: Codable {
                    let name: String
                    let website: String
                    let logo: String
                }
                
                struct VideogameJSON: Codable {
                    let title: String
                    let logo: String
                    let releaseYear: String
                    let description: String
                    let developer: DeveloperJSON
                    let platforms: [String]
                    
                    // Define CodingKeys for JSON decoding
                    enum CodingKeys: String, CodingKey {
                        case title, logo, releaseYear, description, developer, platforms
                    }
                }
                
                // Attempt to decode the JSON data.
                let videogamesJSON = try JSONDecoder().decode([VideogameJSON].self, from: data)
                
                // 8.  IMPORTANT: Switch to the main thread before updating Core Data.
                DispatchQueue.main.async {
                    // Clear existing Core Data before inserting new data (Optional)
                    CoreDataService.deleteAllVideogames()
                    CoreDataService.deleteAllDevelopers()
                    
                    // 9. Iterate over the decoded JSON data and save it to Core Data.
                    for videogameJSON in videogamesJSON {
                        // First, save or fetch the developer.
                        let developer: Developer
                        if let existingDeveloper = CoreDataService.fetchDeveloper(byName: videogameJSON.developer.name) {
                            // Developer exists, update it
                            CoreDataService.updateDeveloper(developer: existingDeveloper, name: videogameJSON.developer.name, website: videogameJSON.developer.website, logo: videogameJSON.developer.logo)
                            developer = existingDeveloper
                        } else {
                            // Developer doesn't exist, create a new one.
                            if let newDeveloper = CoreDataService.saveDeveloper(name: videogameJSON.developer.name, website: videogameJSON.developer.website, logo: videogameJSON.developer.logo) {
                                developer = newDeveloper
                            } else {
                                // Handle error: Unable to save developer. Skip this videogame.
                                print("Error: Could not save developer \(videogameJSON.developer.name), skipping videogame \(videogameJSON.title)")
                                continue
                            }
                        }
                        
                        // Convert the releaseYear string to a Date
                        guard let releaseDate = CoreDataService.getDate(videogameJSON.releaseYear) else {
                            print("Error: Could not convert releaseYear to Date for \(videogameJSON.title), skipping")
                            continue
                        }
                        
                        // Save the videogame
                        CoreDataService.saveVideogame(title: videogameJSON.title,
                                                     logo: videogameJSON.logo,
                                                     releaseYear: releaseDate,
                                                     gameDescription: videogameJSON.description,
                                                     developer: developer,
                                                     platforms: videogameJSON.platforms) // Pass the [String]
                    }
                    
                    // Optionally, post a notification
                    NotificationCenter.default.post(name: .dataUpdated, object: nil)
                    
                } // End of DispatchQueue.main.async
                
            } catch {
                // Handle JSON decoding errors.
                print("Error decoding JSON: \(error)")
            }
        }
        
        // 10. Start the task.
        task.resume()
    }
    
    // MARK: - Core Data Helper Functions
    
    static func getDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Add locale
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: dateString)
    }
    
    static func deleteAllData() {
        deleteAllVideogames()
        deleteAllDevelopers()
    }
    
    static private func deleteAllVideogames() {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all Videogames: \(error)")
        }
    }
    
    static private func deleteAllDevelopers() {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all Developers: \(error)")
        }
    }
    
    // MARK: - Fetch Functions
    
     static func fetchAllVideogames() -> [Videogame] {
            let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
            // Add sort descriptors if you want the results to be ordered
             let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)  // Example: Sort by title
             fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                let videogames = try context.fetch(fetchRequest)
                return videogames
            } catch {
                print("Error fetching videogames: \(error)")
                return []
            }
        }
    
    static func fetchVideogame(byTitle title: String) -> Videogame? {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let videogames = try context.fetch(fetchRequest)
            return videogames.first
        } catch {
            print("Error fetching videogame by title: \(error)")
            return nil
        }
    }
    
    static func fetchDeveloper(byName name: String) -> Developer? {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let developers = try context.fetch(fetchRequest)
            return developers.first
        } catch {
            print("Error fetching developer by name: \(error)")
            return nil
        }
    }
    
    // MARK: - Save Functions
    // Modified to accept [String]
      static func saveVideogame(title: String, logo: String, releaseYear: Date, gameDescription: String, developer: Developer, platforms: [String]) {
          let newVideogame = Videogame(context: context)
          newVideogame.title = title
          newVideogame.logo = logo
          newVideogame.releaseYear = releaseYear
          newVideogame.gameDescription = gameDescription
          newVideogame.developer = developer
          newVideogame.platforms = platforms
          
          do {
              try context.save()
          } catch {
              print("Error saving videogame: \(error)")
          }
      }
    
    static func saveDeveloper(name: String, website: String, logo: String) -> Developer? {
        let newDeveloper = Developer(context: context)
        newDeveloper.name = name
        newDeveloper.website = website
        newDeveloper.logo = logo
        
        do {
            try context.save()
            return newDeveloper
        } catch {
            print("Error saving developer: \(error)")
            return nil
        }
    }
    
    // MARK: - Update Functions
     // Modified to accept [String]
     static func updateVideogame(videogame: Videogame, title: String, logo: String, releaseYear: Date, gameDescription: String, developer: Developer, platforms: [String]) {
           videogame.title = title
           videogame.logo = logo
           videogame.releaseYear = releaseYear
           videogame.gameDescription = gameDescription
           videogame.developer = developer
           videogame.platforms = platforms
           
           do {
               try context.save()
           } catch {
               print("Error updating videogame: \(error)")
           }
       }
    
    static func updateDeveloper(developer: Developer, name: String, website: String, logo: String) {
        developer.name = name
        developer.website = website
        developer.logo = logo
        
        do {
            try context.save()
        } catch {
            print("Error updating developer: \(error)")
        }
    }
    
    // MARK: - Delete Functions
    
    static func deleteVideogame(videogame: Videogame) {
        context.delete(videogame)
        do {
            try context.save()
        } catch {
            print("Error deleting videogame: \(error)")
        }
    }
    
    static func deleteDeveloper(developer: Developer) {
        context.delete(developer)
        do {
            try context.save()
        } catch {
            print("Error deleting developer: \(error)")
        }
    }
}

// MARK: - Notification for Data Update
extension Notification.Name {
    static let dataUpdated = Notification.Name("CoreDataUpdated")
}

