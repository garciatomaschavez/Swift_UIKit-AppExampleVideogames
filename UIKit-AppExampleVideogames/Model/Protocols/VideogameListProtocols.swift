//
//  VideogameListViewProtocol.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

// Protocol for the View (to be implemented by ViewController)
// Defines methods the Presenter can call to update the UI.
protocol VideogameListViewProtocol: AnyObject {
    func displayLoading(_ isLoading: Bool)
    func displayVideogames(_ videogames: [VideogameViewModel])
    func displayError(title: String, message: String)
    func refreshVideogame(at index: Int, with viewModel: VideogameViewModel)
    
    // Added this method for navigation to the detail screen
    func navigateToDetailScreen(for videogameId: UUID)
}

// Protocol for the Presenter (to be implemented by VideogameListPresenter)
// Defines methods the View can call to inform the Presenter of UI events or lifecycle methods.
protocol VideogameListPresenterProtocol: AnyObject {
    var view: VideogameListViewProtocol? { get set }

    func viewDidLoad()
    func didSelectVideogame(at index: Int)
    func didToggleFavorite(forVideogameId id: UUID, at index: Int)
    func refreshDataRequested()
}


// You might also define a protocol for the Router if navigation becomes complex,
// but for now, we can handle simple navigation within the Presenter or have the View do it
// based on Presenter's instructions.
