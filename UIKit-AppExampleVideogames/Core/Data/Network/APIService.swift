//
//  APIService.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

/// Service class responsible for making network calls to fetch data from the API.
/// It conforms to RemoteDataSource for VideogameEntity, providing APIVideogameDTOs.
class APIService: RemoteDataSource {
    // MARK: - RemoteDataSource Conformance
    typealias EntityType = VideogameEntity // Conceptual link: this remote source is for videogame data
    typealias DTOType = APIVideogameDTO

    private let session: URLSession

    /// Initializes the APIService.
    /// - Parameter session: The URLSession to use for network requests. Defaults to `URLSession.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches videogame DTOs from the configured Firebase URL.
    /// This method fulfills the `RemoteDataSource` requirement.
    func getAllDTOs(completion: @escaping (Result<[APIVideogameDTO], RepositoryError>) -> Void) {
        guard let url = URL(string: APIConstants.firebaseVideogamesURL) else {
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
                let decoder = JSONDecoder()
                let apiVideogames = try decoder.decode([APIVideogameDTO].self, from: data)
                completion(.success(apiVideogames))
            } catch let decodingError as DecodingError {
                // Log detailed decoding error for easier debugging
                print("--- APIService Decoding Error ---")
                print("Error: \(decodingError.localizedDescription)")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                case .valueNotFound(let value, let context):
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                case .keyNotFound(let key, let context):
                    print("Key '\(String(describing: key))' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                case .dataCorrupted(let context):
                    print("Data corrupted:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
                print("----------------------")
                completion(.failure(.decodingError(decodingError)))
            } catch {
                completion(.failure(.unknown(error)))
            }
        }
        task.resume()
    }
    
    // The old fetchRemoteVideogames method is now effectively replaced by getAllDTOs.
    // If it was used elsewhere directly, those call sites would need to be updated.
    // For clarity, I'm removing the old APIServiceProtocol and its direct usage.
}
