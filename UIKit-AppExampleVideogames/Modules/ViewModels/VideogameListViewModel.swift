//
//  VideogameListViewModel.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//

import Foundation
import UIKit // For UUID

/// Represents a videogame item ready for display in the list (e.g., in a CollectionViewCell).
struct VideogameListViewModel: Identifiable, Equatable {
    let id: UUID // This is the VideogameEntity.uuid (database UUID), used by Identifiable for diffing
    let businessKeyId: String // This is the VideogameEntity.id (title/business key), used for actions
    
    let name: String // Game's title
    let developerNameText: String?
    let developerLogoImageName: String? // Asset name for developer logo
    let releaseDateText: String?
    let mainImageName: String? // Asset name for the game's primary logo (for the cell)
    let platformIconNames: [String]? // Asset names for platform icons
    let isFavorite: Bool

    init(
        id: UUID,
        businessKeyId: String,
        name: String,
        developerNameText: String?,
        developerLogoImageName: String?,
        releaseDateText: String?,
        mainImageName: String?,
        platformIconNames: [String]?,
        isFavorite: Bool
    ) {
        self.id = id
        self.businessKeyId = businessKeyId
        self.name = name
        self.developerNameText = developerNameText
        self.developerLogoImageName = developerLogoImageName
        self.releaseDateText = releaseDateText
        self.mainImageName = mainImageName
        self.platformIconNames = platformIconNames
        self.isFavorite = isFavorite
    }
}
