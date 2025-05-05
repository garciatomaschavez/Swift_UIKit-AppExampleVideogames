//
//  CollectionViewDataSource.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/4/25.
//

import Foundation
import UIKit

final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    init(dataSource: [Videogame]) { }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreDataService.fetchAllVideogames().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
         let videogames = CoreDataService.fetchAllVideogames()
         guard indexPath.row < videogames.count else {
             print("Index out of range in cellForItemAt")
             return cell // Or handle the error as appropriate
         }
         let model = videogames[indexPath.row]
         cell.configure(model: model)
         return cell
     }
    
}


