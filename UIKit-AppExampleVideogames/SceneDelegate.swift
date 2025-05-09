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
    lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "AppExampleVideogames" // Ensure this matches your .xcdatamodeld file
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Core Data stack successfully initialized with model: \(modelName)")
            }
        })
        return container
    }()

    // MARK: - Service and Repository Dependencies
    lazy var coreDataService = CoreDataService()
    lazy var videogameRepository: VideogameRepositoryProtocol = CoreDataVideogameRepository(coreDataService: self.coreDataService)
    // lazy var developerRepository: DeveloperRepositoryProtocol = CoreDataDeveloperRepository(coreDataService: self.coreDataService)

    // MARK: - Use Case Dependencies
    lazy var getAllVideogamesUseCase: GetAllVideogamesUseCase = GetAllVideogamesUseCase(videogameRepository: self.videogameRepository)
    lazy var updateFavoriteUseCase: UpdateFavoriteVideogameUseCase = UpdateFavoriteVideogameUseCase(videogameRepository: self.videogameRepository)
    lazy var getVideogameByIdUseCase: GetVideogameByIdUseCase = GetVideogameByIdUseCase(videogameRepository: self.videogameRepository)


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        print("SceneDelegate: willConnectTo session - Setting up dependencies.")

        // 1. Create Presenter for the list
        let videogameListPresenter = VideogameListPresenter(
            getAllVideogamesUseCase: self.getAllVideogamesUseCase,
            updateFavoriteVideogameUseCase: self.updateFavoriteUseCase
        )

        // 2. Create ViewController and Inject Dependencies
        let viewController = ViewController()
        viewController.presenter = videogameListPresenter
        viewController.getVideogameByIdUseCase = self.getVideogameByIdUseCase

        // 3. Set up root view controller
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // 4. Trigger initial Firebase data fetch
        // Ensure Core Data stack is ready before this.
        // The lazy var persistentContainer should be initialized by now as coreDataService uses it.
//        print("SceneDelegate: Attempting to fetch data from Firebase and store in Core Data...")
//        CoreDataService.fetchDataAndStoreInCoreData()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveContext()
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("SceneDelegate: Context saved successfully.")
            } catch {
                let nserror = error as NSError
                print("SceneDelegate: Unresolved error saving context \(nserror), \(nserror.userInfo)")
                // Consider more robust error handling than fatalError for production
                // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
