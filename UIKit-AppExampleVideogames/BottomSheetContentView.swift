//
//  BottomSheetContentView.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 25/4/25.
//

import UIKit

class BottomSheetContentView: UIView, UIScrollViewDelegate {

    // MARK: - Properties

    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.addCustomShadowsLogo(.black, opacity: 0.5, radius: 10)
        return imageView
    }()

    let imageCarouselScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray
        pageControl.hidesForSinglePage = true
        return pageControl
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.numberOfLines = 0
        return label
    }()

    let developerButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.contentHorizontalAlignment = .left
        return button
    }()

    let platformsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()

    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        return textView
    }()

    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private var gameImages: [UIImage?] = []

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupImageCarousel()
    }
    
    private func setupViews() {
        addSubview(imageCarouselScrollView)
        addSubview(logoImageView)
        addSubview(pageControl)
        addSubview(titleLabel)
        addSubview(developerButton)
        addSubview(platformsStackView)
        addSubview(descriptionTextView)
        addSubview(releaseDateLabel)
        
        imageCarouselScrollView.delegate = self
        imageCarouselScrollView.backgroundColor = .blue
        
        // Constraints setup (will be added in a separate function for clarity)
        setupConstraints()
    }

    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        imageCarouselScrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        developerButton.translatesAutoresizingMaskIntoConstraints = false
        platformsStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Logo on top of the image carousel
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logoImageView.widthAnchor.constraint(equalToConstant: 60), // Adjust as needed
            logoImageView.heightAnchor.constraint(equalToConstant: 60), // Adjust as needed

            // Image Carousel
            imageCarouselScrollView.topAnchor.constraint(equalTo: topAnchor),
            imageCarouselScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageCarouselScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageCarouselScrollView.heightAnchor.constraint(equalToConstant: 200), // Adjust as needed
            
            // Page Control below the image carousel
            pageControl.topAnchor.constraint(equalTo: imageCarouselScrollView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),

            // Title below the page control
            titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Developer button and platforms stack view (on the same line)
            developerButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            developerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            developerButton.trailingAnchor.constraint(lessThanOrEqualTo: centerXAnchor, constant: -8), // Allow platforms to take space

            platformsStackView.centerYAnchor.constraint(equalTo: developerButton.centerYAnchor),
            platformsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Description below developer/platforms
            descriptionTextView.topAnchor.constraint(equalTo: developerButton.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Release date at the bottom
            releaseDateLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            releaseDateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        
        ])
    }
    



       // MARK: - Configuration

    func configure(with game: Videogame, images: [UIImage?]) {
        logoImageView.image = UIImage(named: "logos/games/\(game.logo ?? "")")
        titleLabel.text = game.title
        descriptionTextView.text = game.gameDescription // Use gameDescription from Core Data
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        releaseDateLabel.text = "Released: \(dateFormatter.string(from: game.releaseYear ?? Date()))" // Use optional chaining and a default Date()
        
        // Configure developer button
        developerButton.setTitle(game.developer?.name, for: .normal)
        developerButton.setTitleColor(.systemBlue, for: .normal)
        developerButton.addTarget(self, action: #selector(openDeveloperWebsite), for: .touchUpInside)
        currentlyDisplayedGame = game // Set currentlyDisplayedGame to the passed game
        
        // Configure platforms
        platformsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear previous platforms
        
        var platforms: [Platform] = []
        if let platformsStrings = game.platforms as? [String] {
            platforms = platformsStrings.compactMap { Platform(rawValue: $0) }
        } else {
            print("Warning: platforms is not of type [String]")
            //  Handle the case where platforms is not a [String]
            //  For example, you could leave platforms as an empty array,
            //  or provide a default set of platforms.
        }

        for platform in platforms {
            let platformLogoImageView = createPlatformLogoImageView(for: platform)
            platformsStackView.addArrangedSubview(platformLogoImageView)
            NSLayoutConstraint.activate([
                platformLogoImageView.heightAnchor.constraint(equalToConstant: 25),
                platformLogoImageView.widthAnchor.constraint(equalToConstant: 25), // Adjust as needed
            ])
        }
        
        // Configure image carousel
        self.gameImages = images
        //           setupImageCarousel()
    }

       private func createPlatformLogoImageView(for platform: Platform) -> UIImageView {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           imageView.image = UIImage(named: "logos/platforms/\(platform.rawValue)")?.addPadding(3)
           return imageView
       }

       private func setupImageCarousel() {
           for subview in imageCarouselScrollView.subviews {
               subview.removeFromSuperview()
           }

           let imageWidth = imageCarouselScrollView.bounds.width
           let imageHeight = imageCarouselScrollView.bounds.height
           
           for (index, image) in gameImages.enumerated() {
               let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * imageWidth, y: 0, width: imageWidth, height: imageHeight))
               imageView.contentMode = .scaleAspectFill
               imageView.clipsToBounds = true
               imageView.image = image
               imageCarouselScrollView.addSubview(imageView)
           }

           imageCarouselScrollView.contentSize = CGSize(width: CGFloat(gameImages.count) * imageWidth, height: imageHeight)
           pageControl.numberOfPages = gameImages.count
           pageControl.currentPage = 0
       }

       // MARK: - Actions

       @objc func openDeveloperWebsite() {
           guard let websiteString = (currentlyDisplayedGame?.developer?.website), let url = URL(string: websiteString) else { return }
           UIApplication.shared.open(url)
       }

       // MARK: - UIScrollViewDelegate

       func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
           let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
           pageControl.currentPage = Int(pageNumber)
       }

       // MARK: - Helper Property for Developer Website

       private var currentlyDisplayedGame: Videogame?
}
