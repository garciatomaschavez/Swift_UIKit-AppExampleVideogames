//
//  BottomSheetContentView.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 25/4/25.
//

import UIKit

class BottomSheetContentView: UIView, UIScrollViewDelegate {

    // MARK: - Properties (UI elements remain largely the same)
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // imageView.addCustomShadowsLogo(.black, opacity: 0.5, radius: 10) // Assuming custom extension
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 5
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.clipsToBounds = false // Allow shadow
        return imageView
    }()

    let imageCarouselScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .systemGray5 // Placeholder background
        return scrollView
    }()

    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.hidesForSinglePage = true
        return pageControl
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    let developerButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.systemBlue, for: .normal)
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
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isEditable = false
        textView.isScrollEnabled = true // Allow scrolling for longer descriptions
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        textView.backgroundColor = .clear
        textView.textColor = .label
        return textView
    }()

    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()

    private var gameImagesForCarousel: [UIImage?] = []
    private var currentDetailViewModel: VideogameDetailViewModel?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground // Background for the whole bottom sheet
        setupViewsAndConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemBackground
        setupViewsAndConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Re-setup carousel if bounds change significantly, though images are set in configure
        if !gameImagesForCarousel.isEmpty {
             setupImageCarouselImageViews()
        }
    }
    
    private func setupViewsAndConstraints() {
        addSubview(imageCarouselScrollView)
        addSubview(logoImageView) // Logo should be on top of the carousel or beside title
        addSubview(pageControl)
        addSubview(titleLabel)
        addSubview(developerButton)
        addSubview(platformsStackView)
        addSubview(descriptionTextView)
        addSubview(releaseDateLabel)
        
        imageCarouselScrollView.delegate = self
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        imageCarouselScrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        developerButton.translatesAutoresizingMaskIntoConstraints = false
        platformsStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false

        // A more robust layout
        NSLayoutConstraint.activate([
            imageCarouselScrollView.topAnchor.constraint(equalTo: topAnchor),
            imageCarouselScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageCarouselScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageCarouselScrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35), // e.g., 35% of sheet height

            pageControl.topAnchor.constraint(equalTo: imageCarouselScrollView.bottomAnchor, constant: 4),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),

            // Logo can be placed relative to title or carousel
            logoImageView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 12),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            developerButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8), // Or below logoImageView if title is short
            developerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            platformsStackView.centerYAnchor.constraint(equalTo: developerButton.centerYAnchor),
            platformsStackView.leadingAnchor.constraint(equalTo: developerButton.trailingAnchor, constant: 12),
            platformsStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            platformsStackView.heightAnchor.constraint(equalToConstant: 25),

            releaseDateLabel.topAnchor.constraint(equalTo: developerButton.bottomAnchor, constant: 8),
            releaseDateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            descriptionTextView.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configuration
    func configure(with viewModel: VideogameDetailViewModel) {
        self.currentDetailViewModel = viewModel

        titleLabel.text = viewModel.name
        descriptionTextView.text = viewModel.description
        releaseDateLabel.text = viewModel.releaseDateText
        
        if let gameLogoName = viewModel.gameLogoImageName {
            logoImageView.image = UIImage(named: "logos/games/\(gameLogoName)")
        } else {
            logoImageView.image = nil // Placeholder
        }
        
        developerButton.setTitle(viewModel.developerName ?? "N/A", for: .normal)
        if viewModel.developerWebsiteURL != nil {
            developerButton.addTarget(self, action: #selector(openDeveloperWebsite), for: .touchUpInside)
            developerButton.isEnabled = true
        } else {
            developerButton.removeTarget(self, action: #selector(openDeveloperWebsite), for: .touchUpInside)
            developerButton.isEnabled = false
        }
        
        // Configure platforms
        platformsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModel.platformIconNames?.forEach { iconName in
            let platformImageView = createPlatformLogoView(platformAssetSubPath: iconName)
            platformsStackView.addArrangedSubview(platformImageView)
        }
        
        // Configure image carousel
        self.gameImagesForCarousel.removeAll()
        if let screenshotNames = viewModel.screenshotImageNames {
            self.gameImagesForCarousel = screenshotNames.map { UIImage(named: $0) } // Assumes full asset path like "images/game/screenshot1"
            
        }
        setupImageCarouselImageViews()
        pageControl.numberOfPages = gameImagesForCarousel.count
        pageControl.currentPage = 0
        pageControl.isHidden = gameImagesForCarousel.count <= 1
    }

    private func createPlatformLogoView(platformAssetSubPath: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // Construct full path if platformAssetSubPath is just "pc", "xbox" etc.
        imageView.image = UIImage(named: "logos/platforms/\(platformAssetSubPath)")
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20), // Fixed size for platform icons
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        return imageView
    }

    private func setupImageCarouselImageViews() {
        // Clear existing image views
        imageCarouselScrollView.subviews.forEach { $0.removeFromSuperview() }
        guard !gameImagesForCarousel.isEmpty else {
            imageCarouselScrollView.contentSize = .zero
            return
        }

        let imageWidth = bounds.width // Use the actual bounds of the BottomSheetContentView for carousel width
        let imageHeight = imageCarouselScrollView.bounds.height // Use the actual height of the scroll view

        guard imageWidth > 0, imageHeight > 0 else {
            // If bounds are not yet set, defer setup (layoutSubviews will call it again)
            return
        }
        
        for (index, image) in gameImagesForCarousel.enumerated() {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * imageWidth, y: 0, width: imageWidth, height: imageHeight))
            imageView.contentMode = .scaleAspectFill // Or .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.image = image ?? UIImage(systemName: "photo") // Placeholder for nil images
            imageCarouselScrollView.addSubview(imageView)
        }
        imageCarouselScrollView.contentSize = CGSize(width: CGFloat(gameImagesForCarousel.count) * imageWidth, height: imageHeight)
    }

    // MARK: - Actions
    @objc private func openDeveloperWebsite() {
        guard let url = currentDetailViewModel?.developerWebsiteURL else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update page control if you want live updates during scroll,
        // otherwise scrollViewDidEndDecelerating is usually enough.
        if scrollView == imageCarouselScrollView {
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            if !pageNumber.isNaN && !pageNumber.isInfinite {
                 pageControl.currentPage = Int(pageNumber)
            }
        }
    }
}
