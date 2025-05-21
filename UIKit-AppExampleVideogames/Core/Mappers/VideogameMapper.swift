//
//  VideogameMapper.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
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

    /// Maps an `APIVideogameDTO` to a `VideogameEntity`.
    /// `VideogameEntity.id` will be the videogame's title.
    /// `VideogameEntity.uuid` will be nil as it's not from the API DTO.
    static func dtoToEntity(_ dto: APIVideogameDTO) -> VideogameEntity {
        let developerEntity = DeveloperMapper.dtoToEntity(dto.developer)
        
        let platformEntities: [Platform] = dto.platforms.compactMap { platformString in
            let jsonData = Data("\"\(platformString)\"".utf8)
            return try? JSONDecoder().decode(Platform.self, from: jsonData)
        }

        return VideogameEntity(
            id: dto.title, // Entity's business key ID is the title
            uuid: nil,     // UUID is not present in the DTO
            title: dto.title,
            descriptionText: dto.description,
            releaseDateString: dto.releaseYear,
            developer: developerEntity,
            platforms: platformEntities,
            logo: dto.logo,
            screenshotIdentifiers: dto.screenshotIdentifiers,
            isFavorite: false
        )
    }

    /// Maps a `Videogame` (CoreData NSManagedObject) to a `VideogameEntity`.
    /// `VideogameEntity.id` is derived from `Videogame.title`.
    /// `VideogameEntity.uuid` is populated from `Videogame.uuid`.
    static func managedObjectToEntity(_ managedObject: Videogame, mapDeveloper: Bool = true) -> VideogameEntity {
        var developerEntity: DeveloperEntity? = nil
        if mapDeveloper, let devMO = managedObject.developer {
            developerEntity = DeveloperMapper.managedObjectToEntity(devMO)
        }
        let finalDeveloperEntity = developerEntity ?? DeveloperEntity(id: "unknown_dev_name", name: "Unknown Developer", logo: "missing_logo", website: nil)

        var platformEntities: [Platform] = []
        if let platformStrings = managedObject.platforms { // CoreData: platforms: [String]?
            platformEntities = platformStrings.compactMap { rawValue in
                let jsonData = Data("\"\(rawValue)\"".utf8)
                return try? JSONDecoder().decode(Platform.self, from: jsonData)
            }
        }
        
        let releaseDateStr: String
        if let date = managedObject.releaseYear { // CoreData: releaseYear: Date?
            releaseDateStr = iso8601Formatter.string(from: date)
        } else {
            releaseDateStr = "N/A"
        }

        // Videogame.uuid is UUID?, VideogameEntity.uuid is UUID?
        // Videogame.title is String?, VideogameEntity.id is String (business key)

        return VideogameEntity(
            id: managedObject.title ?? (managedObject.uuid?.uuidString ?? UUID().uuidString), // Use title as Entity ID, fallback to UUID string if title is nil
            uuid: managedObject.uuid, // Populate Entity's uuid from CoreData's uuid
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
    /// Ensures `Videogame.uuid` is set (either existing or new).
    static func entityToManagedObject(entity: VideogameEntity, in context: NSManagedObjectContext) throws -> Videogame {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        // Entity.id is the videogame's title (business key)
        fetchRequest.predicate = NSPredicate(format: "title == %@", entity.id)

        let videogameMO: Videogame
        if let existingVideogame = try? context.fetch(fetchRequest).first {
            videogameMO = existingVideogame
            // Ensure UUID is consistent if we found an existing one
            if videogameMO.uuid == nil && entity.uuid != nil {
                 videogameMO.uuid = entity.uuid // Should ideally already match or be set
            } else if videogameMO.uuid == nil { // If existing MO somehow has no UUID
                videogameMO.uuid = UUID()
            }
        } else {
            videogameMO = Videogame(context: context)
            // If entity has a UUID (e.g. from a previous fetch), use it. Otherwise, generate new.
            videogameMO.uuid = entity.uuid ?? UUID()
            videogameMO.title = entity.title
        }
        
        // Update properties
        videogameMO.title = entity.title // Keep title consistent
        videogameMO.gameDescription = entity.descriptionText
        
        if let date = iso8601Formatter.date(from: entity.releaseDateString) {
            videogameMO.releaseYear = date
        } else {
            print("⚠️ Warning: Could not parse releaseDateString '\(entity.releaseDateString)' to Date for Videogame: \(entity.title)")
            videogameMO.releaseYear = nil
        }
        
        videogameMO.logo = entity.logo
        videogameMO.screenshots = entity.screenshotIdentifiers
        videogameMO.isFavorite = entity.isFavorite ?? false
        videogameMO.developer = DeveloperMapper.entityToManagedObject(entity: entity.developer, in: context)
        videogameMO.platforms = entity.platforms.map { $0.rawValue }
        
        return videogameMO
    }
}
