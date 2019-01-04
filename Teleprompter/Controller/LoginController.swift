//
//  LoginController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 2/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController {

    var ref: DatabaseReference!
    var homeController: HomeController!
    
    let userInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var loginRegisterButton: BaseButton = {
        let button = BaseButton()
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor.netRoadshowBlue(a: 1)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email Address"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let emailSeparator: BaseView = {
        let view = BaseView()
        view.backgroundColor = UIColor.netRoadshowGray(a: 1)
        return view
    }()
    
    let passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isSecureTextEntry = true
        return field
    }()
    
    let logoView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "NetRoadshowTeleprompterIcon"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let load = UIActivityIndicatorView()
        load.hidesWhenStopped = true
        load.alpha = 0
        load.style = .gray
        return load
    }()
    
    lazy var whyButton: UIButton = {
        let btn = UIButton()
        let title = NSAttributedString(string: "Why?", attributes: [NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.foregroundColor: UIColor.netRoadshowDarkGray(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        btn.setAttributedTitle(title, for: .normal)
        btn.backgroundColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleWhy), for: .touchUpInside)
        return btn
    }()
    
    lazy var skipButton: UIButton = {
        let btn = UIButton()
        let title = NSAttributedString(string: "Skip", attributes: [NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.foregroundColor: UIColor.netRoadshowDarkGray(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        btn.setAttributedTitle(title, for: .normal)
        btn.backgroundColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    func setupView() {
        view.backgroundColor = UIColor.netRoadshowGray(a: 1)
        
        view.addSubview(logoView)
        view.addSubview(userInputView)
        userInputView.addSubview(emailTextField)
        userInputView.addSubview(emailSeparator)
        userInputView.addSubview(passwordTextField)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(loadingIndicator)
        view.addSubview(whyButton)
        view.addSubview(skipButton)
        
        loadingIndicator.center = self.view.center
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
                skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                skipButton.heightAnchor.constraint(equalToConstant: 30),
                skipButton.widthAnchor.constraint(equalToConstant: 50)
                ])
        } else {
            NSLayoutConstraint.activate([
                skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
                skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                skipButton.heightAnchor.constraint(equalToConstant: 30),
                skipButton.widthAnchor.constraint(equalToConstant: 50)
                ])
        }

        
        NSLayoutConstraint.activate([
            userInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInputView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            userInputView.widthAnchor.constraint(equalToConstant: 350),
            userInputView.heightAnchor.constraint(equalToConstant: 120),
            
            emailTextField.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor, constant: 12),
            emailTextField.trailingAnchor.constraint(equalTo: userInputView.trailingAnchor, constant: -12),
            emailTextField.topAnchor.constraint(equalTo: userInputView.topAnchor),
            emailTextField.heightAnchor.constraint(equalTo: userInputView.heightAnchor, multiplier: 0.5),
            
            emailSeparator.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor),
            emailSeparator.widthAnchor.constraint(equalTo: userInputView.widthAnchor, multiplier: 1),
            emailSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            passwordTextField.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor, constant: 12),
            passwordTextField.trailingAnchor.constraint(equalTo: userInputView.trailingAnchor, constant: -12),
            passwordTextField.topAnchor.constraint(equalTo: emailSeparator.bottomAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: userInputView.heightAnchor, multiplier: 0.5),
            
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: userInputView.bottomAnchor, constant: 12),
            loginRegisterButton.widthAnchor.constraint(equalTo: userInputView.widthAnchor),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 50),
            
            whyButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 8),
            whyButton.trailingAnchor.constraint(equalTo: loginRegisterButton.trailingAnchor),
            whyButton.heightAnchor.constraint(equalToConstant: 30),
            whyButton.widthAnchor.constraint(equalToConstant: 50),
            
            loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: userInputView.topAnchor, constant: -12),
            loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: userInputView.widthAnchor),
            loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -24),
            logoView.widthAnchor.constraint(equalToConstant: 200),
            logoView.heightAnchor.constraint(equalToConstant: 200),
            ])
    }
    
    
    //MARK: - Selector Functions
    
    @objc func handleWhy() {
        let alert = UIAlertController(title: "Why Register?", message: "Registering allows you to log in to a second device to use the remote control function.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            self.emailTextField.selectAll(nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleSkip() {
        let alert = UIAlertController(title: "Skip Registration", message: "If you skip registration, then you will not be able to login to a second device and use the remote control functionality. If you skip now, you can always register later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "register", style: .default, handler: { (_) in
            self.emailTextField.selectAll(nil)
        }))
        alert.addAction(UIAlertAction(title: "skip", style: .cancel, handler: { (_) in
            guard let home = self.homeController else {return}
            home.defaults.set(true, forKey: "registrationSkipped")
            self.dismiss(animated: true, completion: nil)
        }))
        alert.preferredAction = alert.actions[0]
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    fileprivate func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        loadingIndicator.alpha = 1
        loadingIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error ?? "")
                self.loadingIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            guard let home = self.homeController else {return}
            home.defaults.set(false, forKey: "registrationSkipped")
            self.loadingIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    fileprivate func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        if password.count < 6 {
            let alert = UIAlertController(title: "Invalid Password", message: "Your password must contain at least 6 characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.passwordTextField.selectAll(nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            loadingIndicator.alpha = 1
            loadingIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if error != nil {
                    print(error ?? "")
                    self.loadingIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
                
                guard let uid = authResult?.user.uid else {return}
                
                self.ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
                let userRef = self.ref.child("users").child(uid)
                let values = ["email": email]
                userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print(err ?? "")
                        self.loadingIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        return
                    }
                    guard let home = self.homeController else {return}
                    home.defaults.set(false, forKey: "registrationSkipped")
                    print("saved user successfully into Firebase DB")
                    self.loadingIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.dismiss(animated: true, completion: nil)
                    
                })
            }
        }
        
    }

}
