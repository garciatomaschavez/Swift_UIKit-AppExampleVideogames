
//
//  DefaultDeveloperRepositoryImpl.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//
//

import Foundation

class DefaultDeveloperRepositoryImpl: DeveloperRepository {
    typealias EntityType = DeveloperEntity

    private let localDataSource: DeveloperLocalDataSource
    private let workQueue = DispatchQueue(label: "com.appexample.developerrepository.workqueue", qos: .userInitiated)

    init(localDataSource: DeveloperLocalDataSource) {
        self.localDataSource = localDataSource
    }

    // MARK: - DeveloperRepository Conformance

    func getAll(completion: @escaping (RepositoryResult<[DeveloperEntity]>) -> Void) {
        workQueue.async {
            self.localDataSource.getAll(completion: completion)
        }
    }

    func getById(_ id: String, completion: @escaping (RepositoryResult<DeveloperEntity?>) -> Void) {
        workQueue.async {
            self.localDataSource.getById(id, completion: completion)
        }
    }

    func save(_ entity: DeveloperEntity, completion: @escaping (RepositoryResult<DeveloperEntity>) -> Void) {
        workQueue.async {
            self.localDataSource.saveAll([entity]) { result in
                switch result {
                case .success:
                    self.localDataSource.getById(entity.id) { getResult in
                        switch getResult {
                        case .success(let savedEntity):
                            if let saved = savedEntity {
                                completion(.success(saved))
                            } else {
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
            self.localDataSource.delete(id, completion: completion)
        }
    }
}
