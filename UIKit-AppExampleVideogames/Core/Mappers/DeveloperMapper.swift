//
//  DeveloperMapper.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//  Updated by AI on 23/5/25 for raw data mapping and complete UUID removal from CoreData.
//

import Foundation
import CoreData

/// `DeveloperMapper` is responsible for converting developer data between different representations.
struct DeveloperMapper {

    /// Maps a raw data dictionary (e.g., from JSON) to a `DeveloperEntity`.
    /// Expects keys like "name", "logo", "website".
    /// - Parameter rawData: A dictionary representing the developer.
    /// - Returns: A `DeveloperEntity` if mapping is successful, otherwise `nil`.
    static func rawDataToEntity(rawData: [String: Any]) -> DeveloperEntity? {
        guard let name = rawData["name"] as? String,
              let logo = rawData["logo"] as? String else {
            print("⚠️ DeveloperMapper: Could not map rawData to DeveloperEntity. Missing 'name' or 'logo'. Data: \(rawData)")
            return nil
        }
        
        let website = rawData["website"] as? String
        
        // DeveloperEntity's 'id' is its name.
        return DeveloperEntity(
            id: name,
            name: name,
            logo: logo,
            website: website
        )
    }

    /// Maps a `Developer` (CoreData NSManagedObject) to a `DeveloperEntity`.
    /// `DeveloperEntity.id` is derived from `Developer.name`.
    /// `Developer` MO no longer has a `uuid` attribute.
    static func managedObjectToEntity(_ managedObject: Developer) -> DeveloperEntity {
        let developerName = managedObject.name ?? "Unknown Developer"
        // DeveloperEntity.id is the name.
        return DeveloperEntity(
            id: developerName,
            name: developerName,
            logo: managedObject.logo ?? "missing_logo",
            website: managedObject.website
        )
    }

    /// Populates a `Developer` (CoreData NSManagedObject) with data from a `DeveloperEntity`.
    /// Finds existing MO by `name` (which is `DeveloperEntity.id`) or creates a new one.
    /// `Developer` MO no longer has a `uuid` attribute.
    static func entityToManagedObject(entity: DeveloperEntity, in context: NSManagedObjectContext) -> Developer {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        // Entity.id is the developer's name
        fetchRequest.predicate = NSPredicate(format: "name == %@", entity.id)

        let developerMO: Developer
        if let existingDeveloper = try? context.fetch(fetchRequest).first {
            developerMO = existingDeveloper
        } else {
            developerMO = Developer(context: context)
            developerMO.name = entity.name // Name is the primary way to identify for mapping
        }
        
        // Update properties
        // developerMO.name = entity.name // Already set for new, or matches for existing
        developerMO.logo = entity.logo
        developerMO.website = entity.website
        
        return developerMO
    }
}
