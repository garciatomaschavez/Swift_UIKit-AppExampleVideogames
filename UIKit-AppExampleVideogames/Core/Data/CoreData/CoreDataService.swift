//
//  CoreDataService.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 5/5/25.
//
//

import Foundation
import CoreData

class CoreDataService {

    // MARK: - Properties

    private let persistentContainer: NSPersistentContainer
    
    // These contexts can be used by the specific LocalDataSource adapters if needed,
    // or the adapters can create their own contexts from the persistentContainer.
    // For the current adapter implementation, they create their own.
    // So, these specific lazy vars might become redundant if not used elsewhere.
    /*
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    private var viewContext: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    */

    // MARK: - Initialization

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    // MARK: - General Helper Methods (if any are needed by multiple data sources)
    // For example, the isLocalDataEmpty can remain here if it's general enough.
    // However, each LocalDataSource might want to implement its own version
    // based on its specific EntityType for clarity.

    public func isDataEmpty(for entityName: String, in context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.fetchLimit = 1 // We only need to know if at least one exists
            do {
                let count = try context.count(for: fetchRequest)
                completion(count == 0)
            } catch {
                print("CoreDataService: Error checking if data is empty for entity \(entityName): \(error)")
                completion(true) // Assume empty on error
            }
        }
    }
    
    // Other potential shared Core Data utilities could go here.
    // For now, most logic has been moved to the specific LocalDataSource adapters.
}
