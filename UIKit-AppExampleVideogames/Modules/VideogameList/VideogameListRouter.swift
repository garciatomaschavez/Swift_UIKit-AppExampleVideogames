//
//  VideogameListRouter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//
//

import UIKit
import CoreData

class VideogameListRouter: VideogameListRouterProtocol {

    // Updated static factory method name to match protocol
    static func createModule(
        persistentContainer: NSPersistentContainer
    ) -> UIViewController {
        
        let view = VideogameListViewController()
        let presenter = VideogameListPresenter()
        let router = VideogameListRouter()

        // --- Data Layer Setup Simplified ---
        let dataDependencies = DataLayerDependencies(persistentContainer: persistentContainer)
        // --- End of Data Layer Setup Simplification ---
        
        let interactor: any VideogameListInteractorInputProtocol = VideogameListInteractor(
            videogameRepository: dataDependencies.videogameRepository // Use repository from dependencies
        )
        
        ViperModuleBuilder.wire(
            view: view,
            presenter: presenter,
            interactor: interactor,
            router: router
        )
        
        return view
    }

    // MARK: - Navigation (Instance method)
    func navigateToVideogameDetail(from view: any VideogameListViewProtocol, withVideogameId videogameId: String) {
        print("VideogameListRouter: Navigating to detail for videogame ID (business key): \(videogameId)")
        
        guard let sourceViewController = view as? UIViewController else {
            print("Error: Source view for navigation is not a UIViewController.")
            return
        }

        // It's generally better if the persistentContainer is passed down or accessible
        // via a more direct dependency injection rather than reaching out to SceneDelegate here.
        // However, for now, keeping this as is, assuming persistentContainer is the main one.
        guard let sceneDelegate = sourceViewController.view.window?.windowScene?.delegate as? SceneDelegate else {
             fatalError("Could not get SceneDelegate to access persistentContainer for detail view setup. Ensure the view is in the window hierarchy.")
        }
        let persistentContainer = sceneDelegate.persistentContainer
            
        let detailVC = VideogameDetailRouter.createModule(
            videogameId: videogameId,
            persistentContainer: persistentContainer
        )

        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [
                UISheetPresentationController.Detent.medium(),
                UISheetPresentationController.Detent.large()
            ]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = UISheetPresentationController.Detent.Identifier.medium
        }
        sourceViewController.present(detailVC, animated: true, completion: nil)
    }
}
