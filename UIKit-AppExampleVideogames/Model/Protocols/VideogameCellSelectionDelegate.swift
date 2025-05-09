//
//  VideogameCellSelectionDelegate.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import UIKit

// Protocol for handling cell selection events.
// The CollectionViewDelegate will use this to notify its own delegate (the ViewController).
protocol VideogameCellSelectionDelegate: AnyObject {
    func didSelectVideogame(at indexPath: IndexPath)
}

// Protocol for handling actions originating from within a cell, like a button tap.
// The CollectionViewCell will use this to notify its delegate (likely the ViewController, via the DataSource).
protocol VideogameCellActionDelegate: AnyObject {
    func didTapFavoriteButton(on cell: UICollectionViewCell, at indexPath: IndexPath)
    // Add other actions if needed, e.g., didTapShareButton, etc.
}
