//
//  DeveloperLocalDataSourceProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/05/25.
//

import Foundation

/// Protocol defining the contract for a local data source specific to `DeveloperEntity`.
protocol DeveloperLocalDataSourceProtocol {
    /// Fetches all `DeveloperEntity` objects from the local data source.
    func getAll(completion: @escaping (Result<[DeveloperEntity], RepositoryError>) -> Void)

    /// Fetches a single `DeveloperEntity` by its identifier (business key, e.g., name) from the local data source.
    func getById(_ id: String, completion: @escaping (Result<DeveloperEntity?, RepositoryError>) -> Void)

    /// Saves a list of `DeveloperEntity` objects to the local data source.
    func saveAll(_ entities: [DeveloperEntity], completion: @escaping (Result<Void, RepositoryError>) -> Void)
    
    /// Deletes a single `DeveloperEntity` by its identifier (business key) from the local data source.
    func delete(_ id: String, completion: @escaping (Result<Void, RepositoryError>) -> Void)

    /// Deletes all `DeveloperEntity` objects from the local data source.
    func deleteAll(completion: @escaping (Result<Void, RepositoryError>) -> Void)
}
