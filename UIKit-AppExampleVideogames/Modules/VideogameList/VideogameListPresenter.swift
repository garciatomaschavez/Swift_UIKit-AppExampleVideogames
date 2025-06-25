//
//  VideogameListPresenter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//  
//

import UIKit

class VideogameListPresenter: VideogameListPresenterProtocol {
    
    weak var view: (any VideogameListViewProtocol)?
    var interactor: (any VideogameListInteractorInputProtocol)?
    var router: (any VideogameListRouterProtocol)?

    private var currentVideogames: [VideogameEntity] = []

    // MARK: - VideogameListPresenterProtocol (View -> Presenter)

    func viewDidLoad() {
        view?.showLoading()
        interactor?.fetchVideogames()
    }

    func didSelectVideogame(withId id: String) {
        // 'id' here is the VideogameEntity.id (business key / title)
        guard let view = view else {
            print("Error: View is nil, cannot navigate to detail.")
            return
        }
        router?.navigateToVideogameDetail(from: view, withVideogameId: id)
    }

    func didTapFavoriteButton(forVideogameId id: String) {
        // 'id' here is the VideogameEntity.id (business key / title)
        view?.showLoading()
        interactor?.toggleFavoriteStatus(forVideogameId: id)
    }
    
    func refreshTriggered() {
        view?.showLoading()
        interactor?.fetchVideogames()
    }

    // MARK: - Helper to map Entity to VideogameListViewModel
    private func mapEntitiesToListViewModels(_ entities: [VideogameEntity]) -> [VideogameListViewModel] {
        return entities.map { entity in
            // VideogameListViewModel.id is non-optional String, used for Identifiable in UI.
            // We will use entity.id (the business key/title) for this.
            // VideogameEntity.uuid is String? and currently always nil.
            
            let viewModelId = entity.id // Use business key (title) as the ViewModel's Identifiable ID.
            let businessKey = entity.id // Also use business key for actions.

            let devNameText = "\(NSLocalizedString("VideogameListPresenter-By", comment: "")) \(entity.developer.name)"
            let devLogoImageName = entity.developer.logo
            
            let releaseDateTextValue: String
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]
            
            if let date = isoFormatter.date(from: entity.releaseDateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateStyle = .medium
                displayFormatter.timeStyle = .none
                releaseDateTextValue = "\(NSLocalizedString("Released_has_value", comment: "")) \(displayFormatter.string(from: date))"
            } else if entity.releaseDateString.isEmpty || entity.releaseDateString.lowercased() == "n/a" {
                releaseDateTextValue = "\(NSLocalizedString("Released_has_no_date", comment: ""))"
            } else {
                releaseDateTextValue = "\(NSLocalizedString("Released_cannot_detect_value", comment: "")) \(entity.releaseDateString)"
                print("⚠️ Warning: Could not parse releaseDateString '\(entity.releaseDateString)' for VideogameListViewModel: \(entity.title)")
            }

            let mainGameImageName = entity.logo
            let platformIcons = entity.platforms.map { $0.imageName }

            return VideogameListViewModel(
                id: viewModelId,                          // ViewModel's Identifiable ID (String)
                businessKeyId: businessKey,               // Business Key (String)
                name: entity.title,
                developerNameText: devNameText,
                developerLogoImageName: devLogoImageName,
                releaseDateText: releaseDateTextValue,
                mainImageName: mainGameImageName,
                platformIconNames: platformIcons,
                isFavorite: entity.isFavorite ?? false
            )
        }
    }
}

// MARK: - VideogameListInteractorOutputProtocol (Interactor -> Presenter)
extension VideogameListPresenter: VideogameListInteractorOutputProtocol {
    
    func didFetchVideogames(_ videogames: [VideogameEntity]) {
        view?.hideLoading()
        self.currentVideogames = videogames

        if videogames.isEmpty {
            view?.displayNoVideogames()
        } else {
            let viewModels = mapEntitiesToListViewModels(videogames)
            // No need for the "Some game data could not be fully processed" error here anymore
            // because mapEntitiesToListViewModels now always returns a ViewModel if an entity is provided,
            // as it uses entity.id for the ViewModel's id.
            if viewModels.isEmpty && videogames.isEmpty { // Should be caught by the first check
                 view?.displayNoVideogames()
            } else {
                view?.displayVideogames(viewModels)
            }
        }
    }

    func didFailToFetchVideogames(error: RepositoryError) {
        view?.hideLoading()
        let title = "Error"
        var message = "An unknown error occurred. Please try again."
        switch error {
        case .networkError: message = "A network error occurred. Please check your connection."
        case .decodingError: message = "Failed to process data from the server."
        case .coreDataError: message = "A database error occurred."
        case .dataNotFound: message = "Could not find the requested data."
        case .localResourceError: message = "An error occurred with a local resource."
        case .unknown: message = "An unexpected error occurred."
        }
        view?.displayError(title: title, message: message)
    }

    func didUpdateFavoriteStatus(forVideogame updatedVideogame: VideogameEntity) {
        view?.hideLoading()
        if let index = currentVideogames.firstIndex(where: { $0.id == updatedVideogame.id }) {
            currentVideogames[index] = updatedVideogame
        } else {
            print("VideogameListPresenter: Updated videogame not found in current list to update locally. ID: \(updatedVideogame.id)")
        }
        let viewModels = mapEntitiesToListViewModels(currentVideogames)
        view?.displayVideogames(viewModels)
    }

    func didFailToUpdateFavoriteStatus(error: RepositoryError) {
        view?.hideLoading()
        view?.displayError(title: "Favorite Error", message: "Could not update favorite status.")
    }
}
