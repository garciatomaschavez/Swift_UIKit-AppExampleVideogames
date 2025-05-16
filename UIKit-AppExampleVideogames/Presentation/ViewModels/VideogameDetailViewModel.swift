//
//  VideogameDetailViewModel.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import UIKit // For UIImage if you decide to pass actual images, though names are often better

/// Represents the detailed view of a videogame, ready for display.
/// Data is formatted and prepared by a Presenter.
struct VideogameDetailViewModel: Identifiable {
    let id: UUID
    let name: String                     // e.g., "Grand Theft Auto V"
    let gameLogoImageName: String?       // Asset name for the game's main logo (e.g., "gtav_logo")
    let developerName: String?           // e.g., "Rockstar Games"
    let developerLogoImageName: String?  // Asset name for the developer's logo (e.g., "rockstar_logo")
    let developerWebsiteURL: URL?
    let releaseDateText: String?         // e.g., "Released: Sep 17, 2013"
    let description: String?
    let platformIconNames: [String]?     // Asset names for platform logos (e.g., ["playstation", "pc"])
    let screenshotImageNames: [String]?  // Asset names for carousel screenshots (e.g., ["gtav_ss1", "gtav_ss2"])
    let isFavorite: Bool                 // To potentially show a favorite button in the detail view

    // Initializer
    init(id: UUID,
         name: String,
         gameLogoImageName: String?,
         developerName: String?,
         developerLogoImageName: String?,
         developerWebsiteURL: URL?,
         releaseDateText: String?,
         description: String?,
         platformIconNames: [String]?,
         screenshotImageNames: [String]?,
         isFavorite: Bool) {
        self.id = id
        self.name = name
        self.gameLogoImageName = gameLogoImageName
        self.developerName = developerName
        self.developerLogoImageName = developerLogoImageName
        self.developerWebsiteURL = developerWebsiteURL
        self.releaseDateText = releaseDateText
        self.description = description
        self.platformIconNames = platformIconNames
        self.screenshotImageNames = screenshotImageNames
        self.isFavorite = isFavorite
    }
}

// Example of how a Presenter might create this from a VideogameEntity
extension VideogameDetailViewModel {
    static func from(entity: VideogameEntity) -> VideogameDetailViewModel {
        let dateFormatter = DateFormatter()
        // More detailed date format for detail view
        dateFormatter.dateFormat = "\(NSLocalizedString("VideogameViewModel_dateFormatter", comment: "."))"

        let releaseText: String?
        if let date = entity.releaseDate {
            releaseText = "\(NSLocalizedString("VideogameViewModel_releasedText", comment: ".")): \(dateFormatter.string(from: date))"
        } else {
            releaseText = "\(NSLocalizedString("VideogameViewModel_notReleasedText", comment: "."))"
        }
        
        let platformIcons: [String]? = entity.platforms?.map { $0.imageName } // Get platform logo names
        
        var websiteURL: URL? = nil
        // Assuming DeveloperEntity might have a website string
        // For now, this is not in DeveloperEntity, so it would be nil or fetched differently.
        // if let websiteString = entity.developer?.website { websiteURL = URL(string: websiteString) }


        return VideogameDetailViewModel(
            id: entity.id,
            name: entity.name,
            gameLogoImageName: entity.imageName, // From VideogameEntity
            developerName: entity.developer?.name,
            developerLogoImageName: entity.developer?.logoImageName, // From DeveloperEntity
            developerWebsiteURL: websiteURL, // Placeholder, needs DeveloperEntity to have website
            releaseDateText: releaseText,
            description: entity.gameDescription,
            platformIconNames: platformIcons,
            screenshotImageNames: entity.screenshotImageNames, // From VideogameEntity
            isFavorite: entity.isFavorite
        )
    }
}
