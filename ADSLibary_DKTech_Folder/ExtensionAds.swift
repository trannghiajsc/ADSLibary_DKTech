//
//  ExtensionAds.swift
//  GoogleAds-Framework-InHouse
//
//  Created by Pham Van Thai on 02/08/2023.
//

import UIKit

extension UILabel {
    class func textHeight(withWidth width: CGFloat, font: UIFont, text: String) -> CGFloat {
            return textSize(font: font, text: text, width: width).height
        }
    class func textSize(font: UIFont, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
            label.numberOfLines = 0
            label.font = font
            label.text = text
            label.sizeToFit()
            return label.frame.size
        }
}
