//
//  Videogame+CoreDataProperties.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//
//

import Foundation
import CoreData


extension Videogame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Videogame> {
        return NSFetchRequest<Videogame>(entityName: "Videogame")
    }

    @NSManaged public var gameDescription: String?
    @NSManaged public var logo: String?
    @NSManaged public var platforms: [String]?
    @NSManaged public var releaseYear: Date?
    @NSManaged public var title: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var screenshots: [String]?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var developer: Developer?

}

extension Videogame : Identifiable {

}
