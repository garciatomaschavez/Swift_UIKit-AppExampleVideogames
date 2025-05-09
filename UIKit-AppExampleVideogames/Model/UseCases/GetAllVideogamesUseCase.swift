//
//  GetAllVideogamesUseCase.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// A use case responsible for fetching all videogame entities.
/// It uses a `VideogameRepositoryProtocol` to abstract the data source.
public class GetAllVideogamesUseCase {
    private let videogameRepository: VideogameRepositoryProtocol

    /// Initializes the use case with a specific videogame repository.
    /// - Parameter videogameRepository: An object conforming to `VideogameRepositoryProtocol`
    ///                                  that will be used to fetch videogame data.
    public init(videogameRepository: VideogameRepositoryProtocol) {
        self.videogameRepository = videogameRepository
    }

    /// Executes the use case to fetch all videogames.
    /// - Parameter completion: A closure that is called with the result of the operation,
    ///                         containing either an array of `VideogameEntity` or an `Error`.
    public func execute(completion: @escaping (Result<[VideogameEntity], Error>) -> Void) {
        videogameRepository.getAllVideogames(completion: completion)
    }
}
