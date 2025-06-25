//
//  Developer+CoreDataProperties.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/5/25.
//
//

import Foundation
import CoreData


extension Developer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Developer> {
        return NSFetchRequest<Developer>(entityName: "Developer")
    }

    @NSManaged public var logo: String?
    @NSManaged public var name: String?
    @NSManaged public var website: String?
    @NSManaged public var videogames: NSSet?

}

// MARK: Generated accessors for videogames
extension Developer {

    @objc(addVideogamesObject:)
    @NSManaged public func addToVideogames(_ value: Videogame)

    @objc(removeVideogamesObject:)
    @NSManaged public func removeFromVideogames(_ value: Videogame)

    @objc(addVideogames:)
    @NSManaged public func addToVideogames(_ values: NSSet)

    @objc(removeVideogames:)
    @NSManaged public func removeFromVideogames(_ values: NSSet)

}

extension Developer : Identifiable {

}
