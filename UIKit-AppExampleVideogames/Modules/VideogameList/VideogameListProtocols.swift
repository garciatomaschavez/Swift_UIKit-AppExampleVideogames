//
//  VideogameListProtocols.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//  Refactored by AI on 19/05/25.
//

import UIKit
import CoreData // For NSPersistentContainer

// MARK: - View Protocol
protocol VideogameListViewProtocol: AnyObject {
    var presenter: (any VideogameListPresenterProtocol)? { get set }

    // PRESENTER -> VIEW
    func showLoading()
    func hideLoading()
    func displayVideogames(_ videogames: [VideogameListViewModel])
    func displayError(title: String, message: String)
    func displayNoVideogames()
}

// MARK: - Interactor Protocols
protocol VideogameListInteractorInputProtocol: AnyObject {
    var presenter: (any VideogameListInteractorOutputProtocol)? { get set }

    // PRESENTER -> INTERACTOR
    func fetchVideogames()
    func toggleFavoriteStatus(forVideogameId id: String)
}

protocol VideogameListInteractorOutputProtocol: AnyObject {
    // INTERACTOR -> PRESENTER
    func didFetchVideogames(_ videogames: [VideogameEntity])
    func didFailToFetchVideogames(error: RepositoryError)
    func didUpdateFavoriteStatus(forVideogame videogame: VideogameEntity)
    func didFailToUpdateFavoriteStatus(error: RepositoryError)
}

// MARK: - Presenter Protocol
protocol VideogameListPresenterProtocol: AnyObject {
    var view: (any VideogameListViewProtocol)? { get set }
    var interactor: (any VideogameListInteractorInputProtocol)? { get set }
    var router: (any VideogameListRouterProtocol)? { get set }

    // VIEW -> PRESENTER
    func viewDidLoad()
    func didSelectVideogame(withId id: String)
    func didTapFavoriteButton(forVideogameId id: String)
    func refreshTriggered()
}

// MARK: - Router Protocol
protocol VideogameListRouterProtocol: AnyObject {
    // Corrected signature:
    static func createVideogameListModule(
        persistentContainer: NSPersistentContainer // Pass the persistent container
    ) -> UIViewController

    // PRESENTER -> ROUTER
    func navigateToVideogameDetail(from view: VideogameListViewProtocol, withVideogameId videogameId: String)
}
