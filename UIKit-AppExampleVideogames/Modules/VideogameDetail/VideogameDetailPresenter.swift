//
//  VideogameDetailPresenter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation
import UIKit // For UIImage, URL if needed in ViewModel mapping, though ViewModels should ideally stick to primitive types or asset names.

class VideogameDetailPresenter: VideogameDetailPresenterProtocol, VideogameDetailInteractorOutputProtocol {
    
    weak var view: (any VideogameDetailViewProtocol)?
    var interactor: (any VideogameDetailInteractorInputProtocol)?
    var router: (any VideogameDetailRouterProtocol)?

    private let videogameId: String
    private var currentVideogameEntity: VideogameEntity?

    init(videogameId: String) {
        self.videogameId = videogameId
    }

    // MARK: - VideogameDetailPresenterProtocol (View -> Presenter)

    func viewDidLoad() {
        view?.showLoading()
        interactor?.fetchVideogameDetails(forId: self.videogameId)
    }

    func didTapFavoriteButton() {
        guard let entity = currentVideogameEntity else {
            view?.displayError(title: "Error", message: "Videogame data not loaded yet.")
            return
        }
        view?.showLoading()
        interactor?.toggleFavoriteStatus(forId: entity.id)
    }

    // MARK: - VideogameDetailInteractorOutputProtocol (Interactor -> Presenter)

    func didFetchVideogameDetails(_ videogame: VideogameEntity) {
        self.currentVideogameEntity = videogame
        view?.hideLoading()
        let viewModel = mapEntityToDetailViewModel(videogame)
        view?.displayVideogameDetails(viewModel)
    }

    func didFailToFetchVideogameDetails(error: RepositoryError) {
        view?.hideLoading()
        let message: String
        switch error {
        case .dataNotFound:
            message = "The requested videogame could not be found."
        case .networkError(let underlyingError):
            message = "Network error: \(underlyingError.localizedDescription)"
        case .coreDataError(let underlyingError):
            message = "Database error: \(underlyingError.localizedDescription)"
        default:
            message = "An unexpected error occurred while fetching details."
        }
        view?.displayError(title: "Error", message: message)
    }

    func didUpdateFavoriteStatus(forVideogame videogame: VideogameEntity) {
        self.currentVideogameEntity = videogame
        view?.hideLoading()
        let viewModel = mapEntityToDetailViewModel(videogame)
        view?.displayVideogameDetails(viewModel)
    }

    func didFailToUpdateFavoriteStatus(error: RepositoryError) {
        view?.hideLoading()
        view?.displayError(title: "Favorite Error", message: "Could not update favorite status. Please try again.")
    }

    // MARK: - Private Helper: Mapping Entity to ViewModel

    private func mapEntityToDetailViewModel(_ entity: VideogameEntity) -> VideogameDetailViewModel {
        let releaseDateText: String
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]
        
        if let date = isoFormatter.date(from: entity.releaseDateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .none
            releaseDateText = "\(NSLocalizedString("Released_has_value", comment: "")) \(displayFormatter.string(from: date))"
        } else if entity.releaseDateString.isEmpty || entity.releaseDateString.lowercased() == "n/a" {
            releaseDateText = "\(NSLocalizedString("Released_has_no_date", comment: ""))"
        } else {
            releaseDateText = "\(NSLocalizedString("Released_cannot_detect_value", comment: "")) \(entity.releaseDateString)"
            print("⚠️ Warning: Could not parse releaseDateString '\(entity.releaseDateString)' for VideogameDetailViewModel: \(entity.title)")
        }

        let platformIconNames = entity.platforms.map { $0.rawValue }

        var devWebsiteURL: URL? = nil
        if let websiteString = entity.developer.website, !websiteString.isEmpty {
            var validUrlString = websiteString
            if !websiteString.lowercased().hasPrefix("http://") && !websiteString.lowercased().hasPrefix("https://") {
                validUrlString = "https://" + websiteString
            }
            devWebsiteURL = URL(string: validUrlString)
            if devWebsiteURL == nil {
                print("⚠️ Warning: Could not create URL from developer website string: \(websiteString)")
            }
        }
        
        return VideogameDetailViewModel(
            id: entity.uuid,
            name: entity.title,
            gameLogoImageName: entity.logo,
            developerName: entity.developer.name,
            developerLogoImageName: entity.developer.logo,
            developerWebsiteURL: devWebsiteURL,
            releaseDateText: releaseDateText,
            description: entity.descriptionText,
            platformIconNames: platformIconNames,
            // Corrected argument label here:
            screenshotImageIdentifiers: entity.screenshotIdentifiers,
            isFavorite: entity.isFavorite ?? false
        )
    }
}
