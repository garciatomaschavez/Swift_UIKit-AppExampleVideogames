//
//  SheetViewController.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/4/25.
//

import UIKit

//protocol SheetViewControllerDelegate: AnyObject {
//    func sheetViewControllerDidDismiss(with data: Any?)
//    func sheetViewControllerDidPerformAction(at indexPath: IndexPath, with updatedData: Any?)
//}

class SheetViewController: UIViewController {
//    private var delegate: SheetPresentationControllerDelegate?
    let contentView = BottomSheetContentView()
    var dataToShow: Videogame
    var selectedIndexPath: IndexPath?

    // MARK: - Initializers

    // Custom initializer to ensure 'dataToShow' is provided
    init(data: Videogame, indexPath: IndexPath? = nil) {
        self.dataToShow = data
        self.selectedIndexPath = indexPath
        super.init(nibName: nil, bundle: nil) // Call the designated initializer of UIViewController
    }

    // Required initializer for when the view controller is loaded from a storyboard or nib
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // Or implement if you load from storyboard/nib
    }

    // ... your other UI elements and logic ...
    

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        delegate?.sheetViewControllerDidDismiss(with: nil)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.configure(with: dataToShow,
                       images: [UIImage(named: "images/lol/1"), UIImage(named: "images/lol/2")])
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
        contentView.topAnchor.constraint(equalTo: view.topAnchor),
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        guard let presentationController = presentationController as? UISheetPresentationController else {
        return
        }

        presentationController.detents = [.medium(), .large()]
        presentationController.selectedDetentIdentifier = .medium
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 20
    }
    
    
//    @IBAction func saveChangesButtonTapped(_ sender: UIButton) {
//        guard let indexPath = selectedIndexPath, let updatedData = /* get updated data from UI */ else { return }
//        delegate?.sheetViewControllerDidPerformAction(at: indexPath, with: updatedData)
//        dismiss(animated: true, completion: nil)
//    }
}


/*
 
class SheetViewController: UIViewController {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Follow for more!"
        label.font = .systemFont(ofSize: 32)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        
        view.backgroundColor = .purple
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        guard let presentationController = presentationController as? UISheetPresentationController else {
            return
        }
    
        presentationController.detents = [.medium(), .large()]
        presentationController.selectedDetentIdentifier = .medium
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 20
    }
    
    func show
}

 */
