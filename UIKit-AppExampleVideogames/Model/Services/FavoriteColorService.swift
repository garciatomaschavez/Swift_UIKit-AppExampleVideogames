//
//  FavoriteColorService.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 14/5/25.
//

import UIKit

struct FavoriteColorService {
    
    private static let defaults = UserDefaults.standard
    private static let favoriteColorKey = "userFavoriteHeartColorName"

    // Predefined color names that we can store as strings
    enum ColorName: String, CaseIterable {
        case systemRed, systemBlue, systemGreen, systemOrange, systemPurple, systemTeal
        
        var uiColor: UIColor {
            switch self {
            case .systemRed: return .systemRed
            case .systemBlue: return .systemBlue
            case .systemGreen: return .systemGreen
            case .systemOrange: return .systemOrange
            case .systemPurple: return .systemPurple
            case .systemTeal: return .systemTeal
            }
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
            // If the color is not one of our predefined ones,
            // we could choose to not save it, or save a default.
            // For now, we'll just print a warning if it's an unknown color.
            print("FavoriteColorService: Warning - Attempted to save a non-predefined UIColor. Color not saved.")
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
        return .systemRed
    }
}
