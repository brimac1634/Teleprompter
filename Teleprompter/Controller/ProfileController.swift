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
        label.textAlignment = .center
        label.isEditable = false
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var logoutButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("Logout", for: .normal)
        btn.titleLabel?.textColor = UIColor.white
        btn.backgroundColor = UIColor.netRoadshowDarkGray(a: 1)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return btn
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        configureDatabase()
        
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(logoView)
        view.addSubview(userLabel)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            userLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            userLabel.widthAnchor.constraint(equalToConstant: 300),
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
    
    //MARK: - Selector Methods
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Unable to sign out: ", error)
        }
        
        navigationController?.popViewController(animated: true)
        let loginController = LoginController()
        navigationController?.present(loginController, animated: true, completion: nil)
    }
    
    //MARK: - Firebase Methods
    
    fileprivate func configureDatabase() {
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .gray
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                guard let currentUser = value["email"] else {return}
                let currentUserString = String(describing: currentUser)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: "You are currently signed in as...\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.netRoadshowDarkGray(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                attributedString.append(NSAttributedString(string: currentUserString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.netRoadshowBlue(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                self.userLabel.attributedText = attributedString
                
                loadingIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            } else {
                self.userLabel.attributedText = NSAttributedString(string: "Unable to retrieve current user, please check internet signal", attributes: [NSAttributedString.Key.foregroundColor: UIColor.netRoadshowDarkGray(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
                loadingIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }, withCancel: nil)
    }
}
