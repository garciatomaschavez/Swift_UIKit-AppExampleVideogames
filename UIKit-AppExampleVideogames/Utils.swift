//
//  Utils.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/4/25.
//

import Foundation
import UIKit

func getDate(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // ensures consistent parsing
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // avoids local time influence
    
    if let date = dateFormatter.date(from: dateString) {
        return date
    } else {
        print("Invalid date format")
        return Date.now
    }
}

/// Adds a padding all around of an image. Good use case is to apply it when creating the UIImage
extension UIImage {
    func addPadding(_ padding: CGFloat) -> UIImage {
        let alignmentInset = UIEdgeInsets(top: -padding, left: -padding,
                                          bottom: -padding, right: -padding)
        return withAlignmentRectInsets(alignmentInset)
    }
}

extension UIView {
    func addCustomShadows(_ color: UIColor, opacity: Float, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.masksToBounds = false // Important: Allows the shadow to be visible outside the view's bounds
    }
}

extension UIImageView {
    func addCustomShadowsLogo(_ color: UIColor, opacity: Float, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.masksToBounds = false // Important: Allows the shadow to be visible outside the view's bounds
    }
    
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 10
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}

