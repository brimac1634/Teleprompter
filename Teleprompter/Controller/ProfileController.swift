//
//  ProfileController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 3/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ProfileController: UIViewController {
    
    let logoView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "NetRoadshowTeleprompterIcon"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let userLabel: BaseTextView = {
        let label = BaseTextView()
        label.text = "Hello"
        return label
    }()
    
    let logoutButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("Logout", for: .normal)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(logoView)
        view.addSubview(userLabel)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            userLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            userLabel.widthAnchor.constraint(equalToConstant: 200),
            userLabel.heightAnchor.constraint(equalToConstant: 100),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 12),
            logoutButton.widthAnchor.constraint(equalTo: userLabel.widthAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.bottomAnchor.constraint(equalTo: userLabel.topAnchor, constant: -24),
            logoView.widthAnchor.constraint(equalToConstant: 200),
            logoView.heightAnchor.constraint(equalToConstant: 200)
            ])
    }
}
