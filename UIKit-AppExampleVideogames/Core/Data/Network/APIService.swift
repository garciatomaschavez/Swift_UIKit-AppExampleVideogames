//
//  APIService.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//  
//

import Foundation

/// Service class responsible for making network calls to fetch data from the API.
/// It now conforms to the specific `VideogameRemoteDataSourceProtocol`.
class APIService: APIServiceProtocol {
    // No EntityType alias needed here as the protocol is specific.

    let firebaseVideogamesURL = "https://appexamplevideogames-default-rtdb.europe-west1.firebasedatabase.app/videogames.json"
    
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches videogame data as an array of dictionaries from the configured Firebase URL.
    func getAllRawData(completion: @escaping (Result<[[String: Any]], RepositoryError>) -> Void) {
        guard let url = URL(string: firebaseVideogamesURL) else {
            completion(.failure(.networkError(NSError(domain: "APIService.URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL string."]))))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError(NSError(domain: "APIService.Response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response object."]))))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.networkError(NSError(domain: "APIService.HTTPStatus", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status code: \(httpResponse.statusCode)"]))))
                return
            }

            guard let data = data else {
                completion(.failure(.dataNotFound))
                return
            }

            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                    print("APIService: Failed to cast JSON object to [[String: Any]]. Data might not be a JSON array of objects.")
                    completion(.failure(.decodingError(NSError(domain: "APIService.JSONCast", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not cast JSON to array of dictionaries."]))))
                    return
                }
                completion(.success(jsonObject))
            } catch let jsonError {
                print("--- APIService JSON Deserialization Error ---")
                print("Error: \(jsonError.localizedDescription)")
                completion(.failure(.decodingError(jsonError)))
            }
        }
        task.resume()
    }
}
