//
//  VideogameListRouter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//  Refactored by AI on 19/05/25.
//

import UIKit
import CoreData // Required for NSPersistentContainer

class VideogameListRouter: VideogameListRouterProtocol {

    private weak var viewController: UIViewController?

    static func createVideogameListModule(
        persistentContainer: NSPersistentContainer
    ) -> UIViewController {
        
        // --- MODIFIED: Instantiate VideogameListViewController programmatically ---
        let view = VideogameListViewController()
        // If VideogameListViewController was designed in a NIB (XIB file) named "VideogameListViewController.xib",
        // and it's not the default name, you would instantiate it like this:
        // let view = VideogameListViewController(nibName: "VideogameListViewController", bundle: nil)
        // For this example, we assume it's fully code-based or its XIB matches its class name (if it has one).
        // --- END OF MODIFICATION ---

        // 1. Create Data Sources
        let coreDataService = CoreDataService(persistentContainer: persistentContainer)
        let videogameLocalDataSource = VideogameLocalDataSource(coreDataService: coreDataService, persistentContainer: persistentContainer)
        let developerLocalDataSource = DeveloperLocalDataSource(coreDataService: coreDataService, persistentContainer: persistentContainer)
        let apiService = APIService()

        // 2. Create Repositories
        let videogameRepository = DefaultVideogameRepositoryImpl(
            videogameLocalDataSource: videogameLocalDataSource,
            developerLocalDataSource: developerLocalDataSource,
            remoteDataSource: apiService,
            fetchStrategy: .remoteElseLocal
        )
        
        // 3. Create Interactor
        let interactor: any VideogameListInteractorInputProtocol = VideogameListInteractor(
            videogameRepository: videogameRepository
        )
        
        // 4. Create Presenter
        let presenter: any VideogameListPresenterProtocol & VideogameListInteractorOutputProtocol = VideogameListPresenter()
        
        // 5. Create Router instance
        let router = VideogameListRouter()
        router.viewController = view

        // 6. Wire up the components
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        return view
    }

    // MARK: - Navigation (Instance method)
    func navigateToVideogameDetail(from view: VideogameListViewProtocol, withVideogameId videogameId: String) {
        print("VideogameListRouter: Navigating to detail for videogame ID (business key): \(videogameId)")
        
        guard let sourceViewController = view as? UIViewController else {
            print("Error: Source view for navigation is not a UIViewController.")
            return
        }

        guard let sceneDelegate = sourceViewController.view.window?.windowScene?.delegate as? SceneDelegate else {
             fatalError("Could not get SceneDelegate to access persistentContainer for detail view setup. Ensure the view is in the window hierarchy.")
        }
        let persistentContainer = sceneDelegate.persistentContainer
            
        // VideogameDetailRouter also creates its view programmatically
        let detailVC = VideogameDetailRouter.createVideogameDetailModule(
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
