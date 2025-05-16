//
//  VideogameViewModel.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import UIKit

/// Represents a videogame item ready for display in the UI (e.g., in a CollectionViewCell).
/// Data is formatted and prepared by a Presenter.
struct VideogameViewModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    let developerNameText: String?         // Formatted developer name, e.g., "By Rockstar Games"
    let developerLogoImageName: String?  // Asset name for the developer's logo
    let releaseDateText: String?         // Formatted release date, e.g., "Released: 2013"
    let mainImageName: String?           // Name of the image asset for the game's logo/icon in the cell
    let platformIconNames: [String]?     // Array of asset names for platform icons
    let isFavorite: Bool
    
    // Removed platformsText as platformIconNames is more suitable for the cell.
    // If you need a combined text elsewhere, it can be re-added or computed where needed.

    init(
        id: UUID,
        name: String,
        developerNameText: String?,
        developerLogoImageName: String?,
        releaseDateText: String?,
        mainImageName: String?,
        platformIconNames: [String]?,
        isFavorite: Bool
    ) {
        self.id = id
        self.name = name
        self.developerNameText = developerNameText
        self.developerLogoImageName = developerLogoImageName
        self.releaseDateText = releaseDateText
        self.mainImageName = mainImageName
        self.platformIconNames = platformIconNames
        self.isFavorite = isFavorite
    }
}

extension VideogameViewModel {
    static func from(entity: VideogameEntity) -> VideogameViewModel {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "\(NSLocalizedString("VideogameViewModel_dateFormatter", comment: "."))"
        // Format for cell display

        let releaseText: String?
        if let date = entity.releaseDate {
            releaseText = "\(NSLocalizedString("VideogameViewModel_releasedText", comment: ".")): \(dateFormatter.string(from: date))"
        } else {
            releaseText = "\(NSLocalizedString("VideogameViewModel_notReleasedText", comment: "."))"
        }

        let devNameText: String?
        if let developer = entity.developer {
            devNameText = "\(NSLocalizedString("VideogameViewModel_devNameText", comment: ".")) \(developer.name)"
        } else {
            devNameText = nil
        }
        
        // Get platform icon names directly from the Platform enum's imageName property
        let platformIcons: [String]? = entity.platforms?.map { $0.imageName }

        return VideogameViewModel(
            id: entity.id,
            name: entity.name,
            developerNameText: devNameText,
            developerLogoImageName: entity.developer?.logoImageName, // From DeveloperEntity
            releaseDateText: releaseText,
            mainImageName: entity.imageName, // This is the game's main image/logo for the cell
            platformIconNames: platformIcons,
            isFavorite: entity.isFavorite
        )
    }
}
