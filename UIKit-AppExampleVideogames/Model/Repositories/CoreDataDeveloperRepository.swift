//
//  CoreDataDeveloperRepository.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation
import CoreData

// Assuming RepositoryError is defined
// enum RepositoryError: Error {
//     case objectNotFound
//     case coreDataError(Error)
//     case mappingFailed
//     case generalError(String)
// }

class CoreDataDeveloperRepository: DeveloperRepositoryProtocol {
    private let coreDataService: CoreDataService // Instance of the refactored service
    private var context: NSManagedObjectContext {
        // Get context from the CoreDataService instance
        return coreDataService.mainContext
    }

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func getAllDevelopers(completion: @escaping (Result<[DeveloperEntity], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        // Optionally add sort descriptors
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let managedDevelopers = try context.fetch(fetchRequest)
            let entities = managedDevelopers.compactMap { DeveloperMapper.toEntity(managedObject: $0) }
            completion(.success(entities))
        } catch {
            completion(.failure(RepositoryError.coreDataError(error)))
        }
    }

    func getDeveloper(byId id: UUID, completion: @escaping (Result<DeveloperEntity?, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            let managedDevelopers = try context.fetch(fetchRequest)
            if let managedDeveloper = managedDevelopers.first {
                if let entity = DeveloperMapper.toEntity(managedObject: managedDeveloper) {
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

    func saveDeveloper(_ developerEntity: DeveloperEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", developerEntity.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let existingMOs = try context.fetch(fetchRequest)
            let existingMO = existingMOs.first
            
            _ = DeveloperMapper.toManagedObject(entity: developerEntity, in: context, existingManagedObject: existingMO)
            
            // Use the new saveChanges method from CoreDataService
            coreDataService.saveChanges { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let serviceError):
                    completion(.failure(RepositoryError.coreDataError(serviceError)))
                }
            }
        } catch {
            completion(.failure(RepositoryError.coreDataError(error)))
        }
    }
    
    func deleteDeveloper(byId id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let developerToDelete = results.first {
                context.delete(developerToDelete)
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
