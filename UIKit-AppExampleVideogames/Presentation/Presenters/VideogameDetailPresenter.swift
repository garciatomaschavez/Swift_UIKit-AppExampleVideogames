//
//  VideogameDetailPresenter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

class VideogameDetailPresenter: VideogameDetailPresenterProtocol {
    
    weak var view: VideogameDetailViewProtocol?
    
    private let videogameId: UUID
    private let getVideogameByIdUseCase: GetVideogameByIdUseCase
    // private let updateFavoriteUseCase: UpdateFavoriteVideogameUseCase // If detail view can toggle favorite

    init(
        videogameId: UUID,
        getVideogameByIdUseCase: GetVideogameByIdUseCase
        // updateFavoriteUseCase: UpdateFavoriteVideogameUseCase
    ) {
        self.videogameId = videogameId
        self.getVideogameByIdUseCase = getVideogameByIdUseCase
        // self.updateFavoriteUseCase = updateFavoriteUseCase
    }

    func viewDidLoad() {
        fetchDetails()
    }

    private func fetchDetails() {
        view?.displayLoading(true)
        getVideogameByIdUseCase.execute(id: videogameId) { [weak self] result in
            guard let self = self else { return }
            self.view?.displayLoading(false)

            switch result {
            case .success(let entityOptional):
                if let entity = entityOptional {
                    let viewModel = VideogameDetailViewModel.from(entity: entity)
                    self.view?.displayVideogameDetails(viewModel)
                } else {
                    self.view?.displayError(title: "Not Found", message: "Videogame details could not be loaded.")
                }
            case .failure(let error):
                self.view?.displayError(title: "Error", message: "Failed to load details: \(error.localizedDescription)")
            }
        }
    }
    
    // Example: If the detail view had a favorite button
    // func didTapFavoriteButton() {
    //     // 1. Get current entity (might need to store it after fetchDetails)
    //     // 2. Call updateFavoriteUseCase
    //     // 3. On success, update the view: self.view?.updateFavoriteStatusInView(isFavorite: newStatus)
    // }
}
