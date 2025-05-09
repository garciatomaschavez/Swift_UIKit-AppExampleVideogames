//
//  CollectionViewCell.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/4/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "MainVideogameCollectionViewCell"
    
    weak var actionDelegate: VideogameCellActionDelegate?
    private var currentViewModelId: UUID? // Store ID for delegate calls
    private var currentIndexPath: IndexPath?

    // UI Elements
    private let platformInfoStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        // stackView.layer.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.7).cgColor // For debug
        stackView.layer.cornerRadius = 6
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        return stackView
    }()
    
    private let developerInfoStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        // stackView.layer.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.7).cgColor // For debug
        stackView.layer.cornerRadius = 8
        stackView.axis = .horizontal // Changed to horizontal for logo + name
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        return stackView
    }()
    
    private let headerStackView: UIStackView = { // Contains game logo and name
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let videogameLogoImageView: UIImageView = { // Game's main icon
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let videogameNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let videogameDeveloperLogoImageView: UIImageView = { // Developer's logo
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let videogameDeveloperNameLabel: UILabel = { // Developer's name text
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .tertiaryLabel
        label.textAlignment = .left
        return label
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func createPlatformLogoImageView(imageName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName) // ViewModel provides full image name
        return imageView
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath

        setupCellUI()
        setupCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videogameLogoImageView.image = nil
        videogameNameLabel.text = nil
        videogameDeveloperLogoImageView.image = nil
        videogameDeveloperNameLabel.text = nil
        releaseDateLabel.text = nil
        favoriteButton.isSelected = false
        currentViewModelId = nil
        currentIndexPath = nil
        platformInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private func setupCellUI() {
        contentView.addSubview(headerStackView)
        contentView.addSubview(developerInfoStackView)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(platformInfoStackView)
        contentView.addSubview(favoriteButton)
        
        headerStackView.addArrangedSubview(videogameLogoImageView)
        headerStackView.addArrangedSubview(videogameNameLabel)
        
        developerInfoStackView.addArrangedSubview(videogameDeveloperLogoImageView)
        developerInfoStackView.addArrangedSubview(videogameDeveloperNameLabel)
    }

    private func setupCellConstraints() {
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        developerInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        platformInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        // Individual elements within stack views manage their own size or are sized by stack view distribution

        NSLayoutConstraint.activate([
            // Favorite Button (Top Right)
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            // Header Stack View (Game Logo and Name)
            headerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            headerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            headerStackView.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            
            videogameLogoImageView.widthAnchor.constraint(equalToConstant: 50),
            videogameLogoImageView.heightAnchor.constraint(equalToConstant: 50),

            // Developer Info Stack View (Below Header)
            developerInfoStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            developerInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            developerInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),

            videogameDeveloperLogoImageView.widthAnchor.constraint(equalToConstant: 20), // Small dev logo
            videogameDeveloperLogoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Release Date (Below Developer Info)
            releaseDateLabel.topAnchor.constraint(equalTo: developerInfoStackView.bottomAnchor, constant: 4),
            releaseDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            releaseDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Platform Info Stack View (Bottom)
            platformInfoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            platformInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            platformInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12), // Allow it to not fill if few platforms
            platformInfoStackView.heightAnchor.constraint(equalToConstant: 20) // Height for platform icons
        ])
    }
    
    func configure(with viewModel: VideogameViewModel, at indexPath: IndexPath) {
        self.currentViewModelId = viewModel.id
        self.currentIndexPath = indexPath

        videogameNameLabel.text = viewModel.name
        
        if let mainImageName = viewModel.mainImageName {
            videogameLogoImageView.image = UIImage(named: "logos/games/\(mainImageName)")
        } else {
            videogameLogoImageView.image = UIImage(systemName: "photo") // Placeholder
        }
        
        // Use developerLogoImageName from ViewModel
        if let devLogoName = viewModel.developerLogoImageName {
            videogameDeveloperLogoImageView.image = UIImage(named: "logos/developers/\(devLogoName)")
        } else {
            videogameDeveloperLogoImageView.image = UIImage(systemName: "person.crop.square") // Placeholder
        }
        videogameDeveloperNameLabel.text = viewModel.developerNameText // This is the formatted string "By Developer"

        releaseDateLabel.text = viewModel.releaseDateText
        favoriteButton.isSelected = viewModel.isFavorite

        platformInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let platformIconAssetNames = viewModel.platformIconNames {
            for iconAssetName in platformIconAssetNames {
                // Construct full path if iconAssetName is just "pc", "xbox" etc.
                let platformImageView = createPlatformLogoImageView(imageName: "logos/platforms/\(iconAssetName)")
                platformImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    platformImageView.widthAnchor.constraint(equalToConstant: 18), // Small platform icons
                    platformImageView.heightAnchor.constraint(equalToConstant: 18)
                ])
                platformInfoStackView.addArrangedSubview(platformImageView)
            }
        }
    }

    @objc private func didTapFavorite() {
        guard let path = currentIndexPath, let id = currentViewModelId else { return }
        // The cell itself doesn't know the ID, it should come from the ViewModel or be passed to delegate
        // Corrected: Use currentViewModelId
        actionDelegate?.didTapFavoriteButton(on: self, at: path) // The VC will use its ViewModel array and index
    }
}
