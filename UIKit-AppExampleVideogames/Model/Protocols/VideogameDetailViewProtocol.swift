//
//  VideogameDetailViewProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

// Protocol for the Detail View (to be implemented by SheetViewController)
protocol VideogameDetailViewProtocol: AnyObject {
    func displayVideogameDetails(_ viewModel: VideogameDetailViewModel)
    func displayLoading(_ isLoading: Bool)
    func displayError(title: String, message: String)
    // func updateFavoriteStatusInView(isFavorite: Bool) // If detail view can toggle favorite
}

// Protocol for the Detail Presenter
protocol VideogameDetailPresenterProtocol: AnyObject {
    var view: VideogameDetailViewProtocol? { get set }

    func viewDidLoad() // Called when the detail view is loaded
    // func didTapFavoriteButton() // If detail view can toggle favorite
    // func didTapOpenDeveloperWebsite() // If there's a button for this
}
