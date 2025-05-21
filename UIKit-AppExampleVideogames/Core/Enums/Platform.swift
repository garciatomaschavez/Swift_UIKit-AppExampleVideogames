//
//  Platforms.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 30/4/25.
//

import Foundation

/// Represents the platforms a videogame can be available on.
enum Platform: String, CaseIterable, Decodable {
    case pc
    case steam
    case xbox
    case playstation
    case ios
    case android
    case nintendoswitch
    case missing

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        let processedString = rawString.lowercased().replacingOccurrences(of: " ", with: "")

        if let platform = Platform(rawValue: processedString) {
            self = platform
        } else {
            print("⚠️ Warning: Unknown platform string '\(rawString)' encountered during decoding. Defaulting to '.missing'.")
            self = .missing
        }
    }

    /// Provides an image asset name for the platform's icon.
    /// These should match asset names in your Assets.xcassets.
    var imageName: String {
        switch self {
        case .pc: return "pc_icon" // Example: replace with your actual asset name
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
