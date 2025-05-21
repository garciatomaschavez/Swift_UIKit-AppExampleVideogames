//
//  VideogameListViewController.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//  Refactored for programmatic UI, Search, and Menu
//

import UIKit

class VideogameListViewController: UIViewController, VideogameListViewProtocol {

    var presenter: (any VideogameListPresenterProtocol)?

    // --- UI Elements ---
    private var searchController: UISearchController!
    private var collectionView: UICollectionView!
    private var activityIndicator: UIActivityIndicatorView!
    private var emptyStateLabel: UILabel!
    
    private let refreshControl = UIRefreshControl()
    private var viewModels: [VideogameListViewModel] = [] {
        didSet {
            DispatchQueue.main.async {
                print("VideogameListVC: viewModels.didSet - count: \(self.viewModels.count)")
                self.collectionView?.reloadData()
                self.updateEmptyStateVisibility()
            }
        }
    }
    
    private var currentHeartColor: UIColor = FavoriteColorService.loadFavoriteColor()
    private var hasConfiguredLayout = false // Flag to ensure layout is configured only once if needed

    override func loadView() {
        super.loadView()
        print("VideogameListVC: loadView called")
        
        self.view = UIView()
        self.view.backgroundColor = .systemGroupedBackground

        // Initialize layout here, but don't set itemSize yet
        let layout = UICollectionViewFlowLayout()
        // Default estimated item size can help if actual sizes are deferred
        // layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray

        emptyStateLabel = UILabel()
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "\(NSLocalizedString("No_videogames_found", comment: ""))"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true

        self.view.addSubview(collectionView)
        self.view.addSubview(activityIndicator)
        self.view.addSubview(emptyStateLabel)

        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("VideogameListVC: viewDidLoad called")
        configureNavigationBar()
        configureSearchController()
        configureCollectionViewFramework() // Renamed from configureUIFrameworks
        
        if presenter == nil {
            print("VideogameListVC: PRESENTER IS NIL at viewDidLoad!")
        }
        presenter?.viewDidLoad()
        print("VideogameListVC: presenter.viewDidLoad() called")
        updateEmptyStateVisibility()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("VideogameListVC: viewDidLayoutSubviews called, view.bounds: \(view.bounds)")
        // Configure layout here, as view.bounds is reliable.
        // Use a flag to ensure it's only done once if the layout doesn't need to change dynamically
        // or if it's not dependent on bounds that change frequently after initial setup.
        if !hasConfiguredLayout && view.bounds.width > 0 {
            configureCollectionViewLayout()
            hasConfiguredLayout = true // Set flag after first successful configuration
            print("VideogameListVC: CollectionView layout configured in viewDidLayoutSubviews")
        }
    }


    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureNavigationBar() {
        title = "\(NSLocalizedString("Videogames_title", comment: ""))"
        navigationController?.navigationBar.prefersLargeTitles = true

        let menuImage = UIImage(systemName: "ellipsis.circle")
        let menuButton = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: nil)
        
        let refreshAction = UIAction(title: "\(NSLocalizedString("Refresh_from_API", comment: ""))", image: UIImage(systemName: "arrow.clockwise")) { [weak self] _ in
            print("VideogameListVC: Refresh menu item tapped")
            self?.presenter?.refreshTriggered()
        }
        
        let changeColorAction = UIAction(title: "\(NSLocalizedString("Change_Heart_Color", comment: ""))", image: UIImage(systemName: "paintbrush")) { [weak self] _ in
            self?.showChangeHeartColorMenu()
        }
        
        menuButton.menu = UIMenu(title: "", children: [refreshAction, changeColorAction])
        navigationItem.rightBarButtonItem = menuButton
    }

    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search_videogame_by_title_text_hint", comment: "")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureCollectionViewFramework() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        // DO NOT CALL configureCollectionViewLayout() here anymore. It's called in viewDidLayoutSubviews.

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
    }
    
    private func configureCollectionViewLayout() {
        // This method is now called from viewDidLayoutSubviews
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            print("VideogameListVC: configureCollectionViewLayout - FlowLayout not found.")
            return
        }
        
        // Ensure view.bounds.width is valid before calculating
        guard view.bounds.width > 0 else {
            print("VideogameListVC: configureCollectionViewLayout - view.bounds.width is zero, cannot configure layout yet.")
            return
        }
        
        let padding: CGFloat = 16
        let availableWidth = view.bounds.width - (padding * 3)
        let itemWidth = floor(availableWidth / 2)
        
        // Ensure itemWidth is positive
        guard itemWidth > 0 else {
            print("VideogameListVC: configureCollectionViewLayout - Calculated itemWidth is not positive (\(itemWidth)). availableWidth: \(availableWidth)")
            // Set a default minimum size or handle error, for now, we just return to avoid crash
            // layout.itemSize = CGSize(width: 50, height: 50) // Fallback, not ideal
            return
        }
        
        let itemHeight = itemWidth * 1.35
        guard itemHeight > 0 else {
            print("VideogameListVC: configureCollectionViewLayout - Calculated itemHeight is not positive (\(itemHeight)).")
            return
        }

        print("VideogameListVC: configureCollectionViewLayout - Setting itemSize to: w:\(itemWidth), h:\(itemHeight)")
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        
        // After setting layout properties, you might need to invalidate the layout if it was already laid out
        // layout.invalidateLayout() // Use with caution, can be expensive. Often not needed if configured before first layout pass.
    }
    
    private func updateEmptyStateVisibility() {
        let isLoading = activityIndicator?.isAnimating ?? false
        if !viewModels.isEmpty {
            emptyStateLabel?.isHidden = true
            collectionView?.isHidden = false
            print("VideogameListVC: updateEmptyStateVisibility - Data available, showing collection view.")
        } else if isLoading {
            emptyStateLabel?.isHidden = true
            collectionView?.isHidden = true
            print("VideogameListVC: updateEmptyStateVisibility - Loading, hiding empty state and collection view.")
        } else {
            emptyStateLabel?.isHidden = false
            collectionView?.isHidden = true
            print("VideogameListVC: updateEmptyStateVisibility - No data and not loading, showing empty state.")
        }
    }

    @objc private func didPullToRefresh(_ sender: Any) {
        print("VideogameListVC: Pull to refresh triggered")
        presenter?.refreshTriggered()
    }
    
    private func showChangeHeartColorMenu() {

        let alertController = UIAlertController(title: "\(NSLocalizedString("Choose_Heart_Color", comment: ""))", message: nil, preferredStyle: .actionSheet)

        for colorNameCase in FavoriteColorService.ColorName.allCases {
            let action = UIAlertAction(title: colorNameCase.displayName, style: .default) { [weak self] _ in
                guard let self = self else { return }
                let selectedColor = colorNameCase.uiColor
                self.currentHeartColor = selectedColor
                FavoriteColorService.saveFavoriteColor(selectedColor)
                self.collectionView.reloadData()
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alertController, animated: true)
    }

    // MARK: - VideogameListViewProtocol Conformance
    func showLoading() {
        print("VideogameListVC: showLoading called")
        DispatchQueue.main.async {
            if !self.refreshControl.isRefreshing {
                self.activityIndicator?.startAnimating()
            }
            self.updateEmptyStateVisibility()
        }
    }

    func hideLoading() {
        print("VideogameListVC: hideLoading called")
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.refreshControl.endRefreshing()
            self.updateEmptyStateVisibility()
        }
    }

    func displayVideogames(_ videogames: [VideogameListViewModel]) {
        print("VideogameListVC: displayVideogames called with \(videogames.count) items")
        self.viewModels = videogames
    }

    func displayError(title: String, message: String) {
        print("VideogameListVC: displayError called - Title: \(title), Message: \(message)")
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.refreshControl.endRefreshing()
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
            
            self.emptyStateLabel?.text = message
            self.viewModels = []
        }
    }
    
    func displayNoVideogames() {
        print("VideogameListVC: displayNoVideogames called")
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.refreshControl.endRefreshing()

            self.viewModels = []
            self.emptyStateLabel?.text = "No videogames available."
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension VideogameListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("VideogameListVC: numberOfItemsInSection - returning \(viewModels.count)")
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("VideogameListVC: cellForItemAt - indexPath: \(indexPath.item)")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            fatalError("Unable to dequeue CollectionViewCell with identifier '\(CollectionViewCell.identifier)'.")
        }
        // Ensure viewModels array is not empty and indexPath is valid
        guard indexPath.item < viewModels.count else {
            print("VideogameListVC: cellForItemAt - IndexPath out of bounds: \(indexPath.item) for viewModels count: \(viewModels.count)")
            // Return a configured empty cell or handle appropriately
            return cell // Or a placeholder cell
        }
        let viewModel = viewModels[indexPath.item]
        
        cell.configure(with: viewModel, heartColor: currentHeartColor)
        
        cell.favoriteButtonTapHandler = { [weak self] in
            // Ensure viewModel is captured correctly if needed, or fetch by ID
            self?.presenter?.didTapFavoriteButton(forVideogameId: viewModel.businessKeyId)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ensure viewModels array is not empty and indexPath is valid
        guard indexPath.item < viewModels.count else {
            print("VideogameListVC: didSelectItemAt - IndexPath out of bounds: \(indexPath.item) for viewModels count: \(viewModels.count)")
            return
        }
        let viewModel = viewModels[indexPath.item]
        presenter?.didSelectVideogame(withId: viewModel.businessKeyId)
    }
}

// MARK: - UISearchResultsUpdating
extension VideogameListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        // TODO: Inform presenter about the search text
        // Example: presenter?.searchVideogames(withTitle: searchText)
        print("VideogameListVC: Search text: \(searchText)")
        
        // Basic implementation:
        // if searchText.isEmpty && !searchController.isActive { // Or some other condition to reset
        //    presenter?.viewDidLoad() // Or a specific fetchAll method
        // } else if !searchText.isEmpty {
        //    presenter?.searchVideogames(query: searchText) // Needs to be added to protocol & presenter
        // }
    }
}
