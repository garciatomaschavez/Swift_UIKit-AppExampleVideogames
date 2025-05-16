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
    private var currentViewModelId: UUID?
    private var currentIndexPath: IndexPath?

    // --- UI Elements (Copied from your previous correct version) ---
    private let platformInfoStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
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
        stackView.layer.cornerRadius = 8
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        return stackView
    }()
    
    private let headerStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let videogameLogoImageView: UIImageView = {
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
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    // --- End of UI Elements ---

    private func createPlatformLogoImageView(imageName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
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
        favoriteButton.tintColor = .systemRed // Reset to a default or ensure it's set in configure
        currentViewModelId = nil
        currentIndexPath = nil
        platformInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private func setupCellUI() { // Ensure this matches your actual implementation
        contentView.addSubview(headerStackView)
        contentView.addSubview(developerInfoStackView)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(platformInfoStackView)
        contentView.addSubview(favoriteButton)
        
        headerStackView.addArrangedSubview(videogameLogoImageView)
        headerStackView.addArrangedSubview(videogameNameLabel)
        
        developerInfoStackView.addArrangedSubview(videogameDeveloperLogoImageView)
        developerInfoStackView.addArrangedSubview(videogameDeveloperNameLabel)

        headerStackView.axis = .horizontal; headerStackView.spacing = 10; headerStackView.alignment = .center
        developerInfoStackView.axis = .horizontal; developerInfoStackView.spacing = 6; developerInfoStackView.alignment = .center
        platformInfoStackView.axis = .horizontal; platformInfoStackView.spacing = 4; platformInfoStackView.alignment = .center
    }

    private func setupCellConstraints() { // Ensure this matches your actual implementation
         headerStackView.translatesAutoresizingMaskIntoConstraints = false
         developerInfoStackView.translatesAutoresizingMaskIntoConstraints = false
         releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
         platformInfoStackView.translatesAutoresizingMaskIntoConstraints = false
         videogameLogoImageView.translatesAutoresizingMaskIntoConstraints = false
         videogameNameLabel.translatesAutoresizingMaskIntoConstraints = false
         videogameDeveloperLogoImageView.translatesAutoresizingMaskIntoConstraints = false
         videogameDeveloperNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            headerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            headerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            headerStackView.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            
            videogameLogoImageView.widthAnchor.constraint(equalToConstant: 50),
            videogameLogoImageView.heightAnchor.constraint(equalToConstant: 50),

            developerInfoStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            developerInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            developerInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),

            videogameDeveloperLogoImageView.widthAnchor.constraint(equalToConstant: 20),
            videogameDeveloperLogoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            releaseDateLabel.topAnchor.constraint(equalTo: developerInfoStackView.bottomAnchor, constant: 4),
            releaseDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            releaseDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            platformInfoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            platformInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            platformInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
            platformInfoStackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // Updated configure method to accept heartColor
    func configure(with viewModel: VideogameViewModel, at indexPath: IndexPath, heartColor: UIColor) {
        self.currentViewModelId = viewModel.id
        self.currentIndexPath = indexPath

        videogameNameLabel.text = viewModel.name
        
        if let mainImageName = viewModel.mainImageName {
            videogameLogoImageView.image = UIImage(named: "logos/games/\(mainImageName)")
        } else {
            videogameLogoImageView.image = UIImage(systemName: "photo")
        }
        
        if let devLogoName = viewModel.developerLogoImageName {
            videogameDeveloperLogoImageView.image = UIImage(named: "logos/developers/\(devLogoName)")
        } else {
            videogameDeveloperLogoImageView.image = UIImage(systemName: "person.crop.square")
        }
        videogameDeveloperNameLabel.text = viewModel.developerNameText

        releaseDateLabel.text = viewModel.releaseDateText
        
        favoriteButton.isSelected = viewModel.isFavorite
        favoriteButton.tintColor = heartColor // Apply the passed color
    
        platformInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let platformIconAssetNames = viewModel.platformIconNames {
            for iconAssetName in platformIconAssetNames {
                let platformImageView = createPlatformLogoImageView(imageName: "logos/platforms/\(iconAssetName)")
                platformImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    platformImageView.widthAnchor.constraint(equalToConstant: 18),
                    platformImageView.heightAnchor.constraint(equalToConstant: 18)
                ])
                platformInfoStackView.addArrangedSubview(platformImageView)
            }
        }
    }

    @objc private func didTapFavorite() {
        guard let path = currentIndexPath else { return }
        actionDelegate?.didTapFavoriteButton(on: self, at: path)
    }
}

