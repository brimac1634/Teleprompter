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
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BaseButton: UIButton  {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    
    func setupView() {
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.font = UIFont.systemFont(ofSize: 26)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BaseLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.textAlignment = .center
        self.textColor = UIColor.netRoadshowDarkGray(a: 1)
        self.font = UIFont.systemFont(ofSize: 26)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
