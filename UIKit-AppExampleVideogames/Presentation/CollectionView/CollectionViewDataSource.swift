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
    
    // The ViewController will set this delegate to handle favorite button taps from the cell
    weak var cellActionDelegate: VideogameCellActionDelegate? // Changed type

    init(viewModels: [VideogameViewModel] = [], cellActionDelegate: VideogameCellActionDelegate? = nil) { // Changed type
        self.viewModels = viewModels
        self.cellActionDelegate = cellActionDelegate
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
            fatalError("Failed to dequeue CollectionViewCell.")
        }
        
        guard indexPath.item < viewModels.count else {
            print("Error: Index out of range in cellForItemAt. Index: \(indexPath.item), ViewModels count: \(viewModels.count)")
            return cell // Return an empty or placeholder cell
        }
        
        let viewModel = viewModels[indexPath.item]
        // Corrected: Call the new configure method in CollectionViewCell
        cell.configure(with: viewModel, at: indexPath)
        
        // Corrected: Assign the delegate for cell actions (like favorite button)
        cell.actionDelegate = self.cellActionDelegate
        
        return cell
    }
}
