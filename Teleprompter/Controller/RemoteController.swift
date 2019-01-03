//
//  RemoteController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 3/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit

class RemoteController: UIViewController {
    
    let playPauseButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(UIImage(named: "play"), for: .normal)
        btn.tintColor = UIColor.netRoadshowBlue(a: 1)
        return btn
    }()
    
    let slowButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(UIImage(named: "snail"), for: .normal)
        btn.tintColor = UIColor.netRoadshowBlue(a: 1)
        return btn
    }()
    
    let fastButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(UIImage(named: "rabbit"), for: .normal)
        btn.tintColor = UIColor.netRoadshowBlue(a: 1)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    

    fileprivate func setupView() {
        view.backgroundColor = UIColor.netRoadshowGray(a: 1)
        
        view.addSubview(playPauseButton)
        view.addSubview(slowButton)
        view.addSubview(fastButton)
        
        NSLayoutConstraint.activate([
            playPauseButton.topAnchor.constraint(equalTo: view.topAnchor),
            playPauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playPauseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            slowButton.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor),
            slowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slowButton.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            slowButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            fastButton.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor),
            fastButton.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            fastButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fastButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}
