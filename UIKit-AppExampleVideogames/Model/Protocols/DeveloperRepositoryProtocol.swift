//
//  DeveloperRepositoryProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// Defines the contract for data operations related to developers.w
public protocol DeveloperRepositoryProtocol {

    /// Fetches all developer entities.
    /// - Parameter completion: A closure with the result: an array of `DeveloperEntity` or an `Error`.
    func getAllDevelopers(completion: @escaping (Result<[DeveloperEntity], Error>) -> Void)

    /// Fetches a specific developer entity by its unique identifier.
    /// - Parameters:
    ///   - id: The `UUID` of the developer to fetch.
    ///   - completion: A closure with the result: the optional `DeveloperEntity` or an `Error`.
    func getDeveloper(byId id: UUID, completion: @escaping (Result<DeveloperEntity?, Error>) -> Void)

    /// Saves a developer entity.
    /// - Parameters:
    ///   - developer: The `DeveloperEntity` to save.
    ///   - completion: A closure with the result: `Void` on success or an `Error`.
    func saveDeveloper(_ developer: DeveloperEntity, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Deletes a developer entity by its unique identifier.
    /// - Parameters:
    ///   - id: The `UUID` of the developer to delete.
    ///   - completion: A closure with the result: `Void` on success or an `Error`.
    func deleteDeveloper(byId id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    
    // Potentially, a method to get all games by a developer, though this might also
    // be handled by a query on the VideogameRepositoryProtocol depending on data relationships.
    // func getVideogames(forDeveloperId developerId: UUID, completion: @escaping (Result<[VideogameEntity], Error>) -> Void)
}
