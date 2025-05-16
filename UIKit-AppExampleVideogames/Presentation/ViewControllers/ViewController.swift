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

    // currentHeartColor will now be initialized from UserDefaults
    private var currentHeartColor: UIColor = FavoriteColorService.loadFavoriteColor() {
        didSet {
            if oldValue != currentHeartColor { // Only reload if the color actually changed
                print("ViewController: currentHeartColor changed to \(currentHeartColor). Reloading collection view.")
                collectionView.reloadData() // Reload to update cell heart colors
            }
        }
    }

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

        // Load initial color when view loads (already done by property initializer)
        // currentHeartColor = FavoriteColorService.loadFavoriteColor() // This line is redundant due to property initializer

        setupNavigationBar()
        setupUI()
        setupCollectionViewLogic() // This will now use the initially loaded currentHeartColor
        
        print("ViewController: Calling presenter.viewDidLoad().")
        presenter.viewDidLoad()
    }

    private func setupNavigationBar() {
        self.title = "Videogames"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefreshButton))
        navigationItem.rightBarButtonItem = refreshButton
        let colorPickerButton = UIBarButtonItem(image: UIImage(systemName: "paintpalette"), style: .plain, target: self, action: #selector(didTapChangeColorButton))
        navigationItem.leftBarButtonItem = colorPickerButton
    }

    private func setupUI() {
        self.view.backgroundColor = .systemBackground
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
        self.mainDataSource = CollectionViewDataSource(
            viewModels: self.videogameViewModels,
            cellActionDelegate: self,
            heartColorProvider: { [weak self] in
                // This closure now provides the up-to-date color
                return self?.currentHeartColor ?? FavoriteColorService.loadFavoriteColor()
            }
        )
        self.mainDelegate = CollectionViewDelegate(selectionDelegate: self)
        
        collectionView.dataSource = mainDataSource
        collectionView.delegate = mainDelegate
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    @objc private func didTapRefreshButton() {
        print("ViewController: Refresh button tapped.")
        presenter.refreshDataRequested()
    }

    @objc private func didTapChangeColorButton() {
        print("ViewController: Change Color button tapped.")
        let alertController = UIAlertController(title: "Choose Heart Color", message: nil, preferredStyle: .actionSheet)

        // Use the ColorName enum from FavoriteColorService to populate actions
        for colorNameCase in FavoriteColorService.ColorName.allCases {
            let action = UIAlertAction(title: colorNameCase.rawValue.replacingOccurrences(of: "system", with: "").capitalized, style: .default) { [weak self] _ in
                let selectedColor = colorNameCase.uiColor
                self?.currentHeartColor = selectedColor // Update property (triggers didSet)
                FavoriteColorService.saveFavoriteColor(selectedColor) // Save to UserDefaults
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.leftBarButtonItem
        }
        present(alertController, animated: true)
    }
}

// MARK: - VideogameListViewProtocol Conformance
extension ViewController: VideogameListViewProtocol {
    func displayLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading { self.activityIndicator.startAnimating() }
            else { self.activityIndicator.stopAnimating() }
        }
    }

    func displayVideogames(_ viewModels: [VideogameViewModel]) {
        DispatchQueue.main.async {
            self.videogameViewModels = viewModels
            self.mainDataSource?.update(with: viewModels)
            self.collectionView.reloadData()
        }
    }

    func displayError(title: String, message: String) {
        DispatchQueue.main.async { self.showAlert(title: title, message: message) }
    }
    
    func refreshVideogame(at index: Int, with viewModel: VideogameViewModel) {
        DispatchQueue.main.async {
            guard index < self.videogameViewModels.count else { return }
            self.videogameViewModels[index] = viewModel
            self.mainDataSource?.updateViewModel(viewModel, at: index)
            let indexPath = IndexPath(item: index, section: 0)
            if self.collectionView.indexPathsForVisibleItems.contains(indexPath) ||
               self.collectionView.dataSource?.collectionView(self.collectionView, cellForItemAt: indexPath) != nil {
                 self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func navigateToDetailScreen(for videogameId: UUID) {
        guard let getVideogameByIdUseCase = self.getVideogameByIdUseCase else {
            showAlert(title: "Error", message: "Cannot open details at the moment.")
            return
        }
        let detailPresenter = VideogameDetailPresenter(
            videogameId: videogameId,
            getVideogameByIdUseCase: getVideogameByIdUseCase
        )
        let sheetVC = SheetViewController(presenter: detailPresenter)
        present(sheetVC, animated: true, completion: nil)
    }
}

// MARK: - Delegate Conformances
extension ViewController: VideogameCellSelectionDelegate {
    func didSelectVideogame(at indexPath: IndexPath) {
        presenter.didSelectVideogame(at: indexPath.item)
    }
}

extension ViewController: VideogameCellActionDelegate {
    func didTapFavoriteButton(on cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard indexPath.item < videogameViewModels.count else { return }
        let selectedViewModel = videogameViewModels[indexPath.item]
        presenter.didToggleFavorite(forVideogameId: selectedViewModel.id, at: indexPath.item)
    }
}
