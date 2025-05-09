//
//  SheetViewController.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/4/25.
//

import UIKit

class SheetViewController: UIViewController {
    
    // Presenter - This will be injected
    var presenter: VideogameDetailPresenterProtocol! // Needs to be set up

    let bottomSheetContentView = BottomSheetContentView()
    
    // Activity indicator for loading state
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // Custom initializer to accept the presenter (or necessary IDs for the presenter)
    // The presenter will be responsible for fetching the data.
    init(presenter: VideogameDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    // If you were to initialize with just an ID for the presenter to use:
    // init(videogameId: UUID, /* other dependencies for presenter */) {
    //     // Create presenter here, e.g.:
    //     // let getVideogameByIdUseCase = ...
    //     // self.presenter = VideogameDetailPresenter(videogameId: videogameId, getVideogameByIdUseCase: getVideogameByIdUseCase)
    //     super.init(nibName: nil, bundle: nil)
    // }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(presenter:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // Match BottomSheetContentView or use clear

        setupUI()
        
        assert(presenter != nil, "Presenter must be set for SheetViewController.")
        presenter.view = self // Link presenter to this view
        presenter.viewDidLoad() // Tell presenter the view is ready

        setupSheetPresentation()
    }
    
    private func setupUI() {
        bottomSheetContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomSheetContentView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            bottomSheetContentView.topAnchor.constraint(equalTo: view.topAnchor),
            bottomSheetContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - VideogameDetailViewProtocol Conformance
extension SheetViewController: VideogameDetailViewProtocol {
    func displayVideogameDetails(_ viewModel: VideogameDetailViewModel) {
        DispatchQueue.main.async {
            self.bottomSheetContentView.configure(with: viewModel)
        }
    }

    func displayLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.activityIndicator.startAnimating()
                self.bottomSheetContentView.isHidden = true // Optionally hide content while loading
            } else {
                self.activityIndicator.stopAnimating()
                self.bottomSheetContentView.isHidden = false
            }
        }
    }

    func displayError(title: String, message: String) {
        DispatchQueue.main.async {
            // You might want to show an error state in the bottom sheet itself,
            // or dismiss it and show an alert on the presenting view controller.
            self.showAlert(title: title, message: message)
            // Potentially dismiss if the error is critical
            // self.dismiss(animated: true, completion: nil)
        }
    }
}
