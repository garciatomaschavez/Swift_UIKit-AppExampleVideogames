//
//  GetVideogameByIdUseCase.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// A use case responsible for fetching a specific videogame entity by its ID.
public class GetVideogameByIdUseCase {
    private let videogameRepository: VideogameRepositoryProtocol

    public init(videogameRepository: VideogameRepositoryProtocol) {
        self.videogameRepository = videogameRepository
    }

    /// Executes the use case to fetch a videogame by its unique identifier.
    /// - Parameters:
    ///   - id: The `UUID` of the videogame to fetch.
    ///   - completion: A closure that is called with the result, containing either the
    ///                 optional `VideogameEntity` (if found) or an `Error`.
    public func execute(id: UUID, completion: @escaping (Result<VideogameEntity?, Error>) -> Void) {
        videogameRepository.getVideogame(byId: id, completion: completion)
    }
}
