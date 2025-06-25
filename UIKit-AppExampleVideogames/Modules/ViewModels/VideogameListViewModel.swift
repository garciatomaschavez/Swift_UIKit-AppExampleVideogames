//
//  VideogameListViewModel.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//  Updated by AI on 23/05/25 for ID type change.
//

import Foundation

/// Represents a videogame item ready for display in the list (e.g., in a CollectionViewCell).
struct VideogameListViewModel: Identifiable, Equatable {
    /// The database unique identifier (maps to CoreData's Videogame.uuid, now String).
    /// Used by Identifiable for diffing in UI lists.
    let id: String
    /// The business key identifier (maps to VideogameEntity.id, typically the title).
    /// Used for actions like fetching details or toggling favorites.
    let businessKeyId: String
    
    let name: String // Game's title
    let developerNameText: String?
    let developerLogoImageName: String? // Asset name for developer logo
    let releaseDateText: String?
    let mainImageName: String? // Asset name for the game's primary logo (for the cell)
    let platformIconNames: [String]? // Asset names for platform icons
    let isFavorite: Bool

    init(
        id: String, // Changed from UUID
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
