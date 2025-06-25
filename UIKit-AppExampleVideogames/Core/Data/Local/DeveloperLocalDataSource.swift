//
//  DeveloperLocalDataSource.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/5/25.
//
//

import Foundation
import CoreData

// Conforms to the new specific protocol
class DeveloperLocalDataSource: DeveloperLocalDataSourceProtocol {
    // No typealias EntityType needed here anymore

    private let coreDataService: CoreDataService
    private let backgroundContext: NSManagedObjectContext
    private let viewContext: NSManagedObjectContext

    init(coreDataService: CoreDataService, persistentContainer: NSPersistentContainer) {
        self.coreDataService = coreDataService
        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // Good for background saves
        self.viewContext = persistentContainer.viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true // Good for UI updates
    }

    func getAll(completion: @escaping (Result<[DeveloperEntity], RepositoryError>) -> Void) {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
            do {
                let managedDevelopers = try self.viewContext.fetch(fetchRequest)
                let entities = managedDevelopers.map { DeveloperMapper.managedObjectToEntity($0) }
                completion(.success(entities))
            } catch {
                print("DeveloperLocalDataSource: Failed to fetch all DeveloperEntities: \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }

    func getById(_ id: String, completion: @escaping (Result<DeveloperEntity?, RepositoryError>) -> Void) {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", id) // DeveloperEntity.id is 'name'
            fetchRequest.fetchLimit = 1
            do {
                let managedDeveloper = try self.viewContext.fetch(fetchRequest).first
                if let mo = managedDeveloper {
                    completion(.success(DeveloperMapper.managedObjectToEntity(mo)))
                } else {
                    completion(.success(nil))
                }
            } catch {
                print("DeveloperLocalDataSource: Failed to fetch DeveloperEntity with name '\(id)': \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }

    func saveAll(_ entities: [DeveloperEntity], completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                completion(.failure(.unknown(nil))) // Or a more specific error
                return
            }
            var encounteredError: Error? = nil
            for developerEntity in entities {
                // DeveloperMapper.entityToManagedObject handles finding existing or creating new.
                // No explicit try needed here if the mapper itself doesn't throw, but good practice if it could.
                _ = DeveloperMapper.entityToManagedObject(entity: developerEntity, in: self.backgroundContext)
                // If entityToManagedObject could throw, you'd wrap it in do-catch
            }

            // This logging for encounteredError is not effective if the mapper doesn't throw
            // and errors are only logged within the mapper.
            // If mapping can fail silently (returning nil from a hypothetical "tryMap"), this needs adjustment.
            // Assuming DeveloperMapper.entityToManagedObject always returns a valid MO or crashes/asserts internally on failure.

            do {
                if self.backgroundContext.hasChanges {
                    try self.backgroundContext.save()
                }
                completion(.success(()))
            } catch {
                self.backgroundContext.rollback() // Rollback on save error
                print("DeveloperLocalDataSource: Failed to save DeveloperEntities: \(error)")
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
            let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", id)
            fetchRequest.fetchLimit = 1
            do {
                if let managedEntity = try self.backgroundContext.fetch(fetchRequest).first {
                    self.backgroundContext.delete(managedEntity)
                    if self.backgroundContext.hasChanges {
                        try self.backgroundContext.save()
                    }
                    completion(.success(()))
                } else {
                    completion(.failure(.dataNotFound)) // Data to delete was not found
                }
            } catch {
                self.backgroundContext.rollback()
                print("DeveloperLocalDataSource: Failed to delete DeveloperEntity with name '\(id)': \(error)")
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
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Developer.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                let batchDeleteResult = try self.backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = batchDeleteResult?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                                                         into: [self.viewContext, self.backgroundContext])
                }
                completion(.success(()))
            } catch {
                print("DeveloperLocalDataSource: Failed to delete all DeveloperEntities: \(error)")
                completion(.failure(.coreDataError(error)))
            }
        }
    }
}
