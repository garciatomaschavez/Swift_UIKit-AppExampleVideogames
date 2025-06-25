//
//  Platform.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 30/4/25.
//

import Foundation

/// Represents the platforms a videogame can be available on.
enum Platform: String, CaseIterable {
    case pc
    case steam
    case xbox
    case playstation
    case ios
    case android
    case nintendoswitch
    case missing

    /// Initializes a Platform enum from a raw string.
    /// It processes the string to be lowercase and removes spaces before attempting to match.
    init?(fromString string: String) {
        let processedString = string.lowercased().replacingOccurrences(of: " ", with: "")
        if let platform = Platform(rawValue: processedString) {
            self = platform
        } else {
            // If no direct match, consider it missing or handle specific alternative mappings if necessary.
            // For now, defaulting to .missing for unknown strings.
             print("⚠️ Warning: Unknown platform string '\(string)' encountered during mapping. Defaulting to '.missing'.")
            self = .missing
        }
    }

    /// Provides an image asset name for the platform's icon.
    /// These should match asset names in your Assets.xcassets.
    var imageName: String {
        switch self {
        case .pc: return "pc_icon"
        case .steam: return "steam_icon"
        case .xbox: return "xbox_icon"
        case .playstation: return "playstation_icon"
        case .ios: return "ios_icon"
        case .android: return "android_icon"
        case .nintendoswitch: return "nintendoswitch_icon"
        case .missing: return "missing_icon"
        }
    }
}
