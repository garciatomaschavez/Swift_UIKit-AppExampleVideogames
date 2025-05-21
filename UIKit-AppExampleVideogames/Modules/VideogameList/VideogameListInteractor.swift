//
//  VideogameListInteractor.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

class VideogameListInteractor: VideogameListInteractorInputProtocol {
    
    weak var presenter: VideogameListInteractorOutputProtocol?
    
    // Use the protocol type for the repository, not the concrete implementation.
    private let videogameRepository: any VideogameRepository
    // The DeveloperRepository was not directly used by this Interactor's methods,
    // as developer data is handled as a side effect within the VideogameRepository when fetching videogames.
    // If specific developer-only use cases were needed for the list screen (e.g., fetching all developer names for a filter),
    // then a DeveloperRepository would be appropriate here.

    // Updated initializer to accept the VideogameRepository protocol.
    init(videogameRepository: any VideogameRepository) {
        self.videogameRepository = videogameRepository
    }

    // MARK: - VideogameListInteractorInputProtocol

    func fetchVideogames() {
        // This now calls the `getAll` method on our new repository implementation
        // (e.g., DefaultVideogameRepositoryImpl) which handles fetch strategies.
        videogameRepository.getAll { [weak self] result in
            guard let self = self else { return }
            
            // Ensure presenter calls are on the main thread if they lead to UI updates.
            DispatchQueue.main.async {
                switch result {
                case .success(let videogameEntities):
                    self.presenter?.didFetchVideogames(videogameEntities)
                case .failure(let error):
                    self.presenter?.didFailToFetchVideogames(error: error)
                }
            }
        }
    }

    func toggleFavoriteStatus(forVideogameId id: String) {
        // The ID here is the VideogameEntity.id (business key, typically the title).
        
        // 1. Get the current videogame to determine its current favorite state.
        videogameRepository.getById(id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let videogameEntityOptional):
                guard let videogameEntity = videogameEntityOptional else {
                    // Videogame not found, inform presenter.
                    DispatchQueue.main.async {
                        self.presenter?.didFailToUpdateFavoriteStatus(error: .dataNotFound)
                    }
                    return
                }
                
                let newFavoriteState = !(videogameEntity.isFavorite ?? false)
                
                // 2. Call the repository to update the favorite status.
                self.videogameRepository.updateFavorite(id: id, isFavorite: newFavoriteState) { [weak self] updateResult in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch updateResult {
                        case .success(let updatedVideogame):
                            self.presenter?.didUpdateFavoriteStatus(forVideogame: updatedVideogame)
                        case .failure(let error):
                            self.presenter?.didFailToUpdateFavoriteStatus(error: error)
                        }
                    }
                }
                
            case .failure(let error):
                // Failed to fetch the videogame to check its current status.
                DispatchQueue.main.async {
                    self.presenter?.didFailToUpdateFavoriteStatus(error: error)
                }
            }
        }
    }
}
