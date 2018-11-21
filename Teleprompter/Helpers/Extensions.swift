//
//  Extensions.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit


extension UIColor {
    static func netRoadshowGray(a: CGFloat) -> UIColor {
        return UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: a)
    }
    static func netRoadshowBlue(a: CGFloat) -> UIColor {
        return UIColor(red: 40/255, green: 82/255, blue: 152/255, alpha: a)
    }
}

extension UIView {
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
    }
    
}

extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
