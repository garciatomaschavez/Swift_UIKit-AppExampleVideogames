//
//  DataSource.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//

import Foundation

// MARK: - Fetch Strategy Enum

/// Defines the strategy for fetching data when multiple sources (local, remote) are available.
enum FetchStrategy { // Changed from public to internal
    /// Fetches data only from the local data source.
    case localOnly
    /// Fetches data only from the remote data source.
    case remoteOnly
    /// Fetches data from the local data source first, then updates from the remote data source.
    /// The completion handler might be called twice: once with local data, once with updated remote data.
    case localThenRemote
    /// Fetches data from the remote data source first. If it fails, falls back to the local data source.
    case remoteElseLocal
}

// MARK: - Data Source Protocols

/// Protocol defining the contract for a local data source.
/// It works with a generic `EntityType` which is expected to be `Identifiable` by a `String` ID.
protocol LocalDataSource { // Changed from public to internal
    associatedtype EntityType: Identifiable where EntityType.ID == String

    /// Fetches all entities from the local data source.
    /// - Parameter completion: A closure called with the result.
    func getAll(completion: @escaping (Result<[EntityType], RepositoryError>) -> Void)

    /// Fetches a single entity by its identifier from the local data source.
    /// - Parameters:
    ///   - id: The unique `String` identifier of the entity.
    ///   - completion: A closure called with the result.
    func getById(_ id: String, completion: @escaping (Result<EntityType?, RepositoryError>) -> Void)

    /// Saves a list of entities to the local data source.
    /// This should handle updating existing entities or creating new ones.
    /// - Parameters:
    ///   - entities: An array of `EntityType` to save.
    ///   - completion: A closure called with the result.
    func saveAll(_ entities: [EntityType], completion: @escaping (Result<Void, RepositoryError>) -> Void)
    
    /// Deletes a single entity by its identifier from the local data source.
    /// - Parameters:
    ///   - id: The unique `String` identifier of the entity.
    ///   - completion: A closure called with the result.
    func delete(_ id: String, completion: @escaping (Result<Void, RepositoryError>) -> Void)

    /// Deletes all entities of `EntityType` from the local data source.
    /// - Parameter completion: A closure called with the result.
    func deleteAll(completion: @escaping (Result<Void, RepositoryError>) -> Void)
}

/// Protocol defining the contract for a remote data source.
/// It works with a generic `EntityType` and a `DTOType` (Data Transfer Object).
protocol RemoteDataSource { // Changed from public to internal
    associatedtype EntityType
    associatedtype DTOType // The DTO type that the remote source provides

    /// Fetches all DTOs from the remote data source.
    /// These DTOs will then typically be mapped to Entities.
    /// - Parameter completion: A closure called with the result.
    func getAllDTOs(completion: @escaping (Result<[DTOType], RepositoryError>) -> Void)

    // Add other remote operations if needed, e.g., fetching a single DTO by ID.
    // func getDTOById(_ id: String, completion: @escaping (Result<DTOType?, RepositoryError>) -> Void)
}
