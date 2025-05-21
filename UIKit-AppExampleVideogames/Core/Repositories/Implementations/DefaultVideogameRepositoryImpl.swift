//
//  DefaultVideogameRepositoryImpl.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//

import Foundation

class DefaultVideogameRepositoryImpl: VideogameRepository {
    typealias EntityType = VideogameEntity

    private let videogameLocalDataSource: VideogameLocalDataSource
    private let developerLocalDataSource: DeveloperLocalDataSource // To save/update developers linked to videogames
    private let remoteDataSource: APIService // Specifically for APIVideogameDTO
    private let fetchStrategy: FetchStrategy
    private let workQueue = DispatchQueue(label: "com.appexample.videogamerepository.workqueue", qos: .userInitiated)

    init(
        videogameLocalDataSource: VideogameLocalDataSource,
        developerLocalDataSource: DeveloperLocalDataSource,
        remoteDataSource: APIService,
        fetchStrategy: FetchStrategy = .remoteElseLocal // Default strategy
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
                self.fetchRemoteAndSave(completion: completion)
            case .localThenRemote:
                // 1. Fetch and return local data
                self.videogameLocalDataSource.getAll { localResult in
                    completion(localResult) // Call completion with local data first
                    
                    // 2. Then fetch remote, save, and (optionally) call completion again
                    // This part is tricky as completion is escaping and might be called twice.
                    // The client (Interactor/Presenter) must be aware of this behavior.
                    // For simplicity in this example, we'll just update the cache.
                    // A more robust solution might use Combine or RxSwift, or a delegate pattern for multiple updates.
                    self.fetchRemoteAndSave { remoteResult in
                        switch remoteResult {
                        case .success(let remoteVideogames):
                            print("DefaultVideogameRepositoryImpl: Local cache updated from remote.")
                            // Optionally, call completion again if the contract allows for multiple emissions
                            // completion(.success(remoteVideogames))
                        case .failure(let error):
                            print("DefaultVideogameRepositoryImpl: Failed to update local cache from remote: \(error)")
                        }
                    }
                }
            case .remoteElseLocal:
                self.fetchRemoteAndSave { result in
                    switch result {
                    case .success(let videogames):
                        if videogames.isEmpty { // If remote returned success but no data (e.g. empty array)
                            print("DefaultVideogameRepositoryImpl: Remote fetch successful but returned no videogames. Trying local.")
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

    private func fetchRemoteAndSave(completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void) {
        remoteDataSource.getAllDTOs { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let dtos):
                // Map DTOs to VideogameEntities
                let videogameEntities = dtos.map { VideogameMapper.dtoToEntity($0) }
                
                // Extract unique DeveloperEntities from the VideogameEntities
                // DeveloperEntity is Hashable, so Set creation is fine.
                let developerEntities = Array(Set(videogameEntities.map { $0.developer }))

                // Save Developers first
                self.developerLocalDataSource.saveAll(developerEntities) { devSaveResult in
                    switch devSaveResult {
                    case .success:
                        // Then save Videogames
                        self.videogameLocalDataSource.saveAll(videogameEntities) { vgSaveResult in
                            switch vgSaveResult {
                            case .success:
                                completion(.success(videogameEntities))
                            case .failure(let error):
                                print("DefaultVideogameRepositoryImpl: Error saving videogames to local data source: \(error)")
                                // Even if saving fails, we got data from remote.
                                // Decide if we should return success with remote data or failure.
                                // For now, returning success with the fetched (but potentially unsaved) data.
                                completion(.success(videogameEntities))
                            }
                        }
                    case .failure(let error):
                        print("DefaultVideogameRepositoryImpl: Error saving developers to local data source: \(error)")
                        // If developers fail to save, videogames might have issues with relations.
                        // Decide on error handling strategy. For now, complete with failure.
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getById(_ id: String, completion: @escaping (RepositoryResult<VideogameEntity?>) -> Void) {
        // Typically, getById is fast enough to just hit local.
        // Or, implement a strategy similar to getAll if freshness is critical.
        workQueue.async {
            self.videogameLocalDataSource.getById(id, completion: completion)
        }
    }

    func save(_ entity: VideogameEntity, completion: @escaping (RepositoryResult<VideogameEntity>) -> Void) {
        workQueue.async {
            // Save to local data source.
            // Remote saving (POST/PUT to API) would require methods on RemoteDataSource and APIService.
            self.videogameLocalDataSource.saveAll([entity]) { result in // saveAll expects an array
                switch result {
                case .success:
                    // Fetch the saved entity to ensure we return the latest state (e.g., if DB modifies it)
                    self.videogameLocalDataSource.getById(entity.id) { getResult in
                        switch getResult {
                        case .success(let savedEntity):
                            if let saved = savedEntity {
                                completion(.success(saved))
                            } else {
                                completion(.failure(.dataNotFound)) // Should not happen if save was successful
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
            // Remote deletion (DELETE to API) would require methods on RemoteDataSource and APIService.
            self.videogameLocalDataSource.delete(id, completion: completion)
        }
    }

    // MARK: - Videogame Specific Methods

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
            // This search is performed on the local data source.
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
            // This search is performed on the local data source.
            self.videogameLocalDataSource.getAll { result in
                switch result {
                case .success(let allVideogames):
                    // Assuming VideogameEntity.releaseDateString is in a format like "YYYY-MM-DD..."
                    // For a more precise search, parsing the date might be needed.
                    let filtered = allVideogames.filter { $0.releaseDateString.hasPrefix(year) }
                    completion(.success(filtered))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
