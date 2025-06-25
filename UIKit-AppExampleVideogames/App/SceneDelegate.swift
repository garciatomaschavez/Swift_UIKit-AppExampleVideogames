//
//  SceneDelegate.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/4/25.
//

import UIKit
import CoreData // Import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - Core Data Stack
    // This remains essential as it's passed to the routers.
    lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "AppExampleVideogames" // Ensure this matches your .xcdatamodeld file
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this with suitable error handling for your application.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.
                print("Unresolved error \(error), \(error.userInfo)")
                // For production, consider more graceful error handling or reporting.
            } else {
                print("Core Data stack successfully initialized with model: \(modelName)")
            }
        })
        return container
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        print("SceneDelegate: willConnectTo session - Setting up initial module.")

        // Ensure the persistent container is initialized before being used.
        // Accessing it here via `self.persistentContainer` ensures it's loaded.
        let _ = self.persistentContainer

        // 1. Create the initial module (VideogameList) using its router.
        // The router is now responsible for building the entire module with its dependencies.
        let initialViewController = VideogameListRouter.createVideogameListModule(
            persistentContainer: self.persistentContainer
        )

        // 2. Set up root view controller
        let navigationController = UINavigationController(rootViewController: initialViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveContext()
    }

    func saveContext () {
        let context = persistentContainer.viewContext // Use the viewContext from the shared container
        if context.hasChanges {
            do {
                try context.save()
                print("SceneDelegate: Context saved successfully.")
            } catch {
                let nserror = error as NSError
                print("SceneDelegate: Unresolved error saving context \(nserror), \(nserror.userInfo)")
                // Consider more robust error handling for production.
            }
        }
    }
}
