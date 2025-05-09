//
//  ViewController.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/4/25.
//

import UIKit

// let DEBUG_ENABLED = true // This can stay if you use it for debugging prints

class ViewController: UIViewController {
    
    var presenter: VideogameListPresenterProtocol!
    private var videogameViewModels: [VideogameViewModel] = []
    
    private var mainDataSource: CollectionViewDataSource?
    private var mainDelegate: CollectionViewDelegate?
    
    var getVideogameByIdUseCase: GetVideogameByIdUseCase!

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.backgroundColor = .systemGroupedBackground
        return collectionView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController: viewDidLoad.")
        
        assert(presenter != nil, "Presenter must be injected before viewDidLoad.")
        assert(getVideogameByIdUseCase != nil, "GetVideogameByIdUseCase must be injected before viewDidLoad.")
        presenter.view = self

        setupUI()
        setupCollectionViewLogic()
        
        print("ViewController: Calling presenter.viewDidLoad().")
        presenter.viewDidLoad()
    }

    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.title = "Videogames"
        
        self.view.addSubview(collectionView)
        self.view.addSubview(activityIndicator)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupCollectionViewLogic() {
        print("ViewController: Setting up collection view data source and delegate.")
        self.mainDataSource = CollectionViewDataSource(viewModels: self.videogameViewModels, cellActionDelegate: self)
        self.mainDelegate = CollectionViewDelegate(selectionDelegate: self)
        
        collectionView.dataSource = mainDataSource
        collectionView.delegate = mainDelegate
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

extension ViewController: VideogameListViewProtocol {
    func displayLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            print("ViewController: displayLoading - \(isLoading)")
            if isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }

    func displayVideogames(_ viewModels: [VideogameViewModel]) {
        DispatchQueue.main.async {
            print("ViewController: displayVideogames - Received \(viewModels.count) view models.")
            self.videogameViewModels = viewModels
            self.mainDataSource?.update(with: viewModels)
            self.collectionView.reloadData()
            if viewModels.isEmpty {
                print("ViewController: No view models to display. CollectionView might appear empty.")
            }
        }
    }

    func displayError(title: String, message: String) {
        DispatchQueue.main.async {
            print("ViewController: displayError - Title: \(title), Message: \(message)")
            self.showAlert(title: title, message: message)
        }
    }
    
    func refreshVideogame(at index: Int, with viewModel: VideogameViewModel) {
        DispatchQueue.main.async {
            print("ViewController: refreshVideogame at index \(index).")
            guard index < self.videogameViewModels.count else { return }
            self.videogameViewModels[index] = viewModel
            self.mainDataSource?.updateViewModel(viewModel, at: index)
            
            let indexPath = IndexPath(item: index, section: 0)
            if self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
                 self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func navigateToDetailScreen(for videogameId: UUID) {
        print("ViewController: navigateToDetailScreen for ID \(videogameId).")
        let detailPresenter = VideogameDetailPresenter(
            videogameId: videogameId,
            getVideogameByIdUseCase: self.getVideogameByIdUseCase
        )
        let sheetVC = SheetViewController(presenter: detailPresenter)
        present(sheetVC, animated: true, completion: nil)
    }
}

extension ViewController: VideogameCellSelectionDelegate {
    func didSelectVideogame(at indexPath: IndexPath) {
        print("ViewController: VideogameCellSelectionDelegate - didSelectVideogame at \(indexPath.item).")
        presenter.didSelectVideogame(at: indexPath.item)
    }
}

extension ViewController: VideogameCellActionDelegate {
    func didTapFavoriteButton(on cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard indexPath.item < videogameViewModels.count else { return }
        let selectedViewModel = videogameViewModels[indexPath.item]
        print("ViewController: VideogameCellActionDelegate - didTapFavoriteButton for \(selectedViewModel.name) at index \(indexPath.item).")
        presenter.didToggleFavorite(forVideogameId: selectedViewModel.id, at: indexPath.item)
    }
}
