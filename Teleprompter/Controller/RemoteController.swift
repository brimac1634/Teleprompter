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

class RemoteController: UIViewController {
    
    var ref: DatabaseReference!
    
    var scrollViewIsScrolling: Bool = false
    var scrollSpeed: CGFloat = 0
    
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
        ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
        
        setupView()
        setScrollSpeed()
        observeStateChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Remote Control"
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
        updateStateOfScroll()
    }
    
    @objc func handleSlow() {
        print(456)
    }
    
    @objc func handleFast() {
        print(789)
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
    
    fileprivate func setScrollSpeed() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                guard let speed = value["scrollSpeed"] else {return}
                self.scrollSpeed = CGFloat(speed as! Int)
                print(self.scrollSpeed)
            }
        }, withCancel: nil)
    }
    
    fileprivate func observeStateChange() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        ref.child("users").child(uid).observe(.childChanged, with: { (snapshot) in
            let valueChange = snapshot.value as! Int
            var isScrolling: Bool = false
            if valueChange == 0 {
                isScrolling = false
            } else if valueChange == 1 {
                isScrolling = true
            }
            
            if isScrolling != self.scrollViewIsScrolling {
                self.scrollViewIsScrolling = isScrolling
            }
            
        }, withCancel: nil)
    }
}
