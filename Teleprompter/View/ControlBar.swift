//
//  ControlBar.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class ControlBar: BaseView {
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.netRoadshowBlue(a: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let startButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.netRoadshowBlue(a: 1), for: .normal)
        return button
    }()
    
    override func setupView() {
       super.setupView()
        
        backgroundColor = UIColor.netRoadshowGray(a: 1)
        
        addSubview(backButton)
        addSubview(startButton)
        
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            backButton.heightAnchor.constraint(equalToConstant: 28),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.bottomAnchor.constraint(equalTo: backButton.bottomAnchor),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
            ])
        
        
    }
    
    
}
