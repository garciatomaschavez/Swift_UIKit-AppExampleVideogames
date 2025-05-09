//
//  CollectionViewDelegate.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/4/25.
//

import Foundation
import UIKit

// Protocol MyCollectionViewCellDelegate is now VideogameCellSelectionDelegate (defined elsewhere)
// and VideogameCellActionDelegate (defined elsewhere)

final class CollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // This delegate is for cell *selection* (tapping the whole cell)
    weak var selectionDelegate: VideogameCellSelectionDelegate?
    
    // No longer needs to hold viewModels unless used for layout calculations that depend on content.
    // private var viewModels: [VideogameViewModel] = []

    // Initializer can be simplified if it doesn't hold data
    init(selectionDelegate: VideogameCellSelectionDelegate? = nil) {
        self.selectionDelegate = selectionDelegate
    }
    
    // If it needs to be updated with viewModels (e.g., for complex layouts)
    // func update(with viewModels: [VideogameViewModel]) {
    //     self.viewModels = viewModels
    // }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // No longer fetches data here. Just informs its delegate about the tap.
        print("CollectionViewDelegate: Cell at \(indexPath) was selected.")
        selectionDelegate?.didSelectVideogame(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Your existing sizing logic.
        // For a two-column layout:
        let paddingSpace = CGFloat(10 * 3) // Assuming 10 for left, middle, right insets/spacing
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / 2
        return CGSize(width: widthPerItem, height: widthPerItem * 1.6) // Adjust height multiplier as needed for content
        
        // Original:
        // let width = collectionView.bounds.width - 20
        // return CGSize(width: width, height: 400)
    }
    
    // Add minimum spacing if not set in FlowLayout initialization
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
