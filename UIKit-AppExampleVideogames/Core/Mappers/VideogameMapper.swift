//
//  VideogameMapper.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//  Updated by AI on 23/5/25 for raw data mapping and complete UUID removal from CoreData.
//

import Foundation
import CoreData

/// `VideogameMapper` is responsible for converting videogame data.
struct VideogameMapper {

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]
        return formatter
    }()

    /// Maps a raw data dictionary (e.g., from JSON) to a `VideogameEntity`.
    /// `VideogameEntity.uuid` will be `nil` as it's not sourced from API.
    static func rawDataToEntity(rawData: [String: Any]) -> VideogameEntity? {
        guard let title = rawData["title"] as? String,
              let descriptionText = rawData["description"] as? String,
              let releaseDateString = rawData["releaseYear"] as? String,
              let developerData = rawData["developer"] as? [String: Any],
              let developerEntity = DeveloperMapper.rawDataToEntity(rawData: developerData),
              let platformStrings = rawData["platforms"] as? [String],
              let logo = rawData["logo"] as? String,
              let screenshotIdentifiers = rawData["screenshotIdentifiers"] as? [String]
        else {
            print("⚠️ VideogameMapper: Could not map rawData to VideogameEntity. Missing or invalid required fields. Data: \(rawData)")
            return nil
        }

        let platforms: [Platform] = platformStrings.compactMap { Platform(fromString: $0) }

        return VideogameEntity(
            id: title, // Business key
            uuid: nil, // VideogameEntity.uuid is not sourced from API
            title: title,
            descriptionText: descriptionText,
            releaseDateString: releaseDateString,
            developer: developerEntity,
            platforms: platforms,
            logo: logo,
            screenshotIdentifiers: screenshotIdentifiers,
            isFavorite: false
        )
    }

    /// Maps a `Videogame` (CoreData NSManagedObject) to a `VideogameEntity`.
    /// `VideogameEntity.id` is derived from `Videogame.title`.
    /// `VideogameEntity.uuid` is set to `nil` as `Videogame` MO no longer has `uuid`.
    static func managedObjectToEntity(_ managedObject: Videogame, mapDeveloper: Bool = true) -> VideogameEntity {
        var developerEntity: DeveloperEntity? = nil
        if mapDeveloper, let devMO = managedObject.developer {
            developerEntity = DeveloperMapper.managedObjectToEntity(devMO)
        }
        let finalDeveloperEntity = developerEntity ?? DeveloperEntity(id: "unknown_dev_name", name: "Unknown Developer", logo: "missing_logo", website: nil)

        var platformEntities: [Platform] = []
        if let platformStrings = managedObject.platforms {
            platformEntities = platformStrings.compactMap { Platform(fromString: $0) }
        }
        
        let releaseDateStr: String
        if let date = managedObject.releaseYear {
            releaseDateStr = iso8601Formatter.string(from: date)
        } else {
            releaseDateStr = "N/A"
        }

        // VideogameEntity.id is the business key (title).
        // Fallback if title is nil, using a timestamp for some uniqueness, though not ideal for a business key.
        let entityId = managedObject.title ?? "MISSING_TITLE_ID_\(Int(Date().timeIntervalSince1970))"

        return VideogameEntity(
            id: entityId,
            uuid: nil, // Videogame MO no longer has uuid, so entity's uuid is nil from this source
            title: managedObject.title ?? "Unknown Title",
            descriptionText: managedObject.gameDescription ?? "",
            releaseDateString: releaseDateStr,
            developer: finalDeveloperEntity,
            platforms: platformEntities,
            logo: managedObject.logo ?? "missing_logo",
            screenshotIdentifiers: managedObject.screenshots ?? [],
            isFavorite: managedObject.isFavorite
        )
    }

    /// Populates a `Videogame` (CoreData NSManagedObject) with data from a `VideogameEntity`.
    /// Finds existing MO by `title` (which is `VideogameEntity.id`) or creates a new one.
    /// `Videogame` MO no longer has a `uuid` attribute. The `VideogameEntity.uuid` is not used to populate the MO.
    static func entityToManagedObject(entity: VideogameEntity, in context: NSManagedObjectContext) throws -> Videogame {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", entity.id)

        let videogameMO: Videogame
        if let existingVideogame = try? context.fetch(fetchRequest).first {
            videogameMO = existingVideogame
        } else {
            videogameMO = Videogame(context: context)
            videogameMO.title = entity.title // Set title for new MO
        }
        
        // Update properties
        videogameMO.title = entity.title
        videogameMO.gameDescription = entity.descriptionText
        
        if let date = iso8601Formatter.date(from: entity.releaseDateString) {
            videogameMO.releaseYear = date
        } else {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            if let yearOnlyDate = yearFormatter.date(from: entity.releaseDateString) {
                videogameMO.releaseYear = yearOnlyDate
            } else {
                print("⚠️ Warning: Could not parse releaseDateString '\(entity.releaseDateString)' to Date for Videogame MO: \(entity.title)")
                videogameMO.releaseYear = nil
            }
        }
        
        videogameMO.logo = entity.logo
        videogameMO.screenshots = entity.screenshotIdentifiers
        videogameMO.isFavorite = entity.isFavorite ?? false
        videogameMO.developer = DeveloperMapper.entityToManagedObject(entity: entity.developer, in: context)
        videogameMO.platforms = entity.platforms.map { $0.rawValue }
        
        return videogameMO
    }
}
