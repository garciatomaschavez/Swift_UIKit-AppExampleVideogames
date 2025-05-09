//
//  UpdateFavoriteVideogameUseCase.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// A use case for updating the favorite status of a videogame.
public class UpdateFavoriteVideogameUseCase {
    private let videogameRepository: VideogameRepositoryProtocol

    public init(videogameRepository: VideogameRepositoryProtocol) {
        self.videogameRepository = videogameRepository
    }

    /// Executes the use case to update the favorite status.
    /// - Parameters:
    ///   - videogameId: The ID of the videogame to update.
    ///   - isFavorite: The new favorite status.
    ///   - completion: A closure called with the result (`Void` on success or an `Error`).
    public func execute(videogameId: UUID, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        // Here you could add more business logic if needed before calling the repository.
        // For example, checking user permissions, validating data, etc.
        // For now, it directly calls the repository.
        videogameRepository.updateFavoriteStatus(forVideogameId: videogameId, isFavorite: isFavorite, completion: completion)
    }
}

