//
//  GetAllDevelopersUseCase.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// A use case responsible for fetching all developer entities.
public class GetAllDevelopersUseCase {
    private let developerRepository: DeveloperRepositoryProtocol

    public init(developerRepository: DeveloperRepositoryProtocol) {
        self.developerRepository = developerRepository
    }

    /// Executes the use case to fetch all developers.
    /// - Parameter completion: A closure with the result: an array of `DeveloperEntity` or an `Error`.
    public func execute(completion: @escaping (Result<[DeveloperEntity], Error>) -> Void) {
        developerRepository.getAllDevelopers(completion: completion)
    }
}
