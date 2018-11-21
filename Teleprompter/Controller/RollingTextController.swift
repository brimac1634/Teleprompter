//
//  RollingTextController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class RollingTextController: UIViewController {

    var textInput: String = ""
    var textSize: CGFloat = 80
    
    var controlBarTop: NSLayoutConstraint!
    var controlBarBottom: NSLayoutConstraint!
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.isEditable = false
        view.isSelectable = false
        view.textColor = .white
        view.textAlignment = .center
        view.contentMode = .center
        view.font = UIFont.systemFont(ofSize: 80)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let controlBar: ControlBar = {
        let bar = ControlBar()
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGestures()
    }
    
    private func setupView() {
        view.addSubview(textView)
        view.addSubview(controlBar)
        
        controlBarTop = controlBar.topAnchor.constraint(equalTo: view.topAnchor)
        controlBarBottom = controlBar.bottomAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            controlBarTop,
            controlBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            controlBar.heightAnchor.constraint(equalToConstant: 90)
            ])
        
        textView.font = UIFont.systemFont(ofSize: textSize)
        textView.text = textInput
        textView.centerVertically()
    }
    
    private func setupGestures() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleControlToggle)))
        controlBar.backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        controlBar.startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStart)))
    }
    
    //MARK: - Gesture Selectors
    
    @objc func handleControlToggle() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.controlBarBottom.isActive = !self.controlBarBottom.isActive
            self.controlBarTop.isActive = !self.controlBarTop.isActive
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleBack() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleStart() {
        handleControlToggle()
        let range = NSMakeRange(textView.text.count - 1, 0)
        textView.scrollRangeToVisible(range)
    }

}
