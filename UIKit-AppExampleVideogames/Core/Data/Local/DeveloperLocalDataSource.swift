//
//  DeveloperLocalDataSource.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/5/25.
//

import Foundation
import CoreData

class DeveloperLocalDataSource: LocalDataSource {
    typealias EntityType = DeveloperEntity

    private let coreDataService: CoreDataService // The actual CoreData interaction service
    private let backgroundContext: NSManagedObjectContext
    private let viewContext: NSManagedObjectContext

    init(coreDataService: CoreDataService, persistentContainer: NSPersistentContainer) {
        self.coreDataService = coreDataService
        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.viewContext = persistentContainer.viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true
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
                completion(.failure(.unknown(nil)))
                return
            }
            var encounteredError: Error? = nil
            for developerEntity in entities {
                do {
                    // DeveloperMapper.entityToManagedObject handles finding existing or creating new.
                    _ = DeveloperMapper.entityToManagedObject(entity: developerEntity, in: self.backgroundContext)
                } catch {
                    print("DeveloperLocalDataSource: Error mapping DeveloperEntity (name: \(developerEntity.name)) to managed object: \(error)")
                    encounteredError = error
                }
            }

            if encounteredError != nil {
                 print("DeveloperLocalDataSource: At least one DeveloperEntity failed to map. Proceeding to save successfully mapped items.")
            }

            do {
                if self.backgroundContext.hasChanges {
                    try self.backgroundContext.save()
                }
                completion(.success(()))
            } catch {
                self.backgroundContext.rollback()
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
                    completion(.failure(.dataNotFound))
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
