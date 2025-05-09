//
//  VideogameListPresenter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

class VideogameListPresenter: VideogameListPresenterProtocol {
    
    weak var view: VideogameListViewProtocol?
    
    private let getAllVideogamesUseCase: GetAllVideogamesUseCase
    private let updateFavoriteVideogameUseCase: UpdateFavoriteVideogameUseCase

    private var videogameEntities: [VideogameEntity] = []
    private var videogameViewModels: [VideogameViewModel] = []

    init(
        getAllVideogamesUseCase: GetAllVideogamesUseCase,
        updateFavoriteVideogameUseCase: UpdateFavoriteVideogameUseCase
    ) {
        self.getAllVideogamesUseCase = getAllVideogamesUseCase
        self.updateFavoriteVideogameUseCase = updateFavoriteVideogameUseCase
        print("VideogameListPresenter: Initialized.")
    }

    func viewDidLoad() {
        print("VideogameListPresenter: viewDidLoad called. Fetching videogames...")
        // Register for .dataUpdated notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataUpdated), name: .dataUpdated, object: nil)
        fetchVideogames()
    }
    
    @objc private func handleDataUpdated() {
        print("VideogameListPresenter: Received .dataUpdated notification. Re-fetching videogames...")
        fetchVideogames()
    }

    func refreshDataRequested() {
        print("VideogameListPresenter: refreshDataRequested. Fetching videogames...")
        fetchVideogames()
    }

    private func fetchVideogames() {
        view?.displayLoading(true)
        getAllVideogamesUseCase.execute { [weak self] result in
            guard let self = self else { return }
            // Ensure UI updates are on the main thread
            DispatchQueue.main.async {
                self.view?.displayLoading(false)
                switch result {
                case .success(let entities):
                    print("VideogameListPresenter: fetchVideogames success. Received \(entities.count) entities.")
                    self.videogameEntities = entities
                    self.videogameViewModels = entities.map { VideogameViewModel.from(entity: $0) }
                    self.view?.displayVideogames(self.videogameViewModels)
                case .failure(let error):
                    print("VideogameListPresenter: fetchVideogames failed. Error: \(error.localizedDescription)")
                    self.view?.displayError(title: "Error Fetching Data", message: error.localizedDescription)
                }
            }
        }
    }

    func didSelectVideogame(at index: Int) {
        guard index < videogameEntities.count else {
            print("VideogameListPresenter: didSelectVideogame - Index out of bounds.")
            view?.displayError(title: "Error", message: "Invalid selection.")
            return
        }
        let selectedEntity = videogameEntities[index]
        print("VideogameListPresenter: Selected videogame: \(selectedEntity.name) with ID: \(selectedEntity.id)")
        view?.navigateToDetailScreen(for: selectedEntity.id)
    }

    func didToggleFavorite(forVideogameId id: UUID, at index: Int) {
        guard let entityIndex = videogameEntities.firstIndex(where: { $0.id == id }) else {
            print("VideogameListPresenter: didToggleFavorite - Videogame not found for ID: \(id)")
            view?.displayError(title: "Error", message: "Videogame not found.")
            return
        }

        let entity = videogameEntities[entityIndex]
        let newFavoriteStatus = !entity.isFavorite
        print("VideogameListPresenter: Toggling favorite for \(entity.name) to \(newFavoriteStatus)")

        view?.displayLoading(true)
        updateFavoriteVideogameUseCase.execute(videogameId: id, isFavorite: newFavoriteStatus) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view?.displayLoading(false)
                switch result {
                case .success():
                    print("VideogameListPresenter: Favorite status updated successfully for \(entity.name).")
                    self.videogameEntities[entityIndex].isFavorite = newFavoriteStatus
                    let updatedViewModel = VideogameViewModel.from(entity: self.videogameEntities[entityIndex])
                    // Ensure the index for viewModels is also correct if they can get out of sync
                    if index < self.videogameViewModels.count && self.videogameViewModels[index].id == updatedViewModel.id {
                         self.videogameViewModels[index] = updatedViewModel
                         self.view?.refreshVideogame(at: index, with: updatedViewModel)
                    } else {
                        // Fallback to full refresh if index mapping is uncertain
                        print("VideogameListPresenter: ViewModel index mismatch after favorite update, performing full refresh.")
                        self.fetchVideogames() // Or find the correct index in viewModels
                    }
                case .failure(let error):
                    print("VideogameListPresenter: Failed to update favorite status. Error: \(error.localizedDescription)")
                    self.view?.displayError(title: "Update Failed", message: "Could not update favorite status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dataUpdated, object: nil)
        print("VideogameListPresenter: Deinitialized.")
    }
}
