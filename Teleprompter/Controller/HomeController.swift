//
//  HomeController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import PDFKit
import MobileCoreServices
import RealmSwift
import Firebase
import FirebaseDatabase
import GoogleMobileAds

class HomeController: UIViewController, UIDocumentPickerDelegate, GADRewardBasedVideoAdDelegate {
    
    
    let realm = try! Realm()
    var ref: DatabaseReference!
    let defaults = UserDefaults.standard
    
    var usingIpad: Bool = true
    var textBoxIsEditing: Bool = false
    var infoIsShowing: Bool = false
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = UIColor.netRoadshowDarkGray(a: 1)
        label.text = "Teleprompter Text"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textBox: BaseTextView = {
        let box = BaseTextView()
        box.text = "Type or paste your script here..."
        box.textColor = UIColor.lightGray
        box.layer.cornerRadius = 12
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.netRoadshowGray(a: 1).cgColor
        box.isEditable = true
        box.clipsToBounds = true
        box.showsHorizontalScrollIndicator = false
        box.backgroundColor = UIColor.netRoadshowGray(a: 1)
        box.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        box.translatesAutoresizingMaskIntoConstraints = false
        return box
    }()
    
    let startButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = UIColor.netRoadshowBlue(a: 1)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.netRoadshowGray(a: 1), for: .normal)
        return button
    }()
    
    let markerButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = UIColor.netRoadshowDarkGray(a: 1)
        button.setTitle("Add Mark", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    let infoButton: BaseButton = {
        let button = BaseButton()
        let image = UIImage(named: "info")?.withRenderingMode(.alwaysTemplate)
        button.backgroundColor = .clear
        button.setBackgroundImage(image, for: .normal)
        button.tintColor = UIColor.netRoadshowBlue(a: 1)
        return button
    }()
    
    var keyboardHeight: CGFloat = 0
    var currentScriptName: String = ""
    
    var infoPopUp: InfoPopUp!
    
    var startButtonBottomConstraint: NSLayoutConstraint!
    var markerButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
        checkIfUserIsLoggedIn()
        
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            usingIpad = true
        } else {
            usingIpad = false
        }
        
        setupView()
        setupNavBar()
        checkCanSkipAds()
        setupAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        setupAd()
        configureIAP()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        topLabel.font = usingIpad ? UIFont.systemFont(ofSize: 26) : UIFont.systemFont(ofSize: 20)
        
        view.addSubview(topLabel)
        view.addSubview(textBox)
        view.addSubview(startButton)
        view.addSubview(markerButton)
        view.addSubview(infoButton)
        
        if #available(iOS 11.0, *) {
            startButtonBottomConstraint = startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            
            markerButtonBottomConstraint = markerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            textBox.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95).isActive = true
        } else {
            // Fallback on earlier versions
            startButtonBottomConstraint = startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
            
            markerButtonBottomConstraint = markerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
            textBox.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        }
        
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            topLabel.heightAnchor.constraint(equalToConstant: 35),
            
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            startButtonBottomConstraint,
            startButton.trailingAnchor.constraint(equalTo: textBox.trailingAnchor),
            
            textBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textBox.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 8),
            textBox.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -8),
            
            markerButton.widthAnchor.constraint(equalToConstant: 120),
            markerButton.heightAnchor.constraint(equalToConstant: 40),
            markerButtonBottomConstraint,
            markerButton.leadingAnchor.constraint(equalTo: textBox.leadingAnchor),
            
            infoButton.widthAnchor.constraint(equalToConstant: 28),
            infoButton.heightAnchor.constraint(equalToConstant: 28),
            infoButton.centerYAnchor.constraint(equalTo: markerButton.centerYAnchor),
            infoButton.leadingAnchor.constraint(equalTo: markerButton.trailingAnchor, constant: 8)

            ])
        
        startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStart)))
        markerButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddMarker)))
        infoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInfo)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap)))
        view.isUserInteractionEnabled = true
        textBox.delegate = self
    }
    
    private func setupNavBar() {
        
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = UIColor.netRoadshowGray(a: 1)
            navBar.tintColor = UIColor.netRoadshowBlue(a: 1)
            
        }
        
        let logoImage = UIImageView(image: UIImage(named: "logo"))
        logoImage.contentMode = .scaleAspectFit
        navigationItem.titleView = logoImage
        
        
        let profileButton = UIBarButtonItem(image: UIImage(named: "profile"), style: .plain, target: self, action: #selector(handleProfile))
        profileButton.tintColor = UIColor.netRoadshowBlue(a: 1)
        
        let remoteButton = UIBarButtonItem(image: UIImage(named: "remote"), style: .plain, target: self, action: #selector(handleRemote))
        remoteButton.tintColor = UIColor.netRoadshowBlue(a: 1)
        
        navigationItem.leftBarButtonItems = [profileButton, remoteButton]
        
        let folderButton = UIBarButtonItem(image: UIImage(named: "folder"), style: .plain, target: self, action: #selector(handleFolder))
        folderButton.tintColor = UIColor.netRoadshowBlue(a: 1)
        
        let importButton = UIBarButtonItem(image: UIImage(named: "import"), style: .plain, target: self, action: #selector(handleImport))
        importButton.tintColor = UIColor.netRoadshowBlue(a: 1)
        
        navigationItem.rightBarButtonItems = [folderButton, importButton]
        
        
    }

    fileprivate func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil && defaults.bool(forKey: "registrationSkipped") == false {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }

    //MARK: - Gesture Selectors
    
    @objc func handleProfile() {
        if defaults.bool(forKey: "registrationSkipped") == true {
            handleLogout()
        } else if Auth.auth().currentUser?.uid != nil {
            let profileController = ProfileController()
            profileController.homeController = self
            navigationController?.pushViewController(profileController, animated: true)
        }
        
    }
    
    @objc func handleRemote() {
        if defaults.bool(forKey: "registrationSkipped") == true {
            let alert = UIAlertController(title: "Login Needed", message: "You must login before you can use the remote control function.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "login", style: .default, handler: { (_) in
                self.handleLogout()
            }))
            alert.preferredAction = alert.actions[1]
            self.present(alert, animated: true, completion: nil)
        } else if Auth.auth().currentUser?.uid != nil {
            if Reachability.isConnectedToNetwork() {
                if defaults.bool(forKey: "canSkipAds") == false {
                    defaults.set(false, forKey: "canSkipAds")
                    let alert = UIAlertController(title: "Remote Control Feature", message: "Choose one of the options below to unlock the remote control...", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Watch brief ad to unlock once", style: .default, handler: { (_) in
                        print("should play video")
                        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
                            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Unlock for life", style: .default, handler: { (_) in
                        print("life")
                        IAPHandler.shared.purchaseMyProduct(index: IAPHandler.shared.NON_CONSUMABLE_PURCHASE_PRODUCT_ID)
                    }))
                    alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (_) in
                    }))
                    alert.preferredAction = alert.actions[0]
                    
                    if let popoverController = alert.popoverPresentationController {
                        guard let remoteButton = navigationItem.leftBarButtonItems?[1] else {return}
                        popoverController.barButtonItem = remoteButton
                    }
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let remoteController = RemoteController()
                    navigationController?.pushViewController(remoteController, animated: true)
                }
            } else {
                self.present(Alerts.showAlert(title: "No Internet", text: "Internet connection is needed to use the remote control feature. Please check internet connection and try again."), animated: true, completion: nil)
            }
            
        }
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Unable to sign out: ", error)
        }
        
        let loginController = LoginController()
        loginController.homeController = self
        navigationController?.present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleBackgroundTap() {
        textBox.resignFirstResponder()

    }
    
    @objc func handleStart() {
        if textBox.text?.count != 0 && textBox.text != "Type or paste your script here..." {
            let rollingTextController = RollingTextController()
            guard let text = textBox.text else {return}
            let marker = "##"
            let separatedTextArray = text.components(separatedBy: marker)
            rollingTextController.markerArray = createMarkers(textBody: text, textArray: separatedTextArray)
            rollingTextController.textInput = text
            rollingTextController.view.backgroundColor = .black
            navigationController?.isNavigationBarHidden = true
            navigationController?.pushViewController(rollingTextController, animated: true)
        } else {
            noTextFoundAlert()
        }
        
    }

    @objc func handleImport() {
        var alert: UIAlertController!
        
        if #available(iOS 11.0, *) {
            alert = UIAlertController(title: "Import Text", message: "Text can only be imported from .pdf, .txt, and .rtf files at this time.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (finished) in
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text", kUTTypeText as String, kUTTypeRTF as String, kUTTypePDF as String], in: UIDocumentPickerMode.import)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
            }))
        } else {
            alert = UIAlertController(title: "Import Text", message: "Your version of iOS only supports .txt and .rtf files.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (finished) in
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text", kUTTypeText as String, kUTTypeRTF as String], in: UIDocumentPickerMode.import)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.preferredAction = alert.actions[0]
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func handleFolder() {
        let actionAlert = UIAlertController(title: "Scripts", message: nil, preferredStyle: .actionSheet)
        actionAlert.addAction(UIAlertAction(title: "Open", style: .default, handler: { (_) in
            //Open
            let savedScripts = SavedScriptsController()
            savedScripts.scriptList = self.realm.objects(Script.self).sorted(byKeyPath: "dateCreated", ascending: false)
            savedScripts.homeController = self
            self.navigationController?.pushViewController(savedScripts, animated: true)
        }))
        actionAlert.addAction(UIAlertAction(title: "New", style: .default, handler: { (_) in
            //New
            self.createNewScriptButton()
        }))
        actionAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            //Save
            self.saveCurrentScript()
        }))
        actionAlert.addAction(UIAlertAction(title: "Save As", style: .default, handler: { (_) in
            //Save As
            self.saveNewScript()
        }))
        actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = actionAlert.popoverPresentationController {
            guard let folderButton = navigationItem.rightBarButtonItems?[0] else {return}
            popoverController.barButtonItem = folderButton
        }
        
        self.present(actionAlert, animated: true, completion: nil)

    }
    
    @objc func handleAddMarker() {
        if textBoxIsEditing == false {
            textBox.selectAll(nil)
            insertMark()
        } else {
            insertMark()
        }
    }
    
    fileprivate func insertMark() {
        if let selectedRange = textBox.selectedTextRange {
            textBox.insertText("####")
            guard let newPosition = textBox.position(from: selectedRange.start, offset: 2) else {return}
            textBox.selectedTextRange = textBox.textRange(from: newPosition, to: newPosition)
            
        }
    }
    
    @objc func handleInfo() {
        guard let window = UIApplication.shared.keyWindow else {return}
        infoPopUp = InfoPopUp()
        
        window.addSubview(infoPopUp)
        
        NSLayoutConstraint.activate([
            infoPopUp.topAnchor.constraint(equalTo: window.topAnchor),
            infoPopUp.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            infoPopUp.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            infoPopUp.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
       
        
        textBox.resignFirstResponder()
        infoPopUp.setupView()

    }
    
    //MARK: - Document Picker Methods
    
    fileprivate func importRTF(fileURL: URL) {
        var readString = ""
        do {
            let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: fileURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            readString = attributedStringWithRtf.string
            textBox.textColor = .black
            textBox.text = readString
        } catch {
            print("Failed to read file: \(error)")
            presentImportFailAlert()
        }
    }
    
    fileprivate func importTxt(fileURL: URL) {
        var readString = ""
        do {
            let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: fileURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.plain], documentAttributes: nil)
            readString = attributedStringWithRtf.string
            textBox.textColor = .black
            textBox.text = readString
        } catch {
            print("Failed to read file: \(error)")
            presentImportFailAlert()
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if #available(iOS 11.0, *) {
            if let pdf = PDFDocument(url: url) {
                print("PDF coming")
                let pageCount = pdf.pageCount
                let documentContent = NSMutableAttributedString()
                
                for i in 0 ..< pageCount {
                    guard let page = pdf.page(at: i) else { continue }
                    guard let pageContent = page.attributedString else { continue }
                    documentContent.append(pageContent)
                }
                documentContent.setFontFace(font: UIFont.systemFont(ofSize: textBox.universalFontSize), color: UIColor.black)
                
                if documentContent.string == "" {
                    presentImportFailAlert()
                } else {
                    textBox.attributedText = documentContent
                }
                
            } else if url.pathExtension == "rtf" {
                importRTF(fileURL: url)
            } else if url.pathExtension == "txt" {
                importTxt(fileURL: url)
            }
        } else {
            if url.pathExtension == "rtf" {
                importRTF(fileURL: url)
            } else if url.pathExtension == "txt" {
                importTxt(fileURL: url)
            }
        }

    }
    
    //MARK: - Alert Methods

    fileprivate func presentImportFailAlert() {
        let alert = UIAlertController(title: "Missing Text", message: "The text could not be imported", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action:UIAlertAction) in
            self.textBox.selectAll(nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func noTextFoundAlert() {
        let alert = UIAlertController(title: "Missing Text", message: "Add to the textfield before proceeding", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action:UIAlertAction) in
            self.textBox.selectAll(nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func overWriteAlert(script: Script) {
        let alert = UIAlertController(title: "There is already a script named \"\(script.scriptName)\"", message: "Do you wish to save over it?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let scriptText = self.textBox.text else {return}
            let date = Date()
            try! self.realm.write {
                script.scriptBody = scriptText
                script.dateCreated = date
            }
            
            self.savedConfirmation()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.saveNewScript()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func savedConfirmation() {
        self.present(Alerts.showAlert(title: "Saved", text: "Your script has been saved"), animated: true, completion: nil)
    }
    
    fileprivate func saveNewScript() {
        let alert = UIAlertController(title: "New Script", message: "Give your script a unique name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Ex.: Company Speech"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let textField = alert.textFields else {return}
            let field = textField[0]
            if let chosenScript = self.realm.objects(Script.self).filter("scriptName = %@", field.text!).first {
                self.overWriteAlert(script: chosenScript)
            } else {
                let name = field.text ?? "Untitled"
                let scriptBody = self.textBox.text ?? ""
                try! self.realm.write {
                    let script = Script()
                    script.scriptName = name
                    script.scriptBody = scriptBody
                    self.realm.add(script)
                }
                let databaseValues: [String: Any] = ["scriptBody": scriptBody, "dateCreated": Date()]
                self.topLabel.text = field.text
                self.currentScriptName = field.text ?? ""
                self.savedConfirmation()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.preferredAction = saveAction
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func saveCurrentScript() {
        if let currentScript = self.realm.objects(Script.self).filter("scriptName = %@", currentScriptName).first {
            //save over current
            let date = Date()
            try! realm.write {
                currentScript.scriptBody = textBox.text
                currentScript.dateCreated = date
            }
            
            savedConfirmation()
        } else {
            //save as new
            saveNewScript()
        }
    }
    
    func createNewScriptButton() {
        if currentScriptName == "" {
            if textBox.text.count != 0 && textBox.text != "Type or paste your script here..." {
                //ask to save as then create new
                currentScriptHasNotBeenSavedAlert()
            } else {
                //create new
                createNew()
            }
        } else {
            guard let currentScript = self.realm.objects(Script.self).filter("scriptName = %@", self.currentScriptName).first else {return}
            if currentScript.scriptBody != textBox.text {
                //we have a saved script open
                //ask to save then create new
                let alert = UIAlertController(title: "\"\(currentScriptName)\" Script", message: "Would you like to save your current script?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                    guard let scriptText = self.textBox.text else {return}
                    let date = Date()
                    //save over current
                    try! self.realm.write {
                        currentScript.scriptBody = scriptText
                        currentScript.dateCreated = date
                    }
                    
                    let alert = UIAlertController(title: "Saved", message: "Your script has been saved", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                        self.createNew()
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }))
                alert.addAction(UIAlertAction(title: "Do Not Save", style: .default, handler: { (_) in
                    self.createNew()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                createNew()
            }
            
        }
    }
    
    //create new
    fileprivate func createNew() {
        saveNewScript()
        textBox.text = ""
        topLabel.text = ""
    }
    
    //ask to save then create new
    fileprivate func currentScriptHasNotBeenSavedAlert() {
        let alert = UIAlertController(title: "Your current script has not been saved", message: "Would you like to save now?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            //Save as
            let alert = UIAlertController(title: "New Script", message: "Give your script a unique name", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Ex.: Company Speech"
            }
            let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
                guard let textField = alert.textFields else {return}
                let field = textField[0]
                if let chosenScript = self.realm.objects(Script.self).filter("scriptName = %@", field.text!).first {
                    self.overWriteAlert(script: chosenScript)
                } else {
                    guard let scriptName = field.text else {return}
                    guard let scriptText = self.textBox.text else {return}
                    try! self.realm.write {
                        let script = Script()
                        script.scriptName = scriptName
                        script.scriptBody = scriptText
                        self.realm.add(script)
                    }
                    
                    self.topLabel.text = field.text
                    self.currentScriptName = field.text ?? ""
                    let alert = UIAlertController(title: "Saved", message: "Your script has been saved", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                        self.createNew()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.preferredAction = saveAction
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Do Not Save", style: .default, handler: { (_) in
            //do not save
            self.textBox.text = ""
            self.createNew()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Marker Method
    
    fileprivate func createMarkers(textBody: String, textArray: [String]) -> [String] {
        var markerList = [String]()
        var markerCount: Int = 0
        for i in 0..<textArray.count {
            if i % 2 != 0 {
                markerCount += 1
                if textArray[i] == "" {
                    markerList.append("Section \(markerCount)")
                } else {
                    markerList.append(textArray[i])
                }
            }
        }
        return markerList
    }
    
    //MARK: - AdMob Method
    
    fileprivate func loadAd() {
        // real video code: ca-app-pub-7610437866891957/2341921646
        // test code: ca-app-pub-3940256099942544/1712485313
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
    }
    
    fileprivate func setupAd() {
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        loadAd()
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        loadAd()
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        let remoteController = RemoteController()
        navigationController?.pushViewController(remoteController, animated: true)
    }
    
    private func checkCanSkipAds() {
        guard Reachability.isConnectedToNetwork() else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                if let skipAds = value["canSkipAds"] {
                    self.defaults.set(skipAds, forKey: "canSkipAds")
                } else {
                    self.defaults.set(false, forKey: "canSkipAds")
                }
            }
        }, withCancel: nil)
    }
    
    //MARK: - IAP Methods
    
    fileprivate func configureIAP() {
        guard defaults.bool(forKey: "canSkipAds") == false else {return}
        print("can skip ads: ", defaults.bool(forKey: "canSkipAds"))
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                TeleDatabase.saveData(values: ["canSkipAds": true], uidChildren: nil)
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
                strongSelf.defaults.set(true, forKey: "canSkipAds")
                print("defaults: ", strongSelf.defaults.bool(forKey: "canSkipAds"))
            }
        }
        
    }
    
}




