//
//  VideogameEntity.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

// Assuming Platform enum is accessible here, e.g., moved to Domain/Entities or Domain/Enums
// If Platform.swift is in Data/Enums, you might need to move it or duplicate it
// in the Domain layer to maintain the dependency rule (Domain shouldn't know about Data).
// For now, we'll assume it's available.

/// Represents a videogame in the application's domain.
/// This is a plain Swift struct, independent of any specific framework (like Core Data or UIKit).
public struct VideogameEntity: Identifiable, Equatable {
    /// The unique identifier for the videogame.
    public let id: UUID

    /// The name of the videogame.
    public let name: String

    /// A description of the videogame.
    public let gameDescription: String?

    /// The release date of the videogame.
    public let releaseDate: Date?

    /// The developer of the videogame.
    /// This will be an instance of `DeveloperEntity`.
    public let developer: DeveloperEntity?

    /// A list of platforms the videogame is available on.
    /// Uses the `Platform` enum defined elsewhere in the domain.
    public let platforms: [Platform]?

    /// The name of the main image asset for the videogame (e.g., "gtav_logo").
    /// This would typically be used to load an image from an asset catalog or a URL.
    public let imageName: String?

    /// A list of names for screenshot image assets.
    public let screenshotImageNames: [String]?
    
    /// A flag indicating whether the videogame is marked as a favorite by the user.
    /// This is an example of a business rule that might live with the entity or be managed by a use case.
    public var isFavorite: Bool // Example of a mutable property if needed

    /// Initializes a new VideogameEntity.
    ///
    /// - Parameters:
    ///   - id: The unique identifier. Defaults to a new UUID.
    ///   - name: The name of the game.
    ///   - gameDescription: The description of the game.
    ///   - releaseDate: The release date.
    ///   - developer: The developer entity.
    ///   - platforms: An array of platforms.
    ///   - imageName: The name of the primary image.
    ///   - screenshotImageNames: An array of screenshot image names.
    ///   - isFavorite: Whether the game is a favorite. Defaults to false.
    public init(
        id: UUID = UUID(),
        name: String,
        gameDescription: String?,
        releaseDate: Date?,
        developer: DeveloperEntity?,
        platforms: [Platform]?,
        imageName: String?,
        screenshotImageNames: [String]?,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.gameDescription = gameDescription
        self.releaseDate = releaseDate
        self.developer = developer
        self.platforms = platforms
        self.imageName = imageName
        self.screenshotImageNames = screenshotImageNames
        self.isFavorite = isFavorite
    }
}

// MARK: - Equatable Conformance
// It's good practice for entities to be equatable, especially for testing and state management.
public func == (lhs: VideogameEntity, rhs: VideogameEntity) -> Bool {
    return lhs.id == rhs.id &&
           lhs.name == rhs.name &&
           lhs.gameDescription == rhs.gameDescription &&
           lhs.releaseDate == rhs.releaseDate &&
           lhs.developer == rhs.developer &&
           lhs.platforms == rhs.platforms &&
           lhs.imageName == rhs.imageName &&
           lhs.screenshotImageNames == rhs.screenshotImageNames &&
           lhs.isFavorite == rhs.isFavorite
}
