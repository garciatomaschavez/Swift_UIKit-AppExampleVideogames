//
//  VideogameDetailViewModel.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//

import Foundation
import UIKit

/// Represents the detailed view of a videogame, ready for display.
/// Data is formatted and prepared by a Presenter.
struct VideogameDetailViewModel: Identifiable {
    /// The database unique identifier (maps to CoreData's Videogame.uuid). Optional because an entity might not have it if never saved.
    let id: UUID?
    let name: String                     // e.g., "Grand Theft Auto V"
    let gameLogoImageName: String?       // Asset name for the game's main logo (e.g., "gtav_logo")
    let developerName: String?           // e.g., "Rockstar Games"
    let developerLogoImageName: String?  // Asset name for the developer's logo (e.g., "rockstar_logo")
    let developerWebsiteURL: URL?
    let releaseDateText: String?         // e.g., "Released: September 17, 2013"
    let description: String?
    let platformIconNames: [String]?     // Asset names for platform logos (e.g., ["playstation_icon", "pc_icon"])
    let screenshotImageIdentifiers: [String]?  // Raw identifiers for carousel screenshots (e.g., ["1", "2", "3"])
                                          // The view will prepend the game-specific path if needed.
    let isFavorite: Bool                 // To show favorite status in the detail view

    // Initializer matching the properties used in VideogameDetailPresenter
    init(
        id: UUID?,
        name: String,
        gameLogoImageName: String?,
        developerName: String?,
        developerLogoImageName: String?,
        developerWebsiteURL: URL?,
        releaseDateText: String?,
        description: String?,
        platformIconNames: [String]?,
        screenshotImageIdentifiers: [String]?, // Renamed from screenshotImageNames to screenshotImageIdentifiers
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
