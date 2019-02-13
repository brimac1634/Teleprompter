//
//  RemoteController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 3/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RemoteController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    
    var ref: DatabaseReference!
    
    var scrollViewIsScrolling: Bool = false
    var scrollSpeed: CGFloat = 0
    var markerList: [String] = []
    
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
    
    let markerInput: MarkerInput = {
        let input = MarkerInput()
        return input
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
       
        setupView()
        checkIfFirstUse()
        setScrollSpeed()
        setMarkerList()
        observeStateChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Remote Control"
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        updateUseCount()
    }
    

    fileprivate func setupView() {
        view.backgroundColor = UIColor.netRoadshowDarkGray(a: 1)
        markerInput.picker.dataSource = self
        markerInput.picker.delegate = self
        markerInput.markerInputField.delegate = self
        
        view.addSubview(playPauseButton)
        view.addSubview(slowButton)
        view.addSubview(fastButton)
        view.addSubview(markerInput)
        
        NSLayoutConstraint.activate([
            playPauseButton.topAnchor.constraint(equalTo: view.topAnchor),
            playPauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playPauseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -1),
            
            markerInput.heightAnchor.constraint(equalToConstant: 100),
            markerInput.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markerInput.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            markerInput.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            slowButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 1),
            slowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slowButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -1),
            slowButton.bottomAnchor.constraint(equalTo: markerInput.topAnchor, constant: -2),
            
            fastButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 1),
            fastButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 1),
            fastButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fastButton.bottomAnchor.constraint(equalTo: markerInput.topAnchor, constant: -2)
            
            ])
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleResignMark)))
    }
    
    
    fileprivate func checkIfFirstUse() {
        if defaults.bool(forKey: "firstUseComplete") == false {
            self.present(Alerts.showAlert(title: "Remote Control", text: "Login to a second device with the same credentials and start the teleprompter. You can then remotely control the scrolling from this device. NOTE: Both devices must be connected to the internet."), animated: true, completion: nil)
            defaults.set(true, forKey: "firstUseComplete")
        }
    }
    
    //MARK: - Selector Methods
    
    @objc func handlePlayPause() {
        updateStateOfScroll()
    }
    
    @objc func handleSlow() {
        guard scrollSpeed > 5 else {return}
        scrollSpeed = scrollSpeed - 5
        updateScrollSpeed()
    }
    
    @objc func handleFast() {
        guard scrollSpeed <= 145 else {return}
        scrollSpeed = scrollSpeed + 5
        updateScrollSpeed()
    }
    
    @objc func handleResignMark() {
        markerInput.markerInputField.resignFirstResponder()
    }
    
    //MARK: - Firebase Methods
    
    fileprivate func updateStateOfScroll() {
        scrollViewIsScrolling = !scrollViewIsScrolling
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userRef = ref.child("users").child(uid)
        let values = ["scrollViewIsScrolling": scrollViewIsScrolling]
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            print("updated state of scroll")
        })
    }
    
    fileprivate func updateScrollSpeed() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userRef = ref.child("users").child(uid)
        let values = ["scrollSpeed": scrollSpeed]
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            print("updated state of scroll")
        })
        
    }
    
    fileprivate func jumpToMarker(marker: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userRef = ref.child("users").child(uid)
        let values = ["jumpToMarker": marker]
        userRef.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            print("jumped to \(self.markerList[marker])")
        }
    }
    
    fileprivate func setScrollSpeed() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                guard let speed = value["scrollSpeed"] else {return}
                self.scrollSpeed = CGFloat(speed.floatValue)
            }
        }, withCancel: nil)
    }
    
    fileprivate func setMarkerList() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                guard let markerArray = value["markerList"] else {return}
                self.markerList = markerArray as! [String]
                self.markerInput.picker.reloadAllComponents()
            }
        }, withCancel: nil)
    }

    
    fileprivate func observeStateChange() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        ref.child("users").child(uid).observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            if key == "scrollViewIsScrolling" {
                let valueChange = snapshot.value as! Int
                var isScrolling: Bool = false
                if valueChange == 0 {
                    isScrolling = false
                } else {
                    isScrolling = true
                }
                if isScrolling != self.scrollViewIsScrolling {
                    self.scrollViewIsScrolling = isScrolling
                }
                
            } else if key == "scrollSpeed" {
                let valueChange = snapshot.value as! CGFloat
                if valueChange != self.scrollSpeed {
                    self.scrollSpeed = valueChange
                }  
            } else if key == "markerList" {
                let valueChange = snapshot.value as! [String]
                self.markerList = valueChange
                self.markerInput.picker.reloadAllComponents()
            }
        }, withCancel: nil)
    }
    
    func updateUseCount() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        TeleDatabase.saveData(values: ["remoteLastUsed": Date()], uidChildren: nil)
        let usedRemoteCount = ref.child("users").child(uid).child("usedRemoteCount")
        usedRemoteCount.observeSingleEvent(of: .value, with: { snapshot in
            var currentCount = snapshot.value as? Int ?? 0
            currentCount += 1
            usedRemoteCount.setValue(currentCount)
        })
    }
    
    //MARK: - UIPickerView and UITextField Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        playPauseButton.isUserInteractionEnabled = false
        fastButton.isUserInteractionEnabled = false
        slowButton.isUserInteractionEnabled = false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        playPauseButton.isUserInteractionEnabled = true
        fastButton.isUserInteractionEnabled = true
        slowButton.isUserInteractionEnabled = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return markerList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return markerList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        jumpToMarker(marker: row)
        markerInput.markerInputField.resignFirstResponder()
    }
    

}
