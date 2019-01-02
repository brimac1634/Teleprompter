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
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let nameSeparator: BaseView = {
        let view = BaseView()
        view.backgroundColor = UIColor.netRoadshowGray(a: 1)
        return view
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    func setupView() {
        view.backgroundColor = UIColor.netRoadshowGray(a: 1)
        
        view.addSubview(logoView)
        view.addSubview(userInputView)
        userInputView.addSubview(nameTextField)
        userInputView.addSubview(nameSeparator)
        userInputView.addSubview(emailTextField)
        userInputView.addSubview(emailSeparator)
        userInputView.addSubview(passwordTextField)
        view.addSubview(loginRegisterButton)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                userInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                userInputView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                userInputView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -24),
                userInputView.heightAnchor.constraint(equalToConstant: 180)
                ])
        } else {
            NSLayoutConstraint.activate([
                userInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                userInputView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                userInputView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -52),
                userInputView.heightAnchor.constraint(equalToConstant: 180)
                ])
        }
        
        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.bottomAnchor.constraint(equalTo: userInputView.topAnchor, constant: -24),
            logoView.widthAnchor.constraint(equalToConstant: 200),
            logoView.heightAnchor.constraint(equalToConstant: 200),
            
            nameTextField.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor, constant: 12),
            nameTextField.trailingAnchor.constraint(equalTo: userInputView.trailingAnchor, constant: -12),
            nameTextField.topAnchor.constraint(equalTo: userInputView.topAnchor),
            nameTextField.heightAnchor.constraint(equalTo: userInputView.heightAnchor, multiplier: 1/3),
            
            nameSeparator.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor),
            nameSeparator.widthAnchor.constraint(equalTo: userInputView.widthAnchor, multiplier: 1),
            nameSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            emailTextField.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor, constant: 12),
            emailTextField.trailingAnchor.constraint(equalTo: userInputView.trailingAnchor, constant: -12),
            emailTextField.topAnchor.constraint(equalTo: nameSeparator.bottomAnchor),
            emailTextField.heightAnchor.constraint(equalTo: userInputView.heightAnchor, multiplier: 1/3),
            
            emailSeparator.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor),
            emailSeparator.widthAnchor.constraint(equalTo: userInputView.widthAnchor, multiplier: 1),
            emailSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            passwordTextField.leadingAnchor.constraint(equalTo: userInputView.leadingAnchor, constant: 12),
            passwordTextField.trailingAnchor.constraint(equalTo: userInputView.trailingAnchor, constant: -12),
            passwordTextField.topAnchor.constraint(equalTo: emailSeparator.bottomAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: userInputView.heightAnchor, multiplier: 1/3),
            
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: userInputView.bottomAnchor, constant: 12),
            loginRegisterButton.widthAnchor.constraint(equalTo: userInputView.widthAnchor),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    
    //MARK: - Selector Functions
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        if password.count < 6 {
            let alert = UIAlertController(title: "Invalid Password", message: "Your password must contain at least 6 characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.passwordTextField.selectAll(nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            guard let uid = authResult?.user.uid else {return}
            
            self.ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
            let userRef = self.ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
                print("saved user successfully into Firebase DB")
            })
        }
    }

}
