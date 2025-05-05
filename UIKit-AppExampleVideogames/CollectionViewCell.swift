//
//  CollectionViewCell.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/4/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "MainVideogameCollectionViewCell"
    
    private let platformInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layer.backgroundColor = UIColor.systemIndigo.cgColor
        stackView.layer.cornerRadius = 8
        
        stackView.addCustomShadows(.black, opacity: 0.3, radius: 10)
        
        return stackView
    }()
    
    private let developerInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layer.backgroundColor = UIColor.systemTeal.cgColor
        stackView.layer.cornerRadius = 8
        
        stackView.addCustomShadows(.black, opacity: 0.3, radius: 10)
        
        return stackView
    }()
    
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layer.backgroundColor = UIColor.green.cgColor
        stackView.layer.cornerRadius = 8
        
        stackView.addCustomShadows(.black, opacity: 0.3, radius: 10)
        
        return stackView
    }()
    
    private let videogameLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let videogameNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let videogameDeveloperLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private func createPlatformLogoImageView(for platform: Platforms) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logos/platforms/\(platform.rawValue)")?.addPadding(3)
        return imageView
    }
    
    
    private let videogamePlatformLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let videogameDeveloperNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let videogameReleaseYear: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.videogamePlatformLogoImageView.image = nil
        
        for subview in self.platformInfoStackView.subviews {
            DEBUG_ENABLED ? debugPrint("Removed subview: \n\t - \(subview)") : nil
            subview.removeFromSuperview()
        }
    
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header Stack View Constraints
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            headerStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),

            // Developer Info Stack View Constraints
            developerInfoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            developerInfoStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            // Platform Info Stack View Constraints
            platformInfoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            platformInfoStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            // Height constraints for views
            videogameLogoImageView.heightAnchor.constraint(equalToConstant: 70),
            videogameDeveloperLogoImageView.heightAnchor.constraint(equalToConstant: 50),

            // Width constraints for views
            videogameLogoImageView.widthAnchor.constraint(lessThanOrEqualTo: headerStackView.widthAnchor, multiplier: 0.2),
            videogameDeveloperLogoImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
//            videogamePlatformLogoImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            developerInfoStackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.3),
            platformInfoStackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.7),

            // Ensure the developer info stack view's trailing edge is determined by its content
            developerInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -5),
        ])
    }
    
    
    fileprivate func setupUI() {
        addSubview(headerStackView)
        addSubview(developerInfoStackView)
        addSubview(platformInfoStackView)
        
        headerStackView.axis = .horizontal
        headerStackView.spacing = 5
        headerStackView.alignment = .center
        
        developerInfoStackView.axis = .vertical
        developerInfoStackView.spacing = 4
        developerInfoStackView.alignment = .leading
        developerInfoStackView.distribution = .equalSpacing // .fill Or .equalSpacing depending on desired look
        
        platformInfoStackView.axis = .horizontal
        platformInfoStackView.spacing = 2
        platformInfoStackView.alignment = .trailing
        platformInfoStackView.distribution = .equalSpacing
        
        headerStackView.addArrangedSubview(videogameLogoImageView)
        headerStackView.addArrangedSubview(videogameNameLabel)
        //        headerStackView.addArrangedSubview(videogameReleaseYear)
        
        developerInfoStackView.addArrangedSubview(videogameDeveloperLogoImageView)
        // developerInfoStackView.addArrangedSubview(videogameDeveloperNameLabel)
        
        //        platformInfoStackView.addArrangedSubview(videogameReleaseYear)
        
        // Disable autoresizing mask translation to use Auto Layout
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        developerInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        platformInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        videogameLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        videogameDeveloperLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        videogameNameLabel.translatesAutoresizingMaskIntoConstraints = false
        videogameReleaseYear.translatesAutoresizingMaskIntoConstraints = false
        // videogameDeveloperNameLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: Videogame) {
        DEBUG_ENABLED ? print("Starting configure() for: \(model.title ?? "No Title")") : nil
        
        self.backgroundColor = .purple
        self.layer.cornerRadius = 8
        DEBUG_ENABLED ? print("\t - Added purple background and cornerRadius to cell") : nil
        
        videogameLogoImageView.image = UIImage(named: "logos/games/\(model.logo ?? "")")?.addPadding(5)
        videogameNameLabel.text = model.title
        
        DEBUG_ENABLED ? print("\t - Set videogameLogoImage and videogameNameLabel to cell") : nil
        
        videogameDeveloperLogoImageView.image = UIImage(named: "logos/developers/\(model.developer?.logo ?? "")")?.addPadding(5)
        videogameDeveloperNameLabel.text = model.developer?.name
        
        DEBUG_ENABLED ? print("\t - Set videogameDeveloperLogoImageView and videogameDeveloperNameLabel to cell") : nil
        
        videogameReleaseYear.text = model.releaseYear?.formatted(date: .numeric, time: .omitted)
        DEBUG_ENABLED ? print("\t - Set videogameReleaseYear to cell") : nil
        
        var platforms: [Platforms] = []
        
        if let platformsStrings = model.platforms as? [String] {
            platforms = platformsStrings.compactMap { Platforms(rawValue: $0) }
        } else {
            print("Warning: platforms is not of type [String]")
            //  Handle the case where platforms is not a [String]
            //  For example, you could leave platforms as an empty array,
            //  or provide a default set of platforms.
        }
        dump(model.platforms)

        for platform in platforms {
            let platformLogoImageView = createPlatformLogoImageView(for: platform)
            platformInfoStackView.addArrangedSubview(platformLogoImageView)
            DEBUG_ENABLED ? print("\t\t + Added platform (\(platform)) to cell") : nil
            NSLayoutConstraint.activate([
                platformLogoImageView.heightAnchor.constraint(equalToConstant: 25),
                platformLogoImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.075),
            ])
        }
        DEBUG_ENABLED ? print("Finished configure() for: \(model.title ?? "No Title")\n") : nil
    }
}

