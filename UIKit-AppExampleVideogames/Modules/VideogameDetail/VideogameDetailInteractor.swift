//
//  VideogameDetailInteractor.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

class VideogameDetailInteractor: VideogameDetailInteractorInputProtocol {

    weak var presenter: (any VideogameDetailInteractorOutputProtocol)?
    private let videogameRepository: any VideogameRepository // Use the protocol

    // The videogameId (business key, e.g., title) that this interactor instance is focused on.
    // This can be passed during initialization or set if the interactor is reused.
    // For simplicity with the current router setup, we'll assume it's passed during init.
    private let videogameId: String

    init(videogameId: String, videogameRepository: any VideogameRepository) {
        self.videogameId = videogameId
        self.videogameRepository = videogameRepository
    }

    // MARK: - VideogameDetailInteractorInputProtocol

    func fetchVideogameDetails(forId id: String) {
        // Ensure we are fetching for the ID this interactor was initialized with,
        // or use the passed 'id' if the design allows fetching for different IDs.
        // For consistency with VIPER module instance per screen, using self.videogameId is typical.
        // If 'id' parameter is meant to override, the logic would adjust.
        // Here, we assume the 'id' passed to this function is the one we should use.
        
        videogameRepository.getById(id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let videogameEntityOptional):
                    if let videogameEntity = videogameEntityOptional {
                        self.presenter?.didFetchVideogameDetails(videogameEntity)
                    } else {
                        self.presenter?.didFailToFetchVideogameDetails(error: .dataNotFound)
                    }
                case .failure(let error):
                    self.presenter?.didFailToFetchVideogameDetails(error: error)
                }
            }
        }
    }

    func toggleFavoriteStatus(forId id: String) {
        // 1. Get the current videogame to determine its current favorite state.
        videogameRepository.getById(id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let videogameEntityOptional):
                guard let videogameEntity = videogameEntityOptional else {
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
                DispatchQueue.main.async {
                    self.presenter?.didFailToUpdateFavoriteStatus(error: error)
                }
            }
        }
    }
}
