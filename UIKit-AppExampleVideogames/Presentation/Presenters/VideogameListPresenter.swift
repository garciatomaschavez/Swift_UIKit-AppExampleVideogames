//
//  VideogameListPresenter.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation
import UIKit // Import UIKit for UI related tasks like showing loading

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
        // Register for .dataUpdated notification here or in viewDidLoad
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataUpdated), name: .dataUpdated, object: nil)
    }

    func viewDidLoad() {
        print("VideogameListPresenter: viewDidLoad called. Fetching videogames initially from local store...")
        fetchVideogames() // Initial fetch from local Core Data
    }
    
    @objc private func handleDataUpdated() {
        print("VideogameListPresenter: Received .dataUpdated notification. Re-fetching videogames from local store...")
        // This will be triggered after CoreDataService finishes importing from Firebase
        fetchVideogames()
    }

    func refreshDataRequested() {
        print("VideogameListPresenter: refreshDataRequested. Triggering Firebase sync...")
        // Show loading indicator to the user
        // Ensure this is dispatched to the main thread if view methods require it
        DispatchQueue.main.async {
            self.view?.displayLoading(true)
        }
        
        // Call CoreDataService to fetch from Firebase and update Core Data.
        // CoreDataService will post .dataUpdated upon completion,
        // which will trigger handleDataUpdated, then fetchVideogames.
        CoreDataService.fetchDataAndStoreInCoreData()
        
        // Note: The loading indicator (displayLoading(false)) will be handled
        // inside the completion of the fetchVideogames method, which is called
        // by handleDataUpdated after the Firebase sync and Core Data update.
    }

    private func fetchVideogames() {
        // This method fetches from the local Core Data via the use case.
        // It's called on initial load and after .dataUpdated notification.
        print("VideogameListPresenter: fetchVideogames (from local Core Data) called.")
        // Ensure view?.displayLoading(true) is called if this is a standalone refresh,
        // but in the context of remote refresh, it's already set.
        // For initial load, it might also be good to show loading.
        if videogameViewModels.isEmpty { // Show loading for initial fetch if list is empty
            DispatchQueue.main.async {
                 self.view?.displayLoading(true)
            }
        }

        getAllVideogamesUseCase.execute { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view?.displayLoading(false) // Always hide loading after this fetch completes
                switch result {
                case .success(let entities):
                    print("VideogameListPresenter: fetchVideogames success. Received \(entities.count) entities from local store.")
                    self.videogameEntities = entities
                    self.videogameViewModels = entities.map { VideogameViewModel.from(entity: $0) }
                    self.view?.displayVideogames(self.videogameViewModels)
                case .failure(let error):
                    print("VideogameListPresenter: fetchVideogames (from local) failed. Error: \(error.localizedDescription)")
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

        // Show loading for the specific action
        DispatchQueue.main.async {
             self.view?.displayLoading(true)
        }
        updateFavoriteVideogameUseCase.execute(videogameId: id, isFavorite: newFavoriteStatus) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view?.displayLoading(false)
                switch result {
                case .success():
                    print("VideogameListPresenter: Favorite status updated successfully for \(entity.name).")
                    self.videogameEntities[entityIndex].isFavorite = newFavoriteStatus
                    let updatedViewModel = VideogameViewModel.from(entity: self.videogameEntities[entityIndex])
                    if index < self.videogameViewModels.count && self.videogameViewModels[index].id == updatedViewModel.id {
                         self.videogameViewModels[index] = updatedViewModel
                         self.view?.refreshVideogame(at: index, with: updatedViewModel)
                    } else {
                        print("VideogameListPresenter: ViewModel index mismatch after favorite update, performing full local refresh.")
                        self.fetchVideogames()
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
