//
//  VideogameDetailProtocols.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 19/05/25.
//
//

import UIKit
import CoreData

// MARK: - View Protocol
protocol VideogameDetailViewProtocol: ViperViewProtocol where PresenterType == VideogameDetailPresenterProtocol {
    // PRESENTER -> VIEW
    func displayVideogameDetails(_ viewModel: VideogameDetailViewModel)
    func showLoading()
    func hideLoading()
    func displayError(title: String, message: String)
}

// MARK: - Interactor Protocols
protocol VideogameDetailInteractorInputProtocol: ViperInteractorInputProtocol where InteractorOutputType == VideogameDetailInteractorOutputProtocol {
    // PRESENTER -> INTERACTOR
    func fetchVideogameDetails(forId id: String)
    func toggleFavoriteStatus(forId id: String)
}

protocol VideogameDetailInteractorOutputProtocol: AnyObject {
    // INTERACTOR -> PRESENTER
    func didFetchVideogameDetails(_ videogame: VideogameEntity)
    func didFailToFetchVideogames(error: RepositoryError)
    func didUpdateFavoriteStatus(forVideogame videogame: VideogameEntity)
    func didFailToUpdateFavoriteStatus(error: RepositoryError)
}

// MARK: - Presenter Protocol
protocol VideogameDetailPresenterProtocol: ViperPresenterProtocol where
    ViewType == VideogameDetailViewProtocol, // Removed 'any'
    InteractorInputType == VideogameDetailInteractorInputProtocol, // Removed 'any'
    RouterType == VideogameDetailRouterProtocol {
    // VIEW -> PRESENTER
    func viewDidLoad()
    func didTapFavoriteButton()
}

// MARK: - Router Protocol
protocol VideogameDetailRouterProtocol: ViperRouterProtocol {
    static func createModule(videogameId: String, persistentContainer: NSPersistentContainer) -> UIViewController
    // Navigation method now takes a concrete protocol type, not 'any'
    func dismissDetailView(from view: VideogameDetailViewProtocol)
}
