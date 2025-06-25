//
//  BottomSheetContentView.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 25/4/25.
//  Refactored by AI on 19/05/25.
//

import UIKit

class BottomSheetContentView: UIView, UIScrollViewDelegate {

    // MARK: - Callbacks
    public var favoriteButtonTapHandler: (() -> Void)?
    public var openDeveloperWebsiteTapHandler: (() -> Void)? // For consistency

    // MARK: - UI Elements
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 5
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.clipsToBounds = false
        return imageView
    }()

    let imageCarouselScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .systemGray6 // Slightly lighter for carousel background
        scrollView.layer.cornerRadius = 8
        scrollView.clipsToBounds = true
        return scrollView
    }()

    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.hidesForSinglePage = true
        return pageControl
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold) // Slightly adjusted size
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system) // Use system for easier tinting behavior
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .selected)
        button.tintColor = .systemGray // Default tint
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()

    let developerButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium) // Adjusted font
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.systemBlue, for: .normal)
        // Add an icon for better UX
        let image = UIImage(systemName: "safari")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0) // Adjust spacing
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        return button
    }()

    let platformsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15) // Adjusted font
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5) // Adjust default padding
        textView.backgroundColor = .clear
        textView.textColor = .label
        return textView
    }()

    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium) // Adjusted font
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()

    private var gameImagesForCarousel: [UIImage?] = []
    private var currentDetailViewModel: VideogameDetailViewModel?
    private var gameLogoIdentifierForCarousel: String? // To construct screenshot paths

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupViewsAndConstraints()
        imageCarouselScrollView.delegate = self
        developerButton.addTarget(self, action: #selector(openDeveloperWebsite), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemBackground
        setupViewsAndConstraints()
        imageCarouselScrollView.delegate = self
        developerButton.addTarget(self, action: #selector(openDeveloperWebsite), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Re-setup carousel if bounds change significantly
        if !gameImagesForCarousel.isEmpty, imageCarouselScrollView.frame.width > 0 {
             setupImageCarouselImageViews()
        }
    }
    
    private func setupViewsAndConstraints() {
        addSubview(imageCarouselScrollView)
        addSubview(pageControl)
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(favoriteButton) // Add favorite button
        addSubview(developerButton)
        addSubview(platformsStackView)
        addSubview(releaseDateLabel)
        addSubview(descriptionTextView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        imageCarouselScrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        developerButton.translatesAutoresizingMaskIntoConstraints = false
        platformsStackView.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        let padding: CGFloat = 16

        NSLayoutConstraint.activate([
            imageCarouselScrollView.topAnchor.constraint(equalTo: topAnchor, constant: padding / 2),
            imageCarouselScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            imageCarouselScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            imageCarouselScrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.30),

            pageControl.topAnchor.constraint(equalTo: imageCarouselScrollView.bottomAnchor, constant: 4),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),

            logoImageView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: padding),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            logoImageView.widthAnchor.constraint(equalToConstant: 60), // Slightly larger logo
            logoImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: padding / 2),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -padding / 2),

            favoriteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44), // Standard tap target size
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),

            developerButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding / 2),
            developerButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor), // Align with title
            developerButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -padding),


            platformsStackView.topAnchor.constraint(equalTo: developerButton.bottomAnchor, constant: padding / 2),
            platformsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            platformsStackView.heightAnchor.constraint(equalToConstant: 22),

            releaseDateLabel.topAnchor.constraint(equalTo: platformsStackView.bottomAnchor, constant: padding / 2),
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            descriptionTextView.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: padding / 2),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            descriptionTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }

    // MARK: - Configuration
    func configure(with viewModel: VideogameDetailViewModel) {
        self.currentDetailViewModel = viewModel
        self.gameLogoIdentifierForCarousel = viewModel.gameLogoImageName // Store for screenshot path construction

        titleLabel.text = viewModel.name
        descriptionTextView.text = viewModel.description
        releaseDateLabel.text = viewModel.releaseDateText
        
        if let gameLogoName = viewModel.gameLogoImageName {
            logoImageView.image = UIImage(named: "logos/games/\(gameLogoName)")
        } else {
            logoImageView.image = UIImage(systemName: "photo.on.rectangle.angled") // Better placeholder
        }
        
        favoriteButton.isSelected = viewModel.isFavorite
        favoriteButton.tintColor = viewModel.isFavorite ? .systemRed : .systemGray
        
        developerButton.setTitle(viewModel.developerName ?? "N/A", for: .normal)
        developerButton.isEnabled = viewModel.developerWebsiteURL != nil
        
        platformsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModel.platformIconNames?.forEach { iconNameRawValue in
            // Assuming iconNameRawValue is the rawValue of the Platform enum
            // and Platform enum has an `imageName` property for the asset.
            if let platform = Platform(rawValue: iconNameRawValue.lowercased().replacingOccurrences(of: " ", with: "")) {
                 let platformImageView = createPlatformLogoView(platformIconName: platform.imageName)
                 platformsStackView.addArrangedSubview(platformImageView)
            } else {
                // Fallback for unknown platform strings
                let platformImageView = createPlatformLogoView(platformIconName: Platform.missing.imageName)
                platformsStackView.addArrangedSubview(platformImageView)
            }
        }
        
        self.gameImagesForCarousel.removeAll()
        if let screenshotIdentifiers = viewModel.screenshotImageIdentifiers, let _ = self.gameLogoIdentifierForCarousel {
            self.gameImagesForCarousel = screenshotIdentifiers.map { identifier in
                // Construct the full path: "images/{game_logo_identifier}/{screenshot_identifier}"
                // Example: "images/minecraft/1" (assuming your assets are named like "1.jpg", "2.png")
                // The .jpg or .png extension is handled by UIImage(named:) if the asset catalog is set up.
                let imageName = identifier
                return UIImage(named: imageName)
            }
        }
        setupImageCarouselImageViews()
        pageControl.numberOfPages = gameImagesForCarousel.count
        pageControl.currentPage = 0
    }

    private func createPlatformLogoView(platformIconName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // platformIconName should directly be the asset name like "pc_icon", "xbox_icon"
        imageView.image = UIImage(named: platformIconName) // No need to prepend "logos/platforms/" if Platform.imageName provides the full asset name
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        return imageView
    }

    private func setupImageCarouselImageViews() {
        imageCarouselScrollView.subviews.forEach { $0.removeFromSuperview() }
        guard !gameImagesForCarousel.isEmpty, imageCarouselScrollView.frame.width > 0 else {
            imageCarouselScrollView.contentSize = .zero
            return
        }

        let imageWidth = imageCarouselScrollView.frame.width
        let imageHeight = imageCarouselScrollView.frame.height
        
        for (index, image) in gameImagesForCarousel.enumerated() {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * imageWidth, y: 0, width: imageWidth, height: imageHeight))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = image ?? UIImage(systemName: "photo.fill") // Better placeholder
            imageCarouselScrollView.addSubview(imageView)
        }
        imageCarouselScrollView.contentSize = CGSize(width: CGFloat(gameImagesForCarousel.count) * imageWidth, height: imageHeight)
    }

    // MARK: - Actions
    @objc private func favoriteButtonTapped() {
        favoriteButtonTapHandler?()
    }
    
    @objc private func openDeveloperWebsite() {
        // The tap handler is now preferred for consistency, but direct action is also fine.
        // If using handler: openDeveloperWebsiteTapHandler?()
        // Direct action:
        guard let url = currentDetailViewModel?.developerWebsiteURL else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == imageCarouselScrollView {
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            if !pageNumber.isNaN && !pageNumber.isInfinite {
                 pageControl.currentPage = Int(pageNumber)
            }
        }
    }
}
