//
//  VideogameDetailViewModel.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//  Updated by AI on 23/05/25 for ID type change.
//

import Foundation

/// Represents the detailed view of a videogame, ready for display.
/// Data is formatted and prepared by a Presenter.
struct VideogameDetailViewModel: Identifiable {
    /// The database unique identifier (maps to CoreData's Videogame.uuid, now String). Optional.
    let id: String? // Changed from UUID?
    let name: String
    let gameLogoImageName: String?
    let developerName: String?
    let developerLogoImageName: String?
    let developerWebsiteURL: URL? // Keep as URL for now, Presenter handles creation
    let releaseDateText: String?
    let description: String?
    let platformIconNames: [String]?
    let screenshotImageIdentifiers: [String]?
    let isFavorite: Bool

    init(
        id: String?, // Changed from UUID?
        name: String,
        gameLogoImageName: String?,
        developerName: String?,
        developerLogoImageName: String?,
        developerWebsiteURL: URL?,
        releaseDateText: String?,
        description: String?,
        platformIconNames: [String]?,
        screenshotImageIdentifiers: [String]?,
        isFavorite: Bool
    ) {
        self.id = id
        self.name = name
        self.gameLogoImageName = gameLogoImageName
        self.developerName = developerName
        self.developerLogoImageName = developerLogoImageName
        self.developerWebsiteURL = developerWebsiteURL
        self.releaseDateText = releaseDateText
        self.description = description
        self.platformIconNames = platformIconNames
        self.screenshotImageIdentifiers = screenshotImageIdentifiers
        self.isFavorite = isFavorite
    }
}
