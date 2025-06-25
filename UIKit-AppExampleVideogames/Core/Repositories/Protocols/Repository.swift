//
//  Repository.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

// MARK: - Result Typealias

/// A generic result typealias for repository operations, using `RepositoryError`.
typealias RepositoryResult<T> = Result<T, RepositoryError> // Changed from public to internal (implicitly by removing public)

// MARK: - Generic Repository Protocol

/// A generic protocol defining common operations for a repository.
/// It uses an associated type `EntityType` which must conform to `Identifiable` with a `String` ID.
protocol Repository { // Changed from public to internal
    associatedtype EntityType: Identifiable where EntityType.ID == String

    /// Fetches all entities of `EntityType`, employing a defined fetch strategy.
    /// - Parameter completion: A closure called with the result.
    func getAll(completion: @escaping (RepositoryResult<[EntityType]>) -> Void)

    /// Fetches a single entity of `EntityType` by its identifier, employing a defined fetch strategy.
    /// - Parameter id: The unique `String` identifier of the entity to fetch.
    /// - Parameter completion: A closure called with the result.
    func getById(_ id: String, completion: @escaping (RepositoryResult<EntityType?>) -> Void)
    
    /// Adds or updates a single entity.
    /// - Parameters:
    ///   - entity: The entity to save or update.
    ///   - completion: A closure called with the result, containing the saved/updated entity.
    func save(_ entity: EntityType, completion: @escaping (RepositoryResult<EntityType>) -> Void)

    /// Deletes a single entity by its identifier.
    /// - Parameters:
    ///   - id: The unique `String` identifier of the entity to delete.
    ///   - completion: A closure called with the result.
    func delete(_ id: String, completion: @escaping (RepositoryResult<Void>) -> Void)
}

// MARK: - Specific Repository Protocols

/// A specialized repository protocol for `VideogameEntity`.
/// Inherits from the generic `Repository`.
protocol VideogameRepository: Repository where EntityType == VideogameEntity { // Changed from public to internal
    /// Fetches all videogames marked as favorites.
    /// - Parameter completion: A closure with the result.
    func getFavorites(completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void)

    /// Updates the favorite status of a videogame.
    /// - Parameters:
    ///   - id: The `String` ID (business key, e.g., title) of the videogame to update.
    ///   - isFavorite: The new favorite status.
    ///   - completion: A closure with the result, containing the updated videogame.
    func updateFavorite(id: String, isFavorite: Bool, completion: @escaping (RepositoryResult<VideogameEntity>) -> Void)

    /// Searches for videogames by developer name.
    /// - Parameters:
    ///   - developerName: The name of the developer to search for.
    ///   - completion: A closure with the result.
    func searchByDeveloper(_ developerName: String, completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void)

    /// Searches for videogames by release year.
    /// - Parameters:
    ///   - year: The release year (as a String, e.g., "2023") to search for.
    ///   - completion: A closure with the result.
    func searchByReleaseYear(_ year: String, completion: @escaping (RepositoryResult<[VideogameEntity]>) -> Void)
}

/// A specialized repository protocol for `DeveloperEntity`.
/// Inherits from the generic `Repository`.
protocol DeveloperRepository: Repository where EntityType == DeveloperEntity { // Changed from public to internal
    // Developer-specific data operations can be defined here if needed in the future.
}
