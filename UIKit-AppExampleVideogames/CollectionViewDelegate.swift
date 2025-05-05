//
//  CollectionViewDelegate.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/4/25.
//

import Foundation
import UIKit

protocol MyCollectionViewCellDelegate: AnyObject {
    func didSelectCell(at indexPath: IndexPath, with data: Videogame) // Customize 'data' as needed
}

final class CollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var cellSelectionDelegate: MyCollectionViewCellDelegate?
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let videogames = CoreDataService.fetchAllVideogames()
            guard indexPath.row < videogames.count else {
                print("Index out of range")
                return // Or handle the error as appropriate for your app
            }
        
        let model = videogames[indexPath.row]
        print("Clicked on: \(model.title ?? "Unknown Title")")
            
        cellSelectionDelegate?.didSelectCell(at: indexPath, with: model)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the full width of the collection view minus some padding
        let width = collectionView.bounds.width - 20 // 10 points padding on each side
        return CGSize(width: width, height: 400)
    }
    
    

}
