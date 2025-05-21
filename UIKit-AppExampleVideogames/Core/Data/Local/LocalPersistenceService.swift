//
//  LocalPersistenceService.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation
import CoreData

/// Protocol defining the contract for local data persistence operations.
/// This will be implemented by `CoreDataService`.
/// It works with `VideogameEntity` and `DeveloperEntity` domain models.
protocol LocalPersistenceService {

    // MARK: - Videogame Operations

    /// Saves a list of `VideogameEntity` objects to local persistence.
    /// This should handle updating existing videogames or creating new ones based on their ID.
    /// - Parameters:
    ///   - videogames: An array of `VideogameEntity` to save.
    ///   - completion: A closure called with the result, either success (Void) or a `RepositoryError`.
    func saveVideogames(_ videogames: [VideogameEntity], completion: @escaping (Result<Void, RepositoryError>) -> Void)

    /// Fetches all `VideogameEntity` objects from local persistence.
    /// - Parameter completion: A closure with the result.
    func fetchAllVideogames(completion: @escaping (Result<[VideogameEntity], RepositoryError>) -> Void)

    /// Fetches a single `VideogameEntity` by its identifier from local persistence.
    /// - Parameters:
    ///   - id: The unique identifier of the videogame.
    ///   - completion: A closure with the result.
    func fetchVideogame(byId id: String, completion: @escaping (Result<VideogameEntity?, RepositoryError>) -> Void)

    /// Updates the favorite status of a videogame in local persistence.
    /// - Parameters:
    ///   - id: The ID of the videogame to update.
    ///   - isFavorite: The new favorite status.
    ///   - completion: A closure with the result, containing the updated videogame entity.
    func updateVideogameFavoriteStatus(id: String, isFavorite: Bool, completion: @escaping (Result<VideogameEntity, RepositoryError>) -> Void)
    
    /// Deletes all videogames from local persistence.
    /// - Parameter completion: A closure called with the result.
    func deleteAllVideogames(completion: @escaping (Result<Void, RepositoryError>) -> Void)


    // MARK: - Developer Operations

    /// Saves a list of `DeveloperEntity` objects to local persistence.
    /// - Parameters:
    ///   - developers: An array of `DeveloperEntity` to save.
    ///   - completion: A closure called with the result.
    func saveDevelopers(_ developers: [DeveloperEntity], completion: @escaping (Result<Void, RepositoryError>) -> Void)
    
    /// Fetches all `DeveloperEntity` objects from local persistence.
    /// - Parameter completion: A closure with the result.
    func fetchAllDevelopers(completion: @escaping (Result<[DeveloperEntity], RepositoryError>) -> Void)

    /// Fetches a single `DeveloperEntity` by its identifier from local persistence.
    /// - Parameters:
    ///   - id: The unique identifier of the developer.
    ///   - completion: A closure with the result.
    func fetchDeveloper(byId id: String, completion: @escaping (Result<DeveloperEntity?, RepositoryError>) -> Void)
    
    /// Deletes all developers from local persistence.
    /// - Parameter completion: A closure called with the result.
    func deleteAllDevelopers(completion: @escaping (Result<Void, RepositoryError>) -> Void)
    
    // MARK: - General
    
    /// Checks if the local data store is empty (e.g., no videogames).
    /// - Parameter completion: A closure with the boolean result.
    func isLocalDataEmpty(completion: @escaping (Bool) -> Void)
}
