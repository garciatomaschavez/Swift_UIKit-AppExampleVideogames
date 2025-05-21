//
//  VideogameListPresenter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//  Refactored by AI on 19/05/25
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
        view?.showLoading() // Optional: show loading for quick actions too
        interactor?.toggleFavoriteStatus(forVideogameId: id)
    }
    
    func refreshTriggered() {
        view?.showLoading()
        interactor?.fetchVideogames()
    }

    // MARK: - Helper to map Entity to VideogameListViewModel
    // Corrected to return [VideogameListViewModel]
    private func mapEntitiesToListViewModels(_ entities: [VideogameEntity]) -> [VideogameListViewModel] {
        return entities.compactMap { entity -> VideogameListViewModel? in
            guard let entityUUID = entity.uuid else {
                // This entity hasn't been saved to CoreData yet or its UUID wasn't populated.
                // The VideogameListViewModel requires a UUID for its `id` property for Identifiable conformance.
                print("⚠️ Warning: VideogameEntity with title '\(entity.title)' is missing a UUID. Cannot create VideogameListViewModel.")
                return nil
            }

            let devNameText = "\(NSLocalizedString("VideogameListPresenter-By", comment: "")) \(entity.developer.name)"
            let devLogoImageName = entity.developer.logo // Asset name
            
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

            // VideogameEntity.logo is the game's primary logo asset name
            let mainGameImageName = entity.logo

            // Platform.imageName should provide the direct asset name (e.g., "pc_icon")
            let platformIcons = entity.platforms.map { $0.imageName }

            // Corrected to initialize VideogameListViewModel
            return VideogameListViewModel(
                id: entityUUID,                           // UUID from CoreData (for Identifiable in UI)
                businessKeyId: entity.id,                 // Title/Business Key from Entity (for actions)
                name: entity.title,                       // Game's title
                developerNameText: devNameText,
                developerLogoImageName: devLogoImageName, // Asset name for developer logo
                releaseDateText: releaseDateTextValue,
                mainImageName: mainGameImageName,         // Asset name for game's main logo for cell
                platformIconNames: platformIcons,         // Asset names for platform icons
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
            // Corrected to call mapEntitiesToListViewModels
            let viewModels = mapEntitiesToListViewModels(videogames)
            if viewModels.isEmpty && !videogames.isEmpty {
                // This case means all entities failed to map (e.g., all missing UUIDs)
                view?.displayError(title: "Data Issue", message: "Some game data could not be fully processed. Please try refreshing.")
            } else if viewModels.isEmpty && videogames.isEmpty {
                 view?.displayNoVideogames() // Already handled by the first check, but good for clarity
            }
            else {
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
        view?.hideLoading() // Stop loading indicator if it was shown for this action
        if let index = currentVideogames.firstIndex(where: { $0.id == updatedVideogame.id }) {
            currentVideogames[index] = updatedVideogame
        } else {
            // This might happen if the list wasn't up-to-date or if it's a new item.
            // For a list, usually, we'd expect the item to exist.
            // If it doesn't, fetching the whole list again might be an option, or just add it.
            // For now, we update if found, otherwise, this change might not reflect immediately
            // without a full list refresh.
            print("VideogameListPresenter: Updated videogame not found in current list to update locally. ID: \(updatedVideogame.id)")
            // To be safe, re-fetch or ensure data consistency. For now, just map and display.
        }
        // Corrected to call mapEntitiesToListViewModels
        let viewModels = mapEntitiesToListViewModels(currentVideogames)
        view?.displayVideogames(viewModels) // Refresh the entire list
    }

    func didFailToUpdateFavoriteStatus(error: RepositoryError) {
        view?.hideLoading()
        view?.displayError(title: "Favorite Error", message: "Could not update favorite status.")
    }
}
