//
//  APIServiceProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

/// Protocol defining the contract for an API service that fetches data directly from the remote source.
protocol APIServiceProtocol {
//    /// Fetches a list of videogames from the remote API.
//    /// - Parameter completion: A closure called with the result, either an array of `APIVideogameDTO`
//    ///                         (matching the raw API response structure) or a `RepositoryError`.
//    func fetchRemoteVideogames(completion: @escaping (Result<[APIVideogameDTO], RepositoryError>) -> Void)
//    
    /// Fetches all videogame data objects from the remote source as an array of dictionaries.
    /// These dictionaries will then be mapped to `VideogameEntity` objects by a Mapper.
    /// - Parameter completion: A closure called with the result.
    func getAllRawData(completion: @escaping (Result<[[String: Any]], RepositoryError>) -> Void)

}
