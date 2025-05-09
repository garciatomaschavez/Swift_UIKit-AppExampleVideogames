//
//  VideogameMapper.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation
import CoreData

/// A utility responsible for mapping between `Videogame` (Core Data NSManagedObject)
/// and `VideogameEntity` (Domain model).
struct VideogameMapper {

    /// Maps a `Videogame` (Core Data NSManagedObject) to a `VideogameEntity`.
    /// - Parameter managedObject: The Core Data `Videogame` object.
    /// - Returns: A `VideogameEntity` instance, or `nil` if essential data is missing.
    /// - Important: Assumes `Videogame` MO has `uuid: UUID?`, `title: String?`,
    ///              `screenshots: [String]?` (or Transformable), and `isFavorite: Bool`.
    static func toEntity(managedObject: Videogame) -> VideogameEntity? {
        // Ensure your Core Data 'Videogame' entity has a 'uuid' attribute of type UUID
        // and 'title' attribute for the name.
        guard let id = managedObject.uuid, // Use direct property access
              let name = managedObject.title else { // 'title' from Core Data maps to 'name' in Entity
            print("Warning: Could not map Videogame NSManagedObject to VideogameEntity. 'uuid' or 'title' attribute might be missing or nil.")
            return nil
        }

        var developerEntity: DeveloperEntity? = nil
        if let managedDeveloper = managedObject.developer {
            // DeveloperMapper.toEntity will handle mapping the Developer
            developerEntity = DeveloperMapper.toEntity(managedObject: managedDeveloper)
        }

        var platformEntities: [Platform]? = nil
        if let platformStrings = managedObject.platforms { // This is [String]? from Core Data
            platformEntities = platformStrings.compactMap { platformString in
                // Attempt to create Platform enum. If it fails, print a warning.
                let platform = Platform(rawValue: platformString)
                if platform == nil {
                    print("Warning: Could not map platform string '\(platformString)' to Platform enum for game '\(name)'. Check if '\(platformString)' exists as a rawValue in Platform.swift or if Firebase data needs correction.")
                }
                return platform
            }
        }
        
        // 'screenshots' from Core Data should be [String]? (e.g., ["minecraft/1", "minecraft/2"])
        let screenshotAssetNames: [String]? = managedObject.screenshots

        return VideogameEntity(
            id: id,
            name: name, // Mapped from 'title'
            gameDescription: managedObject.gameDescription, // Direct mapping
            releaseDate: managedObject.releaseYear, // 'releaseYear' from Core Data maps to 'releaseDate'
            developer: developerEntity,
            platforms: platformEntities,
            imageName: managedObject.logo, // This is the base name like "minecraft", "lol"
            screenshotImageNames: screenshotAssetNames, // These are like "minecraft/1", "lol/2"
            isFavorite: managedObject.isFavorite
        )
    }

    /// Populates a `Videogame` (Core Data NSManagedObject) with data from a `VideogameEntity`.
    /// - Parameters:
    ///   - entity: The `VideogameEntity` containing the data.
    ///   - context: The `NSManagedObjectContext` for operations.
    ///   - existingManagedObject: An optional existing `Videogame` MO to update.
    /// - Returns: The populated `Videogame` NSManagedObject.
    /// - Important: Assumes `Videogame` MO has necessary attributes like `uuid`, `title`, etc.
    static func toManagedObject(
        entity: VideogameEntity,
        in context: NSManagedObjectContext,
        existingManagedObject: Videogame? = nil
    ) -> Videogame {
        let videogameMO = existingManagedObject ?? Videogame(context: context)

        videogameMO.uuid = entity.id
        videogameMO.title = entity.name // 'name' from Entity maps to 'title' in Core Data
        videogameMO.gameDescription = entity.gameDescription
        videogameMO.releaseYear = entity.releaseDate // 'releaseDate' from Entity maps to 'releaseYear'
        videogameMO.logo = entity.imageName // 'imageName' from Entity maps to 'logo'

        if let platformEntities = entity.platforms {
            videogameMO.platforms = platformEntities.map { $0.rawValue }
        } else {
            videogameMO.platforms = nil
        }

        // Stores ["minecraft/1", "minecraft/2"] directly
        videogameMO.screenshots = entity.screenshotImageNames
        
        videogameMO.isFavorite = entity.isFavorite

        // Map developer
        if let devEntity = entity.developer {
            let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", devEntity.id as CVarArg)
            do {
                let results = try context.fetch(fetchRequest)
                if let existingDevMO = results.first {
                    videogameMO.developer = existingDevMO
                } else {
                    let newDevMO = DeveloperMapper.toManagedObject(entity: devEntity, in: context)
                    videogameMO.developer = newDevMO
                }
            } catch {
                print("Error fetching developer with id \(devEntity.id) for Videogame: \(error). Creating new developer.")
                let newDevMO = DeveloperMapper.toManagedObject(entity: devEntity, in: context)
                videogameMO.developer = newDevMO
            }
        } else {
            videogameMO.developer = nil
        }
        
        return videogameMO
    }
}
