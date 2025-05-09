//
//  DeveloperEntity.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// Represents a game developer in the application's domain.
/// This is a plain Swift struct, independent of any specific framework.
public struct DeveloperEntity: Identifiable, Equatable {
    /// The unique identifier for the developer.
    public let id: UUID

    /// The name of the developer.
    public let name: String

    /// The name of the logo image asset for the developer (e.g., "rockstar_logo").
    /// This would typically be used to load an image from an asset catalog or a URL.
    public let logoImageName: String?
    
    // Note: We are not including a list of `VideogameEntity` here.
    // While a developer has many games, in Clean Architecture, entities are often kept simple.
    // Fetching all games for a developer would typically be a Use Case's responsibility,
    // which would query a repository. This helps avoid circular dependencies and keeps entities lightweight.

    /// Initializes a new DeveloperEntity.
    ///
    /// - Parameters:
    ///   - id: The unique identifier. Defaults to a new UUID.
    ///   - name: The name of the developer.
    ///   - logoImageName: The name of the logo image.
    public init(
        id: UUID = UUID(),
        name: String,
        logoImageName: String?
    ) {
        self.id = id
        self.name = name
        self.logoImageName = logoImageName
    }
}

// MARK: - Equatable Conformance
public func == (lhs: DeveloperEntity, rhs: DeveloperEntity) -> Bool {
    return lhs.id == rhs.id &&
           lhs.name == rhs.name &&
           lhs.logoImageName == rhs.logoImageName
}

