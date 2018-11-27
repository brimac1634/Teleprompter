//
//  BaseView.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BaseButton: UIButton  {
    var universalFontSize: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    
    func setupView() {
        if ( UIDevice.current.model.range(of: "iPad") != nil){
            universalFontSize = 24
        } else {
            universalFontSize = 18
        }
        
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.font = UIFont.systemFont(ofSize: universalFontSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BaseLabel: UILabel {
    var universalFontSize: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        if ( UIDevice.current.model.range(of: "iPad") != nil){
            universalFontSize = 24
        } else {
            universalFontSize = 18
        }
        
        self.textAlignment = .center
        self.textColor = UIColor.netRoadshowDarkGray(a: 1)
        self.font = UIFont.systemFont(ofSize: universalFontSize)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

class BaseTextView: UITextView {
    var universalFontSize: CGFloat = 0
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
    }
    
    func setupView() {
        
        if ( UIDevice.current.model.range(of: "iPad") != nil){
            universalFontSize = 30
        } else {
            universalFontSize = 22
        }
        
        self.font = UIFont.systemFont(ofSize: universalFontSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
