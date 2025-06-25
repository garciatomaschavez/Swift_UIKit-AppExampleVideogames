//
//  VideogameLocalDataSourceProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/05/25.
//

import Foundation

/// Protocol defining the contract for a local data source specific to `VideogameEntity`.
protocol VideogameLocalDataSourceProtocol {
    /// Fetches all `VideogameEntity` objects from the local data source.
    func getAll(completion: @escaping (Result<[VideogameEntity], RepositoryError>) -> Void)

    /// Fetches a single `VideogameEntity` by its identifier (business key, e.g., title) from the local data source.
    func getById(_ id: String, completion: @escaping (Result<VideogameEntity?, RepositoryError>) -> Void)

    /// Saves a list of `VideogameEntity` objects to the local data source.
    func saveAll(_ entities: [VideogameEntity], completion: @escaping (Result<Void, RepositoryError>) -> Void)
    
    /// Deletes a single `VideogameEntity` by its identifier (business key) from the local data source.
    func delete(_ id: String, completion: @escaping (Result<Void, RepositoryError>) -> Void)

    /// Deletes all `VideogameEntity` objects from the local data source.
    func deleteAll(completion: @escaping (Result<Void, RepositoryError>) -> Void)
    
    // Videogame-specific local operations
    /// Updates the favorite status of a videogame in local persistence.
    func updateFavoriteStatus(id: String, isFavorite: Bool, completion: @escaping (Result<VideogameEntity, RepositoryError>) -> Void)
    
    /// Fetches all videogames marked as favorites from local persistence.
    func fetchFavorites(completion: @escaping (Result<[VideogameEntity], RepositoryError>) -> Void)
}
