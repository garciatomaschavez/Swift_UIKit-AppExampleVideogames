//
//  APIServiceProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

/// Protocol defining the contract for an API service that fetches data directly from the remote source.
protocol APIServiceProtocol {
    /// Fetches a list of videogames from the remote API.
    /// - Parameter completion: A closure called with the result, either an array of `APIVideogameDTO`
    ///                         (matching the raw API response structure) or a `RepositoryError`.
    func fetchRemoteVideogames(completion: @escaping (Result<[APIVideogameDTO], RepositoryError>) -> Void)
}
