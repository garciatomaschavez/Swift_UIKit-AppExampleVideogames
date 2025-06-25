//
//  ViperComponentProtocols.swift
//  UIKit-AppExampleVideogames
//  
//  Created by tom on 23/05/25.
//
//

import UIKit

// MARK: - Base VIPER Component Protocols

/// Base protocol for a VIPER View.
/// Requires a `presenter` property of an associated type.
protocol ViperViewProtocol: AnyObject {
    associatedtype PresenterType // This will be the specific Presenter protocol for the module
    var presenter: PresenterType? { get set }
}

/// Base protocol for a VIPER Presenter.
/// Requires `view`, `interactor`, and `router` properties of associated types.
protocol ViperPresenterProtocol: AnyObject {
    associatedtype ViewType // Specific View protocol
    associatedtype InteractorInputType // Specific Interactor Input protocol
    associatedtype RouterType // Specific Router protocol (for instance methods)

    var view: ViewType? { get set }
    var interactor: InteractorInputType? { get set }
    var router: RouterType? { get set }
}

/// Base protocol for a VIPER Interactor (Input).
/// Requires a `presenter` property (for output) of an associated type.
protocol ViperInteractorInputProtocol: AnyObject {
    associatedtype InteractorOutputType // This is typically the Presenter, conforming to the Interactor's output protocol
    var presenter: InteractorOutputType? { get set }
}

/// Base protocol for a VIPER Router (instance).
protocol ViperRouterProtocol: AnyObject {
    // weak var viewController: UIViewController? { get set } // Example if router instance needs VC
}


// MARK: - Generic VIPER Wiring Helper

struct ViperModuleBuilder {
    
    /// Wires together the components of a VIPER module.
    ///
    /// - Parameters:
    ///   - view: The View component (must be a UIViewController and conform to ViperViewProtocol).
    ///   - presenter: The Presenter component (must conform to ViperPresenterProtocol).
    ///   - interactor: The Interactor component (must conform to ViperInteractorInputProtocol).
    ///   - router: The Router instance component (must conform to ViperRouterProtocol).
    ///
    /// This version uses simpler generic constraints and relies on dynamic casts
    /// to ensure type compatibility for assignments. `fatalError` is used to catch
    /// incorrect wiring during development.
    static func wire<V, P, I, R>(
        view: V,
        presenter: P,
        interactor: I,
        router: R
    ) where V: UIViewController, V: ViperViewProtocol,
              P: ViperPresenterProtocol,
              I: ViperInteractorInputProtocol,
              R: ViperRouterProtocol
    {
        // Assign presenter to view
        // V.PresenterType is the protocol type the View expects for its presenter.
        // P is the concrete presenter instance. P must conform to V.PresenterType.
        guard let viewPresenter = presenter as? V.PresenterType else {
            fatalError("Presenter (type \(type(of: presenter))) cannot be assigned to View's presenter (expected type \(V.PresenterType.self))")
        }
        view.presenter = viewPresenter

        // Assign view to presenter
        // P.ViewType is the protocol type the Presenter expects for its view.
        // V is the concrete view instance. V must conform to P.ViewType.
        guard let presenterView = view as? P.ViewType else {
            fatalError("View (type \(type(of: view))) cannot be assigned to Presenter's view (expected type \(P.ViewType.self))")
        }
        presenter.view = presenterView
        
        // Assign interactor to presenter
        // P.InteractorInputType is the protocol type the Presenter expects for its interactor.
        // I is the concrete interactor instance. I must conform to P.InteractorInputType.
        guard let presenterInteractor = interactor as? P.InteractorInputType else {
            fatalError("Interactor (type \(type(of: interactor))) cannot be assigned to Presenter's interactor (expected type \(P.InteractorInputType.self))")
        }
        presenter.interactor = presenterInteractor

        // Assign router to presenter
        // P.RouterType is the protocol type the Presenter expects for its router.
        // R is the concrete router instance. R must conform to P.RouterType.
        guard let presenterRouter = router as? P.RouterType else {
            fatalError("Router (type \(type(of: router))) cannot be assigned to Presenter's router (expected type \(P.RouterType.self))")
        }
        presenter.router = presenterRouter
        
        // Assign presenter to interactor (as output)
        // I.InteractorOutputType is the protocol type the Interactor expects for its output (presenter).
        // P is the concrete presenter instance. P must conform to I.InteractorOutputType.
        guard let interactorPresenterAsOutput = presenter as? I.InteractorOutputType else {
            fatalError("Presenter (type \(type(of: presenter))) cannot be assigned to Interactor's presenter/output (expected type \(I.InteractorOutputType.self))")
        }
        interactor.presenter = interactorPresenterAsOutput
    }
}
