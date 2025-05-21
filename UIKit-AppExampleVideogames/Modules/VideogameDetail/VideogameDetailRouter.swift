//
//  VideogameDetailRouter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//  Refactored by AI on 19/05/25.
//

import UIKit
import CoreData // For NSPersistentContainer

class VideogameDetailRouter: VideogameDetailRouterProtocol {

    static func createVideogameDetailModule(
        videogameId: String, // Business key (e.g., title)
        persistentContainer: NSPersistentContainer
    ) -> UIViewController {

        // 1. Create View
        // Assuming VideogameDetailViewController is instantiated programmatically
        // and doesn't rely on a storyboard for this specific module creation.
        // If it were from a storyboard:
        // let storyboard = UIStoryboard(name: "VideogameDetail", bundle: Bundle.main)
        // guard let view = storyboard.instantiateViewController(withIdentifier: "VideogameDetailViewControllerID") as? VideogameDetailViewController else {
        //     fatalError("Failed to instantiate VideogameDetailViewController from storyboard.")
        // }
        // For now, direct instantiation:
        let view = VideogameDetailViewController()

        // 2. Create Data Sources & Repositories (similar to VideogameListRouter)
        let coreDataService = CoreDataService(persistentContainer: persistentContainer)
        
        let videogameLocalDataSource = VideogameLocalDataSource(coreDataService: coreDataService, persistentContainer: persistentContainer)
        let developerLocalDataSource = DeveloperLocalDataSource(coreDataService: coreDataService, persistentContainer: persistentContainer)
        let apiService = APIService()

        let videogameRepository = DefaultVideogameRepositoryImpl(
            videogameLocalDataSource: videogameLocalDataSource,
            developerLocalDataSource: developerLocalDataSource,
            remoteDataSource: apiService,
            fetchStrategy: .remoteElseLocal // Or .localOnly if detail view shouldn't fetch remote
        )
        // Note: DeveloperRepository might not be directly needed by VideogameDetailInteractor
        // unless there are developer-specific actions initiated from the detail screen.

        // 3. Create Interactor
        // VideogameDetailInteractor needs the videogameId (business key) and the repository.
        let interactor: any VideogameDetailInteractorInputProtocol = VideogameDetailInteractor(
            videogameId: videogameId, // Pass the business key
            videogameRepository: videogameRepository
        )

        // 4. Create Presenter
        // VideogameDetailPresenter needs the videogameId (business key).
        let presenter: any VideogameDetailPresenterProtocol & VideogameDetailInteractorOutputProtocol = VideogameDetailPresenter(
            videogameId: videogameId // Pass the business key
        )
        
        // 5. Create Router instance (itself)
        let router: any VideogameDetailRouterProtocol = VideogameDetailRouter()

        // 6. Wire up the components
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router // For dismiss action
        
        interactor.presenter = presenter
        
        return view
    }

    // MARK: - Navigation
    func dismissDetailView(from view: VideogameDetailViewProtocol) {
        guard let viewController = view as? UIViewController else {
            print("VideogameDetailRouter: Error - View to dismiss is not a UIViewController.")
            return
        }
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // Example of further navigation if needed:
    // func navigateToDeveloperDetails(from view: VideogameDetailViewProtocol, withDeveloperId developerId: String) {
    //     guard let sourceViewController = view as? UIViewController else { return }
    //     // Create and present developer detail module
    //     print("VideogameDetailRouter: Navigating to developer details for ID: \(developerId)")
    // }
}
