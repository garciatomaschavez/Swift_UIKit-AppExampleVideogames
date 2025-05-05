//
//  ViewController.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/4/25.
//

import UIKit

let DEBUG_ENABLED = true

class ViewController: UIViewController, MyCollectionViewCellDelegate {
    private var dataSource: CollectionViewDataSource?
    private var delegate: CollectionViewDelegate?
    private var myCollectionViewCellDelegate: MyCollectionViewCellDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the Videogames from Core Data
        let videogames = CoreDataService.fetchAllVideogames()
        self.dataSource = CollectionViewDataSource(dataSource: videogames)
        self.delegate = CollectionViewDelegate()
        
        
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        
        delegate?.cellSelectionDelegate = self
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        
        self.setupUI()
    }
    
    private func setupUI() {
        self.collectionView.backgroundColor = .blue
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        ])
    }
    
    func didSelectCell(at indexPath: IndexPath, with data: Videogame) {
        let viewControllerToPresent = SheetViewController(data: data)
        
        present(viewControllerToPresent, animated: true)
    }

}
