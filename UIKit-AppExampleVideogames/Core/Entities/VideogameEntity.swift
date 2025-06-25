//
//  VideogameEntity.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

/// Represents a videogame.
/// Conforms to `Identifiable` (using 'id' which is 'title').
struct VideogameEntity: Identifiable {
    /// The unique business key identifier for the videogame, typically its title.
    let id: String
    let title: String
    let descriptionText: String
    let releaseDateString: String // Stores the date string from API (e.g., "2009-05-17T00:00:00Z")
    let developer: DeveloperEntity
    let platforms: [Platform]
    let logo: String
    let screenshotIdentifiers: [String]
    var isFavorite: Bool? = false

    // Initializer for creating entities, e.g., from Mappers, CoreData, or for testing
    init(id: String, title: String, descriptionText: String, releaseDateString: String, developer: DeveloperEntity, platforms: [Platform], logo: String, screenshotIdentifiers: [String], isFavorite: Bool? = false) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.releaseDateString = releaseDateString
        self.developer = developer
        self.platforms = platforms
        self.logo = logo
        self.screenshotIdentifiers = screenshotIdentifiers
        self.isFavorite = isFavorite
    }
}
