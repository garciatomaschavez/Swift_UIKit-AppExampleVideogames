//
//  CoreDataService.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 5/5/25.
//

import Foundation
import CoreData
import UIKit // Needed for UIApplication

class CoreDataService {

    // 1. Get the context
    private static var context: NSManagedObjectContext {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.persistentContainer.viewContext
        } else {
            // Handle the error: Unable to get context
            fatalError("Could not get context from SceneDelegate")
        }
    }
    
    // MARK: - Initialize and delete data
    
    static func insertInitialDataIfNeeded() {
             let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
             
             guard (try? context.count(for: fetchRequest)) == 0 else {
                 // Database is not empty, do not insert initial data
                 return
             }
             
             // Database is empty, insert initial data
             insertInitialData()
         }

    static private func insertInitialData() {
        // Insert Developer entities
        let mojang = saveDeveloper(name: "Mojang Studios", website: "mojang.com", logo: "mojang")
        let valve = saveDeveloper(name: "Valve Corporation", website: "valvesoftware.com", logo: "valve")
        let epic = saveDeveloper(name: "Epic Games", website: "epicgames.com", logo: "epicgames")
        let riot = saveDeveloper(name: "Riot Games", website: "riotgames.com", logo: "riot")
        let nintendo = saveDeveloper(name: "Nintendo", website: "nintendo.com", logo: "nintendo")
        let rockstar = saveDeveloper(name: "Rockstar Games", website: "rockstargames.com", logo: "rockstar")
        let cdpr = saveDeveloper(name: "CD Projekt Red", website: "cdprojektred.com", logo: "cdpr")
        let ubisoft = saveDeveloper(name: "Ubisoft", website: "ubisoft.com", logo: "ubisoft")
        let fromSoftware = saveDeveloper(name: "FromSoftware", website: "fromsoftware.jp", logo: "fromsoftware")
        let supercell = saveDeveloper(name: "Supercell", website: "supercell.com", logo: "supercell")

        // Ensure Developers are saved before using them
        do {
            try context.save()
        } catch {
            print("Error saving developers: \(error)")
            return // Or handle the error appropriately
        }

        
        // Insert Videogame entities
        if let mojang = mojang,
           let valve = valve,
           let epic = epic,
           let riot = riot,
           let nintendo = nintendo,
           let rockstar = rockstar,
           let cdpr = cdpr,
           let ubisoft = ubisoft,
           let fromSoftware = fromSoftware,
           let supercell = supercell {
                saveVideogame(title: "Minecraft",
                              logo: "minecraft",
                              releaseYear: getDate("17/05/2009"),
                              gameDescription: "Minecraft is a sandbox game developed by Mojang Studios. Players explore a blocky, procedurally generated world and build structures.",
                              developer: mojang, platforms: [.PC, .iOS, .Android, .XBox, .PlayStation, .Nintendo])
                saveVideogame(title: "Half-Life 2",
                              logo: "halflife2",
                              releaseYear: getDate("16/11/2004"),
                              gameDescription: "Half-Life 2 is a first-person shooter developed by Valve. Players control Gordon Freeman as he fights through a dystopian future.",
                              developer: valve, platforms: [.PC, .Steam, .XBox])
                saveVideogame(title: "Fortnite",
                              logo: "fortnite",
                              releaseYear: getDate("25/07/2017"),
                              gameDescription: "Fortnite is a battle royale game by Epic Games where 100 players fight to be the last one standing.",
                              developer: epic, platforms: [.PC, .iOS, .Android, .XBox, .PlayStation, .Nintendo])
                saveVideogame(title: "League of Legends",
                              logo: "lol", releaseYear: getDate("27/10/2009"),
                              gameDescription: "League of Legends is a multiplayer online battle arena game developed by Riot Games.",
                              developer: riot, platforms: [.PC])
                saveVideogame(title: "The Legend of Zelda: Breath of the Wild",
                              logo: "zelda_botw", releaseYear: getDate("03/03/2017"),
                              gameDescription: "An open-world action-adventure game developed by Nintendo, praised for its design and freedom.",
                              developer: nintendo, platforms: [.Nintendo])
                saveVideogame(title: "Grand Theft Auto V",
                              logo: "gtav",
                              releaseYear: getDate("17/09/2013"),
                              gameDescription: "An open-world crime simulation game developed by Rockstar Games, featuring three playable protagonists.",
                              developer: rockstar, platforms: [.PC, .Steam, .XBox, .PlayStation])
                saveVideogame(title: "The Witcher 3: Wild Hunt",
                              logo: "witcher3", releaseYear: getDate("19/05/2015"),
                              gameDescription: "An open-world RPG developed by CD Projekt Red based on Andrzej Sapkowski's fantasy novels.",
                              developer: cdpr, platforms: [.PC, .Steam, .XBox, .PlayStation, .Nintendo])
                saveVideogame(title: "Assassin's Creed Valhalla",
                              logo: "assassinscreed",
                              releaseYear: getDate("10/11/2020"),
                              gameDescription: "An action RPG by Ubisoft where players control Eivor, a Viking raider during the Norse invasion of England.",
                              developer: ubisoft, platforms: [.PC, .XBox, .PlayStation])
                saveVideogame(title: "Elden Ring",
                              logo: "eldenring",
                              releaseYear: getDate("25/02/2022"),
                              gameDescription: "A fantasy action RPG created by FromSoftware in collaboration with George R.R. Martin.",
                              developer: fromSoftware, platforms: [.PC, .Steam, .XBox, .PlayStation])
                saveVideogame(title: "Clash of Clans",
                              logo: "clashofclans",
                              releaseYear: getDate("02/08/2012"),
                              gameDescription: "A freemium mobile strategy game developed by Supercell where players build villages and battle others.",
                              developer: supercell, platforms: [.iOS, .Android])
            }
        }
         
     static func getDate(_ dateString: String) -> Date {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "dd/MM/yyyy"
         return dateFormatter.date(from: dateString) ?? Date()
     }
    
    
    static func deleteAllData() {
        deleteAllVideogames()
        deleteAllDevelopers()
    }

    static private func deleteAllVideogames() {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all Videogames: \(error)")
        }
    }

    static private func deleteAllDevelopers() {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all Developers: \(error)")
        }
    }

    // MARK: - Fetch Functions

    // 2. Fetch all Videogame entities
    static func fetchAllVideogames() -> [Videogame] {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        do {
            let videogames = try context.fetch(fetchRequest)
            for videogame in videogames {
                if let platformsStrings = videogame.platforms as? [String] {
                    videogame.platforms = platformsStrings.compactMap { Platforms(rawValue: $0) }
                    dump(videogame.platforms)
                } else {
                    videogame.platforms = [] // Or handle this case appropriately
                    print("Warning: platforms is not of type [String]")
                }
            }
            return videogames
        } catch {
            print("Error fetching videogames: \(error)")
            return []
        }
    }

    // 3. Fetch a single Videogame by title
    static func fetchVideogame(byTitle title: String) -> Videogame? {
        let fetchRequest: NSFetchRequest<Videogame> = Videogame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let videogames = try context.fetch(fetchRequest)
            if let videogame = videogames.first,
               let platformsStrings = videogame.platforms as? [String] {
                videogame.platforms = platformsStrings.compactMap { Platforms(rawValue: $0) } as NSObject
            }
            return videogames.first
        } catch {
            print("Error fetching videogame by title: \(error)")
            return nil
        }
    }

    // MARK: - Save Function

    // 4. Save a new Videogame
    static func saveVideogame(title: String, logo: String, releaseYear: Date, gameDescription: String, developer: Developer, platforms: [Platforms]) {
        let newVideogame = Videogame(context: context)
        newVideogame.title = title
        newVideogame.logo = logo
        newVideogame.releaseYear = releaseYear
        newVideogame.gameDescription = gameDescription
        newVideogame.developer = developer
        newVideogame.platforms = platforms.map { $0.rawValue }  // Store rawValue (String)

        do {
            try context.save()
        } catch {
            print("Error saving videogame: \(error)")
        }
    }

    // MARK: - Update Function

    // 5. Update a Videogame
    static func updateVideogame(videogame: Videogame, title: String, logo: String, releaseYear: Date, gameDescription: String, developer: Developer, platforms: [Platforms]) {
        videogame.title = title
        videogame.logo = logo
        videogame.releaseYear = releaseYear
        videogame.gameDescription = gameDescription
        videogame.developer = developer
        videogame.platforms = platforms.map { $0.rawValue }  // Store rawValue (String)

        do {
            try context.save()
        } catch {
            print("Error updating videogame: \(error)")
        }
    }

    // MARK: - Delete Function

    // 6. Delete a Videogame
    static func deleteVideogame(videogame: Videogame) {
        context.delete(videogame)
        do {
            try context.save()
        } catch {
            print("Error deleting videogame: \(error)")
        }
    }

    // MARK: - Developer CRUD Operations

    // 7. Fetch all Developers
    static func fetchAllDevelopers() -> [Developer] {
        let fetchRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        do {
            let developers = try context.fetch(fetchRequest)
            return developers
        } catch {
            print("Error fetching developers: \(error)")
            return []
        }
    }

    // 8. Save a new Developer
    static func saveDeveloper(name: String, website: String, logo: String) -> Developer? {
        let newDeveloper = Developer(context: context)
        newDeveloper.name = name
        newDeveloper.website = website
        newDeveloper.logo = logo

        do {
            try context.save()
            return newDeveloper // Return the saved Developer object
        } catch {
            print("Error saving developer: \(error)")
            return nil
        }
    }

    // 9. Update a Developer
    static func updateDeveloper(developer: Developer, name: String, website: String, logo: String) {
        developer.name = name
        developer.website = website
        developer.logo = logo

        do {
            try context.save()
        } catch {
            print("Error updating developer: \(error)")
        }
    }

    // 10. Delete a Developer
    static func deleteDeveloper(developer: Developer) {
        context.delete(developer)
        do {
            try context.save()
        } catch {
            print("Error deleting developer: \(error)")
        }
    }
    
}
