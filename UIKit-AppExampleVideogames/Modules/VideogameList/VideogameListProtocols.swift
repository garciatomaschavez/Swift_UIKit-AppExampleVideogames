//
//  VideogameListProtocols.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//
//

import UIKit
import CoreData // For NSPersistentContainer

// MARK: - View Protocol
// Conforms to the base ViperViewProtocol
protocol VideogameListViewProtocol: ViperViewProtocol where PresenterType == VideogameListPresenterProtocol {
    // PRESENTER -> VIEW
    func showLoading()
    func hideLoading()
    func displayVideogames(_ videogames: [VideogameListViewModel])
    func displayError(title: String, message: String)
    func displayNoVideogames()
}

// MARK: - Interactor Protocols
// Conforms to the base ViperInteractorInputProtocol
protocol VideogameListInteractorInputProtocol: ViperInteractorInputProtocol where InteractorOutputType == VideogameListInteractorOutputProtocol {
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
// Conforms to the base ViperPresenterProtocol
protocol VideogameListPresenterProtocol: ViperPresenterProtocol where
    ViewType == VideogameListViewProtocol, // Removed 'any'
    InteractorInputType == VideogameListInteractorInputProtocol, // Removed 'any'
    RouterType == VideogameListRouterProtocol {
    // VIEW -> PRESENTER
    func viewDidLoad()
    func didSelectVideogame(withId id: String)
    func didTapFavoriteButton(forVideogameId id: String)
    func refreshTriggered()
}

// MARK: - Router Protocol
protocol VideogameListRouterProtocol: ViperRouterProtocol {
    static func createModule(persistentContainer: NSPersistentContainer) -> UIViewController
    // Navigation method now takes a concrete protocol type, not 'any'
    func navigateToVideogameDetail(from view: VideogameListViewProtocol, withVideogameId videogameId: String)
}
