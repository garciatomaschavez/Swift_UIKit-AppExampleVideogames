//
//  FavoriteColorService.swift
//  UIKit-AppExampleVideogames
//  Location: Core/Services/FavoriteColorService.swift
//  Created by tom on 14/5/25.
//

import UIKit

struct FavoriteColorService {
    
    private static let defaults = UserDefaults.standard
    private static let favoriteColorKey = "userFavoriteHeartColorName"

    // Predefined color names that we can store as strings
    enum ColorName: String, CaseIterable {
        case systemRed, systemBlue, systemGreen, systemOrange, systemPurple, systemTeal, systemPink, systemIndigo, systemGray
        
        var uiColor: UIColor {
            switch self {
            case .systemRed: return .systemRed
            case .systemBlue: return .systemBlue
            case .systemGreen: return .systemGreen
            case .systemOrange: return .systemOrange
            case .systemPurple: return .systemPurple
            case .systemTeal: return .systemTeal
            case .systemPink: return .systemPink
            case .systemIndigo: return .systemIndigo
            case .systemGray: return .systemGray
            }
        }
        
        var displayName: String {
            // Capitalize the first letter and remove "system" prefix for display
            let name = self.rawValue
            if name.lowercased().hasPrefix("system") {
                return String(name.dropFirst("system".count)).capitalizedFirstLetter()
            }
            return name.capitalizedFirstLetter()
        }
        
        static func from(uiColor: UIColor) -> ColorName? {
            return ColorName.allCases.first { $0.uiColor == uiColor }
        }
    }

    static func saveFavoriteColor(_ color: UIColor) {
        if let colorName = ColorName.from(uiColor: color)?.rawValue {
            defaults.set(colorName, forKey: favoriteColorKey)
            print("FavoriteColorService: Saved color name '\(colorName)' to UserDefaults.")
        } else {
            // If the color is not one of our predefined ones, save its rawValue if possible,
            // or default to systemRed. For simplicity, we only save predefined ones.
            defaults.set(ColorName.systemRed.rawValue, forKey: favoriteColorKey) // Default if color not in enum
            print("FavoriteColorService: Warning - Attempted to save a non-predefined UIColor. Defaulting to systemRed and saving that.")
        }
    }

    static func loadFavoriteColor() -> UIColor {
        if let colorNameString = defaults.string(forKey: favoriteColorKey),
           let colorName = ColorName(rawValue: colorNameString) {
            print("FavoriteColorService: Loaded color name '\(colorNameString)' from UserDefaults.")
            return colorName.uiColor
        }
        // Default color if nothing is saved or if the saved string is invalid
        print("FavoriteColorService: No color saved or invalid name in UserDefaults. Returning default (systemRed).")
        return ColorName.systemRed.uiColor // Default color
    }
}

extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
