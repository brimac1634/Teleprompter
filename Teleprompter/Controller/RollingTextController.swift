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
    var textColor: UIColor = UIColor.white
    var textSize: CGFloat = 80
    var lineSpacing: CGFloat = 40
    var scrollSpeed: CGFloat = 30
    var scrollPoint: CGFloat = 0
    var scrollTimer: Timer?
    
    var style: NSMutableParagraphStyle!
    
    var controlBarTop: NSLayoutConstraint!
    var controlBarBottom: NSLayoutConstraint!
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.isEditable = false
        view.isSelectable = false
        view.textAlignment = .center
        view.contentMode = .center
        view.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
    
    override func viewWillAppear(_ animated: Bool) {
        textView.contentOffset = CGPoint(x: 0, y: -(view.frame.height / 2))
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
            controlBar.heightAnchor.constraint(equalToConstant: 300)
            ])
        
        updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: textColor)
        
    }
    
    private func setupGestures() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleControlToggle)))
        controlBar.backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        controlBar.startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStart)))
        controlBar.fontSizeSlider.addTarget(self, action: #selector(handleFontSize(sender:)), for: .allEvents)
        controlBar.lineSpacingSlider.addTarget(self, action: #selector(handleLineSpacing(sender:)), for: .allEvents)
        controlBar.scrollSpeedSlider.addTarget(self, action: #selector(handleScrollSpeed(sender:)), for: .allEvents)
    }
    
    //MARK: - Gesture Selectors
    
    @objc func handleControlToggle() {
        if let timer = scrollTimer {
            timer.invalidate()
        }
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
        scrollTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1 / scrollSpeed), target: self, selector: #selector(fireScroll), userInfo: nil, repeats: true)
        
    }
    
    @objc func fireScroll() {
        textView.contentOffset.y += 1
        if textView.contentOffset.y > textView.contentSize.height - (view.frame.height / 2) {
            guard scrollTimer != nil else {return}
            scrollTimer?.invalidate()
        }

    }
    
    @objc func handleFontSize(sender: UISlider!) {
        textSize = CGFloat(sender.value)
        updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: textColor)
    }
    
    @objc func handleLineSpacing(sender: UISlider!) {
        lineSpacing = CGFloat(sender.value)
        updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: textColor)
    }
    
    @objc func handleScrollSpeed(sender: UISlider!) {
        scrollSpeed = CGFloat(sender.value)
        controlBar.scrollSpeedLabel.text = "Scroll Speed: \(Int(scrollSpeed))"
    }
    
    //MARK: - Text Manipulator
    
    func updateTextStyle(lineSpacing: CGFloat, fontSize: CGFloat, color: UIColor) {
        let attributedString = NSMutableAttributedString(string: textInput)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineSpacing = lineSpacing

        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: mutableParagraphStyle, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], range: NSMakeRange(0, textInput.count))
        
        textView.attributedText = attributedString

        controlBar.lineSpacingLabel.text = "Line Height: \(Int(lineSpacing))"
        controlBar.fontSizeLabel.text = "Font Size: \(Int(textSize))"
        
        
    }

}
