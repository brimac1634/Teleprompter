//
//  HomeController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    let textBox: UITextView = {
        let box = UITextView()
        box.layer.cornerRadius = 3
        box.isEditable = true
        box.clipsToBounds = true
        box.backgroundColor = UIColor.netRoadshowGray(a: 1)
        box.font = UIFont.systemFont(ofSize: 30)
        box.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        box.translatesAutoresizingMaskIntoConstraints = false
        return box
    }()
    
    let colorButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .black
        return button
    }()
    
    let startButton: BaseButton = {
        let button = BaseButton()
        button.dropShadow()
        button.backgroundColor = UIColor.netRoadshowGray(a: 1)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.netRoadshowBlue(a: 1), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavBar()
        
        
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(textBox)
        view.addSubview(colorButton)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            textBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textBox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            textBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -142),
            textBox.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.topAnchor.constraint(equalTo: textBox.bottomAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: textBox.trailingAnchor),
            
//            colorButton.widthAnchor.constraint(equalTo: startButton.widthAnchor, multiplier: 1),
//            colorButton.heightAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),
//            colorButton.trailingAnchor.constraint(equalTo: startButton.leadingAnchor, constant: -16),
//            colorButton.topAnchor.constraint(equalTo: startButton.topAnchor)
            
            
            ])
        
        colorButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleColor)))
        startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStart)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap)))
        view.isUserInteractionEnabled = true
    }
    
    private func setupNavBar() {
        
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = UIColor.netRoadshowGray(a: 1)
            navBar.tintColor = UIColor.netRoadshowBlue(a: 1)
            
        }
        
        let logoImage = UIImageView(image: UIImage(named: "logo"))
        logoImage.contentMode = .scaleAspectFit
        navigationItem.titleView = logoImage
        
    }
    
    @objc func handleBackgroundTap() {
        textBox.resignFirstResponder()
    }
    
    @objc func handleColor() {
        print(123)
        
    }
    
    @objc func handleStart() {
        if textBox.text?.count != 0 {
            let rollingTextController = RollingTextController()
            rollingTextController.textInput = textBox.text
            rollingTextController.view.backgroundColor = .black
            navigationController?.isNavigationBarHidden = true
            navigationController?.pushViewController(rollingTextController, animated: true)
        } else {
            let alert = UIAlertController(title: "Missing Text", message: "Add to the textfield before proceeding", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action:UIAlertAction) in
                self.textBox.selectAll(nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
}
