//
//  PlatformsTransformer.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 5/5/25.
//

import Foundation

@objc(PlatformsTransformer)
class PlatformsTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let platforms = value as? [String] else { return nil }
        
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: platforms, requiringSecureCoding: true)
            return encodedData
        } catch {
            print("Error encoding platforms: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            let decodedPlatforms = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [String]
            return decodedPlatforms
        } catch {
            print("Error decoding platforms: \(error)")
            return nil
        }
    }
}
