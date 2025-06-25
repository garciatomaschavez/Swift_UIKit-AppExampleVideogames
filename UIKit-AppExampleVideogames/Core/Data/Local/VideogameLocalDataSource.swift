//
//  VideogameLocalDataSource.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/5/25.
//
//

import Foundation
import CoreData

// Conforms to the new specific protocol
class VideogameLocalDataSource: VideogameLocalDataSourceProtocol {
    // No typealias EntityType needed here anymore as it's not a generic protocol

    private let coreDataService: CoreDataService
    private let backgroundContext: NSManagedObjectContext
    private let viewContext: NSManagedObjectContext

    init(coreDataService: CoreDataService, persistentContainer: NSPersistentContainer) {
        self.coreDataService = coreDataService
        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.viewContext = persistentContainer.viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true
    }

    func getAll(completion: @escaping (Result<[VideogameEntity], RepositoryError>) -> Void) {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
            do {
                let managedVideogames = try self.viewContext.fetch(fetchRequest)
                let entities = managedVideogames.map { VideogameMapper.managedObjectToEntity($0) }
                completion(.success(entities))
            } catch {
                print("VideogameLocalDataSource: Failed to fetch all VideogameEntities: \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }

    func getById(_ id: String, completion: @escaping (Result<VideogameEntity?, RepositoryError>) -> Void) {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", id)
            fetchRequest.fetchLimit = 1
            do {
                let managedVideogame = try self.viewContext.fetch(fetchRequest).first
                if let mo = managedVideogame {
                    completion(.success(VideogameMapper.managedObjectToEntity(mo)))
                } else {
                    completion(.success(nil))
                }
            } catch {
                print("VideogameLocalDataSource: Failed to fetch VideogameEntity with title '\(id)': \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }

    func saveAll(_ entities: [VideogameEntity], completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                completion(.failure(.unknown(nil)))
                return
            }
            var encounteredError: Error? = nil
            for videogameEntity in entities {
                do {
                    _ = try VideogameMapper.entityToManagedObject(entity: videogameEntity, in: self.backgroundContext)
                } catch {
                    print("VideogameLocalDataSource: Error mapping VideogameEntity (title: \(videogameEntity.title)) to managed object: \(error)")
                    encounteredError = error // Capture the last error, or collect all errors
                }
            }
            if encounteredError != nil {
                 print("VideogameLocalDataSource: At least one VideogameEntity failed to map. Proceeding to save successfully mapped items.")
            }
            do {
                if self.backgroundContext.hasChanges {
                    try self.backgroundContext.save()
                }
                completion(.success(()))
            } catch {
                self.backgroundContext.rollback()
                print("VideogameLocalDataSource: Failed to save VideogameEntities: \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }
    
    func delete(_ id: String, completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                completion(.failure(.unknown(nil)))
                return
            }
            let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", id)
            fetchRequest.fetchLimit = 1 // Ensure only one is targeted if titles aren't unique (though they should be as business keys)
            do {
                if let managedEntity = try self.backgroundContext.fetch(fetchRequest).first {
                    self.backgroundContext.delete(managedEntity)
                    if self.backgroundContext.hasChanges {
                        try self.backgroundContext.save()
                    }
                    completion(.success(()))
                } else {
                    completion(.failure(.dataNotFound))
                }
            } catch {
                self.backgroundContext.rollback()
                print("VideogameLocalDataSource: Failed to delete VideogameEntity with title '\(id)': \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }

    func deleteAll(completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                completion(.failure(.unknown(nil)))
                return
            }
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Videogame.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs // Important for merging changes
            do {
                let batchDeleteResult = try self.backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                // Merge changes to other contexts, like the viewContext
                if let objectIDs = batchDeleteResult?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                                                         into: [self.viewContext, self.backgroundContext])
                }
                completion(.success(()))
            } catch {
                print("VideogameLocalDataSource: Failed to delete all VideogameEntities: \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }
    
    // MARK: - VideogameLocalDataSourceProtocol Specific Methods
    
    func updateFavoriteStatus(id: String, isFavorite: Bool, completion: @escaping (Result<VideogameEntity, RepositoryError>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                completion(.failure(.unknown(nil)))
                return
            }
            let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", id)
            fetchRequest.fetchLimit = 1
            do {
                guard let managedVideogame = try self.backgroundContext.fetch(fetchRequest).first else {
                    completion(.failure(.dataNotFound))
                    return
                }
                managedVideogame.isFavorite = isFavorite
                if self.backgroundContext.hasChanges {
                    try self.backgroundContext.save()
                }
                let updatedEntity = VideogameMapper.managedObjectToEntity(managedVideogame)
                completion(.success(updatedEntity))
            } catch {
                self.backgroundContext.rollback()
                print("VideogameLocalDataSource: Failed to update favorite status for title '\(id)': \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }
    
    func fetchFavorites(completion: @escaping (Result<[VideogameEntity], RepositoryError>) -> Void) {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
            do {
                let managedVideogames = try self.viewContext.fetch(fetchRequest)
                let entities = managedVideogames.map { VideogameMapper.managedObjectToEntity($0) }
                completion(.success(entities))
            } catch {
                print("VideogameLocalDataSource: Failed to fetch favorite VideogameEntities: \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }
}
