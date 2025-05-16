//
//  CollectionViewDataSource.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/4/25.
//

import Foundation
import UIKit

final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    private var viewModels: [VideogameViewModel] = []
    weak var cellActionDelegate: VideogameCellActionDelegate?
    var heartColorProvider: (() -> UIColor)? // Closure to get the current heart color

    // Corrected Initializer
    init(
        viewModels: [VideogameViewModel] = [],
        cellActionDelegate: VideogameCellActionDelegate? = nil,
        heartColorProvider: (() -> UIColor)? = nil // Added parameter
    ) {
        self.viewModels = viewModels
        self.cellActionDelegate = cellActionDelegate
        self.heartColorProvider = heartColorProvider // Store it
    }

    func update(with viewModels: [VideogameViewModel]) {
        self.viewModels = viewModels
    }
    
    func updateViewModel(_ viewModel: VideogameViewModel, at index: Int) {
        guard index >= 0 && index < viewModels.count else { return }
        self.viewModels[index] = viewModel
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            fatalError("Failed to dequeue CollectionViewCell. Make sure the identifier is correct and the cell is registered.")
        }
        
        guard indexPath.item < viewModels.count else {
            print("Error: Index out of range in cellForItemAt. Index: \(indexPath.item), ViewModels count: \(viewModels.count)")
            return cell // Return an empty or placeholder cell
        }
        
        let viewModel = viewModels[indexPath.item]
        // Get current heart color using the provider
        let currentHeartColor = heartColorProvider?() ?? .systemRed
        
        // Pass the heart color to the cell's configure method
        // Ensure CollectionViewCell.swift's configure method accepts this
        cell.configure(with: viewModel, at: indexPath, heartColor: currentHeartColor)
        
        cell.actionDelegate = self.cellActionDelegate
        
        return cell
    }
}
