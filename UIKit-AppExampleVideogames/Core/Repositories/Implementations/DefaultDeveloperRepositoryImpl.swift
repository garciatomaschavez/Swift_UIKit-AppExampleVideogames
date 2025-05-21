//
//  DefaultDeveloperRepositoryImpl.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//

import Foundation

class DefaultDeveloperRepositoryImpl: DeveloperRepository {
    typealias EntityType = DeveloperEntity

    private let localDataSource: DeveloperLocalDataSource
    // No direct remote data source for developers, as they are fetched with videogames.
    // No explicit fetchStrategy needed here as operations are primarily local.
    private let workQueue = DispatchQueue(label: "com.appexample.developerrepository.workqueue", qos: .userInitiated)

    init(localDataSource: DeveloperLocalDataSource) {
        self.localDataSource = localDataSource
    }

    // MARK: - DeveloperRepository Conformance

    func getAll(completion: @escaping (RepositoryResult<[DeveloperEntity]>) -> Void) {
        workQueue.async {
            // Developers are sourced from the local database, which is populated
            // when videogames are fetched and their developers are extracted and saved.
            self.localDataSource.getAll(completion: completion)
        }
    }

    func getById(_ id: String, completion: @escaping (RepositoryResult<DeveloperEntity?>) -> Void) {
        // 'id' for DeveloperEntity is its name.
        workQueue.async {
            self.localDataSource.getById(id, completion: completion)
        }
    }

    func save(_ entity: DeveloperEntity, completion: @escaping (RepositoryResult<DeveloperEntity>) -> Void) {
        workQueue.async {
            // Save to local data source.
            self.localDataSource.saveAll([entity]) { result in // saveAll expects an array
                switch result {
                case .success:
                    // Fetch the saved entity to ensure we return the latest state
                    self.localDataSource.getById(entity.id) { getResult in
                        switch getResult {
                        case .success(let savedEntity):
                            if let saved = savedEntity {
                                completion(.success(saved))
                            } else {
                                // This case should ideally not be reached if saveAll was successful
                                // and the entity.id is correct.
                                print("DefaultDeveloperRepositoryImpl: Failed to retrieve developer after save, ID: \(entity.id)")
                                completion(.failure(.dataNotFound))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func delete(_ id: String, completion: @escaping (RepositoryResult<Void>) -> Void) {
        workQueue.async {
            // Delete from local data source.
            self.localDataSource.delete(id, completion: completion)
        }
    }
}
