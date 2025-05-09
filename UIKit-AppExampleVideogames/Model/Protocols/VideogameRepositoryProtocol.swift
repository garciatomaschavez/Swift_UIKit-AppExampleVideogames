//
//  VideogameRepositoryProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// Defines the contract for data operations related to videogames.
/// Implementations of this protocol will handle the actual data fetching and storage
/// (e.g., from Core Data, a network API, etc.).
public protocol VideogameRepositoryProtocol {

    /// Fetches all videogame entities.
    /// - Parameter completion: A closure that is called with the result of the operation,
    ///                         containing either an array of `VideogameEntity` or an `Error`.
    func getAllVideogames(completion: @escaping (Result<[VideogameEntity], Error>) -> Void)

    /// Fetches a specific videogame entity by its unique identifier.
    /// - Parameters:
    ///   - id: The `UUID` of the videogame to fetch.
    ///   - completion: A closure that is called with the result, containing either the
    ///                 optional `VideogameEntity` (if found) or an `Error`.
    func getVideogame(byId id: UUID, completion: @escaping (Result<VideogameEntity?, Error>) -> Void)

    /// Saves a videogame entity. This can be used for both creating new videogames
    /// and updating existing ones.
    /// - Parameters:
    ///   - videogame: The `VideogameEntity` to save.
    ///   - completion: A closure that is called with the result, containing either `Void` on success or an `Error`.
    func saveVideogame(_ videogame: VideogameEntity, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Deletes a videogame entity by its unique identifier.
    /// - Parameters:
    ///   - id: The `UUID` of the videogame to delete.
    ///   - completion: A closure that is called with the result, containing either `Void` on success or an `Error`.
    func deleteVideogame(byId id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Updates the favorite status of a videogame.
    /// - Parameters:
    ///   - id: The `UUID` of the videogame to update.
    ///   - isFavorite: The new favorite status.
    ///   - completion: A closure that is called with the result, containing either `Void` on success or an `Error`.
    func updateFavoriteStatus(forVideogameId id: UUID, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void)

    // Add other necessary methods, for example:
    // func getVideogames(byPlatform platform: Platform, completion: @escaping (Result<[VideogameEntity], Error>) -> Void)
    // func getVideogames(byDeveloperId developerId: UUID, completion: @escaping (Result<[VideogameEntity], Error>) -> Void)
    // func searchVideogames(query: String, completion: @escaping (Result<[VideogameEntity], Error>) -> Void)
}
