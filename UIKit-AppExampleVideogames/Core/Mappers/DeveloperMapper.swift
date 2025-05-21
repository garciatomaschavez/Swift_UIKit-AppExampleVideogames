//
//  DeveloperMapper.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation
import CoreData

/// `DeveloperMapper` is responsible for converting developer data between different representations.
struct DeveloperMapper {

    /// Maps an `APIDeveloperDTO` to a `DeveloperEntity`.
    /// The `DeveloperEntity.id` will be the developer's name.
    static func dtoToEntity(_ dto: APIDeveloperDTO) -> DeveloperEntity {
        return DeveloperEntity(
            id: dto.name, // Entity's ID is the name
            name: dto.name,
            logo: dto.logo,
            website: dto.website
        )
    }

    /// Maps a `Developer` (CoreData NSManagedObject) to a `DeveloperEntity`.
    /// `DeveloperEntity.id` is derived from `Developer.name`.
    /// `Developer.uuid` is the CoreData primary key but not directly used as Entity's `id`.
    static func managedObjectToEntity(_ managedObject: Developer) -> DeveloperEntity {
        return DeveloperEntity(
            id: managedObject.name ?? UUID().uuidString, // Use name as Entity ID, fallback if name is nil
            name: managedObject.name ?? "Unknown Developer",
            logo: managedObject.logo ?? "missing_logo",
            website: managedObject.website
        )
    }

    /// Populates a `Developer` (CoreData NSManagedObject) with data from a `DeveloperEntity`.
    /// Finds existing MO by `name` (which is `DeveloperEntity.id`) or creates a new one.
    /// Ensures `Developer.uuid` is set for new objects.
    static func entityToManagedObject(entity: DeveloperEntity, in context: NSManagedObjectContext) -> Developer {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        // Entity.id is the developer's name
        fetchRequest.predicate = NSPredicate(format: "name == %@", entity.id)

        let developerMO: Developer
        if let existingDeveloper = try? context.fetch(fetchRequest).first {
            developerMO = existingDeveloper
        } else {
            developerMO = Developer(context: context)
            developerMO.uuid = UUID() // Set UUID for new CoreData objects
            developerMO.name = entity.name // Name is the primary way to identify for mapping
        }
        
        // Update properties
        // developerMO.name = entity.name // Already set for new, or matches for existing
        developerMO.logo = entity.logo
        developerMO.website = entity.website
        
        return developerMO
    }
}
