
//
//  DefaultVideogameRepositoryImpl.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//
//

import Foundation

class DefaultVideogameRepositoryImpl: VideogameRepository {
    typealias EntityType = VideogameEntity

    // Use the new specific local data source protocols
    private let videogameLocalDataSource: VideogameLocalDataSourceProtocol
    private let developerLocalDataSource: DeveloperLocalDataSourceProtocol
    // Use the new specific remote data source protocol
    private let remoteDataSource: APIServiceProtocol
    private let fetchStrategy: FetchStrategy
    private let workQueue = DispatchQueue(label: "com.appexample.videogamerepository.workqueue", qos: .userInitiated)

    init(
        videogameLocalDataSource: VideogameLocalDataSourceProtocol,
        developerLocalDataSource: DeveloperLocalDataSourceProtocol,
        remoteDataSource: APIServiceProtocol, // Injected APIService (conforming to this)
        fetchStrategy: FetchStrategy = .remoteElseLocal
    ) {
        self.videogameLocalDataSource = videogameLocalDataSource
        self.developerLocalDataSource = developerLocalDataSource
        self.remoteDataSource = remoteDataSource
        self.fetchStrategy = fetchStrategy
    }

    // MARK: - VideogameRepository Conformance

    func getAll(completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void) {
        workQueue.async {
            switch self.fetchStrategy {
            case .localOnly:
                self.videogameLocalDataSource.getAll(completion: completion)
            case .remoteOnly:
                self.fetchRemoteMapAndSave(completion: completion)
            case .localThenRemote:
                self.videogameLocalDataSource.getAll { localResult in
                    completion(localResult)
                    self.fetchRemoteMapAndSave { remoteResult in
                        switch remoteResult {
                        case .success:
                            print("DefaultVideogameRepositoryImpl: Local cache updated from remote.")
                        case .failure(let error):
                            print("DefaultVideogameRepositoryImpl: Failed to update local cache from remote: \(error)")
                        }
                    }
                }
            case .remoteElseLocal:
                self.fetchRemoteMapAndSave { result in
                    switch result {
                    case .success(let videogames):
                        if videogames.isEmpty {
                            print("DefaultVideogameRepositoryImpl: Remote fetch successful but returned no videogames (or failed mapping). Trying local.")
                            self.videogameLocalDataSource.getAll(completion: completion)
                        } else {
                            completion(.success(videogames))
                        }
                    case .failure:
                        print("DefaultVideogameRepositoryImpl: Remote fetch failed. Falling back to local.")
                        self.videogameLocalDataSource.getAll(completion: completion)
                    }
                }
            }
        }
    }

    private func fetchRemoteMapAndSave(completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void) {
        remoteDataSource.getAllRawData { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let rawDataArray):
                let videogameEntities = rawDataArray.compactMap { VideogameMapper.rawDataToEntity(rawData: $0) }
                
                if rawDataArray.count > 0 && videogameEntities.isEmpty {
                    print("⚠️ DefaultVideogameRepositoryImpl: Received raw data from remote, but failed to map any to VideogameEntity.")
                }
                
                let developerEntities = Array(Set(videogameEntities.map { $0.developer }))

                self.developerLocalDataSource.saveAll(developerEntities) { devSaveResult in
                    switch devSaveResult {
                    case .success:
                        self.videogameLocalDataSource.saveAll(videogameEntities) { vgSaveResult in
                            switch vgSaveResult {
                            case .success:
                                completion(.success(videogameEntities))
                            case .failure(let error):
                                print("DefaultVideogameRepositoryImpl: Error saving videogames to local data source: \(error)")
                                completion(.success(videogameEntities)) // Still return fetched data
                            }
                        }
                    case .failure(let error):
                        print("DefaultVideogameRepositoryImpl: Error saving developers to local data source: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getById(_ id: String, completion: @escaping (RepositoryResult<VideogameEntity?>) -> Void) {
        workQueue.async {
            self.videogameLocalDataSource.getById(id, completion: completion)
        }
    }

    func save(_ entity: VideogameEntity, completion: @escaping (RepositoryResult<VideogameEntity>) -> Void) {
        workQueue.async {
            self.developerLocalDataSource.saveAll([entity.developer]) { devSaveResult in
                switch devSaveResult {
                case .success:
                    self.videogameLocalDataSource.saveAll([entity]) { result in
                        switch result {
                        case .success:
                            self.videogameLocalDataSource.getById(entity.id) { getResult in
                                switch getResult {
                                case .success(let savedEntity):
                                    if let saved = savedEntity {
                                        completion(.success(saved))
                                    } else {
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
                case .failure(let error):
                     print("DefaultVideogameRepositoryImpl: Error saving developer before saving videogame: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    func delete(_ id: String, completion: @escaping (RepositoryResult<Void>) -> Void) {
        workQueue.async {
            self.videogameLocalDataSource.delete(id, completion: completion)
        }
    }

    func getFavorites(completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void) {
        workQueue.async {
            self.videogameLocalDataSource.fetchFavorites(completion: completion)
        }
    }

    func updateFavorite(id: String, isFavorite: Bool, completion: @escaping (RepositoryResult<VideogameEntity>) -> Void) {
        workQueue.async {
            self.videogameLocalDataSource.updateFavoriteStatus(id: id, isFavorite: isFavorite, completion: completion)
        }
    }

    func searchByDeveloper(_ developerName: String, completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void) {
        workQueue.async {
            self.videogameLocalDataSource.getAll { result in
                switch result {
                case .success(let allVideogames):
                    let filtered = allVideogames.filter { $0.developer.name.localizedCaseInsensitiveContains(developerName) }
                    completion(.success(filtered))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func searchByReleaseYear(_ year: String, completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void) {
        workQueue.async {
            self.videogameLocalDataSource.getAll { result in
                switch result {
                case .success(let allVideogames):
                    let filtered = allVideogames.filter { $0.releaseDateString.hasPrefix(year) }
                    completion(.success(filtered))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
