//
//  VideogameEntity.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// Represents a videogame.
/// Conforms to `Identifiable` (using 'id' which is 'title') and `Decodable`.
struct VideogameEntity: Identifiable, Decodable {
    /// The unique business key identifier for the videogame, derived from its title from the API.
    let id: String
    /// The database unique identifier (maps to CoreData's Videogame.uuid).
    /// This is optional because an entity freshly decoded from API DTO might not have a DB UUID yet.
    /// However, for creating a VideogameViewModel, this UUID will be required.
    var uuid: UUID?
    
    let title: String
    let descriptionText: String // Corresponds to API's "description"
    let releaseDateString: String // Stores the date string from API (e.g., "2009-05-17T00:00:00Z")
    let developer: DeveloperEntity
    let platforms: [Platform]
    let logo: String
    let screenshotIdentifiers: [String] // Corresponds to API's "screenshotIdentifiers"
    var isFavorite: Bool? = false

    enum CodingKeys: String, CodingKey {
        case title
        case descriptionText = "description"
        case releaseDateString = "releaseYear" // API field is "releaseYear", but it's a date string
        case developer
        case platforms
        case logo
        case screenshotIdentifiers
        // 'uuid' and 'isFavorite' are not decoded from the primary API DTO.
        // 'uuid' is populated from CoreData. 'isFavorite' is managed locally.
    }

    // Decoder for API data (DTO -> Entity)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        descriptionText = try container.decode(String.self, forKey: .descriptionText)
        releaseDateString = try container.decode(String.self, forKey: .releaseDateString)
        developer = try container.decode(DeveloperEntity.self, forKey: .developer)
        platforms = try container.decode([Platform].self, forKey: .platforms)
        logo = try container.decode(String.self, forKey: .logo)
        screenshotIdentifiers = try container.decode([String].self, forKey: .screenshotIdentifiers)
        
        id = title // Business key
        uuid = nil // Not available from API DTO directly
        isFavorite = false
    }

    // Initializer for creating entities, e.g., from CoreData or for testing
    init(id: String, uuid: UUID?, title: String, descriptionText: String, releaseDateString: String, developer: DeveloperEntity, platforms: [Platform], logo: String, screenshotIdentifiers: [String], isFavorite: Bool? = false) {
        self.id = id
        self.uuid = uuid
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

