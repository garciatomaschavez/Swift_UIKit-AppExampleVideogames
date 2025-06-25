//
//  VideogameDetailViewController.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/4/25.
//

import UIKit

class VideogameDetailViewController: UIViewController, VideogameDetailViewProtocol {
    
    var presenter: (any VideogameDetailPresenterProtocol)? // Conforms to the protocol

    // Assuming BottomSheetContentView is now at Modules/VideogameDetail/Views/
    // and you've added a favorite button to it.
    let bottomSheetContentView = BottomSheetContentView()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray // Ensure it's visible on the sheet background
        return indicator
    }()

    // Removed: selectedVideogameBusinessKey: String?
    // The presenter, injected by the router, will manage the ID.

    // The router will be responsible for creating this ViewController and injecting the presenter.
    // Thus, a custom init might not be strictly necessary here if properties are set post-init by the router.
    // However, for clarity in VIPER, routers often call a setup method on the VC or set properties directly.
    // If an init is needed, it would be parameterless or take only what the storyboard/system needs.

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        
        // Setup action for the favorite button in BottomSheetContentView
        // This requires BottomSheetContentView to expose a way to handle this.
        // Example: bottomSheetContentView.favoriteButtonTapHandler = { [weak self] in
        //    self?.presenter?.didTapFavoriteButton()
        // }
        // For now, we'll assume a direct action or a delegate pattern.
        // If BottomSheetContentView has a public favoriteButton:
        // bottomSheetContentView.favoriteButton.addTarget(self, action: #selector(didTapFavoriteInSheet), for: .touchUpInside)


        assert(presenter != nil, "Presenter must be set for VideogameDetailViewController.")
        presenter?.view = self
        presenter?.viewDidLoad()

        setupSheetPresentation()
    }
    
    private func setupUI() {
        bottomSheetContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomSheetContentView)
        view.addSubview(activityIndicator) // Add activity indicator to the view hierarchy

        NSLayoutConstraint.activate([
            bottomSheetContentView.topAnchor.constraint(equalTo: view.topAnchor),
            bottomSheetContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Example: Adding a favorite button programmatically if not in BottomSheetContentView
        // let favoriteButton = UIButton(type: .system)
        // favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal) // Configure as needed
        // favoriteButton.addTarget(self, action: #selector(didTapFavoriteButtonAction), for: .touchUpInside)
        // favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        // view.addSubview(favoriteButton)
        // NSLayoutConstraint.activate([
        //     favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        //     favoriteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        //     favoriteButton.widthAnchor.constraint(equalToConstant: 44),
        //     favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        // ])
        // self.favoriteButton = favoriteButton // Store reference if needed to update its state
    }

    private func setupSheetPresentation() {
        guard let presentationController = presentationController as? UISheetPresentationController else {
            return
        }
        presentationController.detents = [.medium(), .large()]
        presentationController.selectedDetentIdentifier = .medium
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 20
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            // Optionally dismiss the detail view on critical errors or specific user actions
            // if title == "Error" { // Example condition
            //     self?.presenter?.router?.dismissDetailView(from: self!)
            // }
        }))
        present(alertController, animated: true)
    }

    // Example action for a favorite button if it's part of this VC directly
    // @objc private func didTapFavoriteButtonAction() {
    //     presenter?.didTapFavoriteButton()
    // }

    // MARK: - VideogameDetailViewProtocol Conformance

    func displayVideogameDetails(_ viewModel: VideogameDetailViewModel) {
        DispatchQueue.main.async {
            self.bottomSheetContentView.configure(with: viewModel)
            // If you added a favorite button directly to this VC, update its state:
            // self.favoriteButton?.isSelected = viewModel.isFavorite
            // self.favoriteButton?.tintColor = viewModel.isFavorite ? .red : .gray
        }
    }

    func showLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.bottomSheetContentView.isHidden = true
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.bottomSheetContentView.isHidden = false
        }
    }

    func displayError(title: String, message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating() // Ensure loading is stopped
            self.bottomSheetContentView.isHidden = true // Hide content on error
            self.showAlert(title: title, message: message)
        }
    }

    // Example: If view needs to update favorite status independently
    // func updateFavoriteStatusInView(isFavorite: Bool) {
    //     DispatchQueue.main.async {
    //         // Update your favorite button's appearance
    //         // self.favoriteButton?.isSelected = isFavorite
    //         // self.favoriteButton?.tintColor = isFavorite ? .red : .gray
    //         print("Detail View: Favorite status updated to \(isFavorite)")
    //     }
    // }
}
