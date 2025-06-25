//
//  VideogameDetailRouter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//  Refactored by AI on 19/05/25.
//  Updated by AI on 23/05/25 to use ViperModuleBuilder and DataLayerDependencies.
//

import UIKit
import CoreData

class VideogameDetailRouter: VideogameDetailRouterProtocol {

    // Updated static factory method name to match protocol
    static func createModule(
        videogameId: String,
        persistentContainer: NSPersistentContainer
    ) -> UIViewController {

        let view = VideogameDetailViewController()
        let presenter = VideogameDetailPresenter(videogameId: videogameId)
        let router = VideogameDetailRouter()

        // --- Data Layer Setup Simplified ---
        let dataDependencies = DataLayerDependencies(persistentContainer: persistentContainer)
        // --- End of Data Layer Setup Simplification ---
        
        let interactor: any VideogameDetailInteractorInputProtocol = VideogameDetailInteractor(
            videogameId: videogameId,
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

    // MARK: - Navigation
    func dismissDetailView(from view: any VideogameDetailViewProtocol) {
        guard let viewController = view as? UIViewController else {
            print("VideogameDetailRouter: Error - View to dismiss is not a UIViewController.")
            return
        }
        viewController.dismiss(animated: true, completion: nil)
    }
}
