//
//  RemoteController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 3/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit

class RemoteController: UIViewController {
    
    
    lazy var playPauseButton: RemoteButton = {
        let btn = RemoteButton()
        btn.setImage(UIImage(named: "play_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = UIColor.netRoadshowBlue(a: 1)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        return btn
    }()
    
    lazy var slowButton: RemoteButton = {
        let btn = RemoteButton()
        btn.setImage(UIImage(named: "snail")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = UIColor.netRoadshowBlue(a: 1)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleSlow), for: .touchUpInside)
        return btn
    }()
    
    lazy var fastButton: RemoteButton = {
        let btn = RemoteButton()
        btn.setImage(UIImage(named: "rabbit")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = UIColor.netRoadshowBlue(a: 1)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleFast), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    

    fileprivate func setupView() {
        view.backgroundColor = UIColor.netRoadshowDarkGray(a: 1)
        
        
        view.addSubview(playPauseButton)
        view.addSubview(slowButton)
        view.addSubview(fastButton)
        
        NSLayoutConstraint.activate([
            playPauseButton.topAnchor.constraint(equalTo: view.topAnchor),
            playPauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playPauseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -1),
            
            slowButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 1),
            slowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slowButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -1),
            slowButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            fastButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 1),
            fastButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 1),
            fastButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fastButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    
    
    //MARK: - Selector Methods
    
    @objc func handlePlayPause() {
        print(123)
    }
    
    @objc func handleSlow() {
        print(456)
    }
    
    @objc func handleFast() {
        print(789)
    }
}
