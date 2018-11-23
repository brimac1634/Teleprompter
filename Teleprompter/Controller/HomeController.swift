//
//  HomeController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import PDFKit

class HomeController: UIViewController, UIDocumentPickerDelegate {
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = UIColor.netRoadshowDarkGray(a: 1)
        label.text = "Teleprompter Text"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textBox: UITextView = {
        let box = UITextView()
        box.layer.cornerRadius = 3
        box.layer.borderWidth = 2
        box.layer.borderColor = UIColor.netRoadshowDarkGray(a: 1).cgColor
        box.isEditable = true
        box.clipsToBounds = true
        box.backgroundColor = UIColor.netRoadshowGray(a: 1)
        box.font = UIFont.systemFont(ofSize: 30)
        box.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        box.translatesAutoresizingMaskIntoConstraints = false
        return box
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
        
        view.addSubview(topLabel)
        view.addSubview(textBox)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            topLabel.heightAnchor.constraint(equalToConstant: 40),
            
            textBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textBox.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 16),
            textBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -142),
            textBox.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.topAnchor.constraint(equalTo: textBox.bottomAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: textBox.trailingAnchor),

            ])
        
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
        
        let importImage = UIImage(named: "import")?.withRenderingMode(.alwaysTemplate)
        let importButton = UIButton()
        importButton.setImage(importImage, for: .normal)
        importButton.addTarget(self, action: #selector(handleImport), for: .touchUpInside)
        importButton.tintColor = UIColor.netRoadshowBlue(a: 1)
        let barItem = UIBarButtonItem(customView: importButton)
        
        barItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        barItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        navigationItem.rightBarButtonItem = barItem
    }
    
    //MARK: - Gesture Selectors
    
    @objc func handleBackgroundTap() {
        textBox.resignFirstResponder()
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
    
    @objc func handleImport() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text", "com.apple.iwork.pages.pages", "public.data"], in: .import)
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    //MARK: - Document Picker Methods
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        do {
            let contents = try String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
            print(contents)
            textBox.text = contents
        } catch {
            print("no text found")
        }
        

        if let pdf = PDFDocument(url: url) {
            let pageCount = pdf.pageCount
            let documentContent = NSMutableAttributedString()
            
            for i in 1 ..< pageCount {
                guard let page = pdf.page(at: i) else { continue }
                guard let pageContent = page.attributedString else { continue }
                documentContent.append(pageContent)
            }
            textBox.attributedText = documentContent
        }

    }
}
