//
//  UILabel+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/11/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var maxLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
