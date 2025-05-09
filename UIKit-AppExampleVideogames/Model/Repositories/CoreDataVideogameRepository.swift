//
//  CoreDataVideogameRepository.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation
import CoreData

enum RepositoryError: Error {
     case objectNotFound
     case coreDataError(Error)
     case mappingFailed
     case generalError(String)
 }

class CoreDataVideogameRepository: VideogameRepositoryProtocol {
    private let coreDataService: CoreDataService // Instance of the refactored service
    private var context: NSManagedObjectContext {
        // Get context from the CoreDataService instance
        return coreDataService.mainContext
    }

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func getAllVideogames(completion: @escaping (Result<[VideogameEntity], Error>) -> Void) {
        // Now, perform the fetch directly using the context provided by CoreDataService
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        // Optionally add sort descriptors
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let managedVideogames = try context.fetch(fetchRequest)
            let entities = managedVideogames.compactMap { VideogameMapper.toEntity(managedObject: $0) }
            completion(.success(entities))
        } catch {
            completion(.failure(RepositoryError.coreDataError(error)))
        }
    }

    func getVideogame(byId id: UUID, completion: @escaping (Result<VideogameEntity?, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            let managedVideogames = try context.fetch(fetchRequest)
            if let managedVideogame = managedVideogames.first {
                if let entity = VideogameMapper.toEntity(managedObject: managedVideogame) {
                    completion(.success(entity))
                } else {
                    completion(.failure(RepositoryError.mappingFailed))
                }
            } else {
                completion(.success(nil))
            }
        } catch {
            completion(.failure(RepositoryError.coreDataError(error)))
        }
    }

    func saveVideogame(_ videogameEntity: VideogameEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", videogameEntity.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let existingMOs = try context.fetch(fetchRequest)
            let existingMO = existingMOs.first
            
            _ = VideogameMapper.toManagedObject(entity: videogameEntity, in: context, existingManagedObject: existingMO)
            
            // Use the new saveChanges method from CoreDataService
            coreDataService.saveChanges { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let serviceError): // serviceError is CoreDataServiceError
                    completion(.failure(RepositoryError.coreDataError(serviceError))) // Wrap it if needed
                }
            }
        } catch {
            completion(.failure(RepositoryError.coreDataError(error)))
        }
    }
    
    func deleteVideogame(byId id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let videogameToDelete = results.first {
                context.delete(videogameToDelete)
                coreDataService.saveChanges { result in
                    switch result {
                    case .success():
                        completion(.success(()))
                    case .failure(let serviceError):
                        completion(.failure(RepositoryError.coreDataError(serviceError)))
                    }
                }
            } else {
                completion(.failure(RepositoryError.objectNotFound))
            }
        } catch {
            completion(.failure(RepositoryError.coreDataError(error)))
        }
    }
    
    func updateFavoriteStatus(forVideogameId id: UUID, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let videogameToUpdate = results.first {
                videogameToUpdate.isFavorite = isFavorite
                coreDataService.saveChanges { result in
                    switch result {
                    case .success():
                        completion(.success(()))
                    case .failure(let serviceError):
                        completion(.failure(RepositoryError.coreDataError(serviceError)))
                    }
                }
            } else {
                completion(.failure(RepositoryError.objectNotFound))
            }
        } catch {
            completion(.failure(RepositoryError.coreDataError(error)))
        }
    }
}
