//
//  VideogameDetailProtocols.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//

import UIKit
import CoreData

// MARK: - View Protocol (View -> Presenter, Presenter -> View)
protocol VideogameDetailViewProtocol: AnyObject {
    var presenter: (any VideogameDetailPresenterProtocol)? { get set }

    // PRESENTER -> VIEW
    func displayVideogameDetails(_ viewModel: VideogameDetailViewModel)
    func showLoading()
    func hideLoading()
    func displayError(title: String, message: String)
    // func updateFavoriteStatusInView(isFavorite: Bool) // If detail view can toggle favorite
}

// MARK: - Interactor Protocols (Presenter -> Interactor, Interactor -> Presenter)
protocol VideogameDetailInteractorInputProtocol: AnyObject {
    var presenter: (any VideogameDetailInteractorOutputProtocol)? { get set }

    // PRESENTER -> INTERACTOR
    func fetchVideogameDetails(forId id: String) // id is the business key (e.g., title)
    func toggleFavoriteStatus(forId id: String)
}

protocol VideogameDetailInteractorOutputProtocol: AnyObject {
    // INTERACTOR -> PRESENTER
    func didFetchVideogameDetails(_ videogame: VideogameEntity)
    func didFailToFetchVideogameDetails(error: RepositoryError)
    func didUpdateFavoriteStatus(forVideogame videogame: VideogameEntity)
    func didFailToUpdateFavoriteStatus(error: RepositoryError)
}

// MARK: - Presenter Protocol (View -> Presenter, Interactor -> Presenter, Router -> Presenter)
protocol VideogameDetailPresenterProtocol: AnyObject {
    var view: (any VideogameDetailViewProtocol)? { get set }
    var interactor: (any VideogameDetailInteractorInputProtocol)? { get set }
    var router: (any VideogameDetailRouterProtocol)? { get set } // Optional, if detail view has navigation

    // VIEW -> PRESENTER
    func viewDidLoad()
    func didTapFavoriteButton() // Assuming the detail view has a favorite button
    // func didTapOpenDeveloperWebsite() // If there's a button for this, handled by view directly or via presenter
}

// MARK: - Router Protocol (Presenter -> Router)
protocol VideogameDetailRouterProtocol: AnyObject {
    static func createVideogameDetailModule(
        videogameId: String, // Business key (e.g., title)
        persistentContainer: NSPersistentContainer
    ) -> UIViewController

    // PRESENTER -> ROUTER (if any navigation from detail, e.g., to developer's other games)
    // func navigateToDeveloperDetails(from view: VideogameDetailViewProtocol, withDeveloperId developerId: String)
    func dismissDetailView(from view: VideogameDetailViewProtocol)
}
