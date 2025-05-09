//
//  DeveloperMapper.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation
import CoreData // Required to interact with NSManagedObject

/// A utility responsible for mapping between `Developer` (Core Data NSManagedObject)
/// and `DeveloperEntity` (Domain model).
struct DeveloperMapper {

    /// Maps a `Developer` (Core Data NSManagedObject) to a `DeveloperEntity`.
    /// - Parameter managedObject: The Core Data `Developer` object.
    /// - Returns: A `DeveloperEntity` instance, or `nil` if essential data (like ID or name) is missing.
    static func toEntity(managedObject: Developer) -> DeveloperEntity? {
        // Assuming your Core Data 'Developer' entity has 'uuid' (UUID) and 'name_dev' (String) attributes
        // and 'logoName_dev' (String?) for the image name.
        // PLEASE REPLACE 'uuid', 'name_dev', 'logoName_dev' WITH YOUR ACTUAL ATTRIBUTE NAMES from Developer+CoreDataProperties.swift

        guard let id = managedObject.value(forKey: "uuid") as? UUID,
              let name = managedObject.value(forKey: "name") as? String else {
            print("Warning: Could not map Developer NSManagedObject to DeveloperEntity due to missing or incorrect 'uuid' or 'name'. Check attribute names in Core Data model.")
            return nil
        }

        let logoImageName = managedObject.value(forKey: "logo") as? String

        return DeveloperEntity(
            id: id,
            name: name,
            logoImageName: logoImageName
        )
    }

    /// Populates a `Developer` (Core Data NSManagedObject) with data from a `DeveloperEntity`.
    /// - Parameters:
    ///   - entity: The `DeveloperEntity` containing the data.
    ///   - context: The `NSManagedObjectContext` for the operation.
    ///   - existingManagedObject: An optional existing `Developer` MO to update.
    /// - Returns: The populated `Developer` NSManagedObject.
    static func toManagedObject(
        entity: DeveloperEntity,
        in context: NSManagedObjectContext,
        existingManagedObject: Developer? = nil
    ) -> Developer {
        let developerMO = existingManagedObject ?? Developer(context: context)

        // PLEASE REPLACE 'uuid', 'name_dev', 'logoName_dev' WITH YOUR ACTUAL ATTRIBUTE NAMES
        developerMO.setValue(entity.id, forKey: "uuid")
        developerMO.setValue(entity.name, forKey: "name")
        developerMO.setValue(entity.logoImageName, forKey: "logo")
        
        // Note: We are not mapping videogames back from DeveloperEntity to Developer MO here.
        // The relationship is typically owned and set from the Videogame side.

        return developerMO
    }
}
