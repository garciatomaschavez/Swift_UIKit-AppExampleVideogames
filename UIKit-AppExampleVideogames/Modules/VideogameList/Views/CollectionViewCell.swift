//
//  CollectionViewCell.swift
//  UIKit-AppExampleVideogames
//  Located in: Modules/VideogameList/Views/
//  Created by tom on 9/4/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "VideogameListCollectionViewCell"
    
    public var favoriteButtonTapHandler: (() -> Void)?
            

    // --- UI Elements ---
    private let platformInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let developerInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let headerStackView: UIStackView = { // Contains logo and name
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let mainContentStackView: UIStackView = { // Vertical stack for all content
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return stackView
    }()
    
    private let videogameLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5 // Placeholder color
        return imageView
    }()
    
    private let videogameNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold) // Adjusted font
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let videogameDeveloperLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let videogameDeveloperNameLabel: UILabel = {
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
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .selected)
        button.addTarget(self, action: #selector(didTapFavoriteButtonAction), for: .touchUpInside)
        button.tintColor = .systemGray
        return button
    }()

    private func createPlatformLogoImageView(imageName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // Assumes imageName is the direct asset name like "pc_icon"
        imageView.image = UIImage(named: imageName)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])
        return imageView
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.clipsToBounds = true
    
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        
        setupCellUI() // Call this method to add subviews and constraints
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
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
        // Reset tint color if needed, or rely on configure to set it.
        // favoriteButton.tintColor = .systemGray
        platformInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private func setupCellUI() {
        // Keep your existing UI setup code here from ListCollectionViewCell_Updated
        // For brevity, I'm omitting the full setup code again.
        // Ensure favoriteButton is part of this setup.
        contentView.addSubview(mainContentStackView)
        mainContentStackView.translatesAutoresizingMaskIntoConstraints = false

        let titleFavoriteStack = UIStackView(arrangedSubviews: [videogameNameLabel, favoriteButton])
        titleFavoriteStack.axis = .horizontal
        titleFavoriteStack.spacing = 8
        titleFavoriteStack.alignment = .center
        favoriteButton.setContentHuggingPriority(.required, for: .horizontal)
        favoriteButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let nameAndFavoriteContainer = UIView()
        nameAndFavoriteContainer.addSubview(titleFavoriteStack)
        titleFavoriteStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleFavoriteStack.leadingAnchor.constraint(equalTo: nameAndFavoriteContainer.leadingAnchor),
            titleFavoriteStack.trailingAnchor.constraint(equalTo: nameAndFavoriteContainer.trailingAnchor),
            titleFavoriteStack.topAnchor.constraint(equalTo: nameAndFavoriteContainer.topAnchor),
            titleFavoriteStack.bottomAnchor.constraint(equalTo: nameAndFavoriteContainer.bottomAnchor)
        ])

        headerStackView.addArrangedSubview(videogameLogoImageView)
        headerStackView.addArrangedSubview(nameAndFavoriteContainer)
        
        developerInfoStackView.addArrangedSubview(videogameDeveloperLogoImageView)
        developerInfoStackView.addArrangedSubview(videogameDeveloperNameLabel)

        mainContentStackView.addArrangedSubview(headerStackView)
        mainContentStackView.addArrangedSubview(developerInfoStackView)
        mainContentStackView.addArrangedSubview(releaseDateLabel)
        mainContentStackView.addArrangedSubview(platformInfoStackView)
        
        NSLayoutConstraint.activate([
            mainContentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainContentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainContentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            videogameLogoImageView.widthAnchor.constraint(equalToConstant: 50),
            videogameLogoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            videogameDeveloperLogoImageView.widthAnchor.constraint(equalToConstant: 20),
            videogameDeveloperLogoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            platformInfoStackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // --- MODIFIED: configure method to accept heartColor ---
    func configure(with viewModel: VideogameListViewModel, heartColor: UIColor) {
        videogameNameLabel.text = viewModel.name
        
        if let mainImageName = viewModel.mainImageName {
            videogameLogoImageView.image = UIImage(named: "logos/games/\(mainImageName)")
        } else {
            videogameLogoImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        }
        
        if let devLogoName = viewModel.developerLogoImageName {
            videogameDeveloperLogoImageView.image = UIImage(named: "logos/developers/\(devLogoName)")
        } else {
            videogameDeveloperLogoImageView.image = UIImage(systemName: "building.2")
        }
        videogameDeveloperNameLabel.text = viewModel.developerNameText
        releaseDateLabel.text = viewModel.releaseDateText
        
        favoriteButton.isSelected = viewModel.isFavorite
        favoriteButton.tintColor = viewModel.isFavorite ? heartColor : .systemGray // Use passed heartColor for selected state
    
        platformInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let platformIconAssetNames = viewModel.platformIconNames {
            for iconAssetName in platformIconAssetNames {
                let platformImageView = createPlatformLogoImageView(imageName: iconAssetName)
                platformInfoStackView.addArrangedSubview(platformImageView)
            }
        }
    }
    // --- END OF MODIFICATION ---

    @objc private func didTapFavoriteButtonAction() {
        favoriteButtonTapHandler?()
    }
}
