//
//  RollingTextController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import ChromaColorPicker


class RollingTextController: UIViewController, ChromaColorPickerDelegate {
    

    var textInput: String = ""
    var textColor: UIColor = UIColor.white
    var backgroundColor: UIColor = UIColor.black
    var textSize: CGFloat = 80
    var lineSpacing: CGFloat = 40
    var scrollSpeed: CGFloat = 30
    var scrollPoint: CGFloat = 0
    var scrollTimer: Timer?
    var backgroundColorChosen: Bool = true
    
    var centeredText: UITextRange!
    
    var style: NSMutableParagraphStyle!
    var neatColorPicker: ChromaColorPicker!
    var gradient: CAGradientLayer!
    
    var controlBarTop: NSLayoutConstraint!
    var controlBarBottom: NSLayoutConstraint!
    var arrowLeading: NSLayoutConstraint!
    var arrowTrailing: NSLayoutConstraint!
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.isEditable = false
        view.isSelectable = false
        view.textAlignment = .center
        view.contentMode = .center
        view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let controlBar: ControlBar = {
        let bar = ControlBar()
        return bar
    }()
    
    let arrow: UIImageView = {
        let arrow = UIImageView(image: UIImage(named: "right_arrow")?.withRenderingMode(.alwaysTemplate))
        arrow.tintColor = UIColor.white
        arrow.contentMode = .scaleAspectFit
        arrow.translatesAutoresizingMaskIntoConstraints = false
        return arrow
    }()
    
    let shadeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        view.addSubview(arrow)
        view.addSubview(gradientView)
        view.addSubview(controlBar)
        view.addSubview(shadeView)
        
        controlBarTop = controlBar.topAnchor.constraint(equalTo: view.topAnchor)
        controlBarBottom = controlBar.bottomAnchor.constraint(equalTo: view.topAnchor)
        
        arrowLeading = arrow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        arrowTrailing = arrow.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            arrowTrailing,
            arrow.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 100),
            arrow.heightAnchor.constraint(equalToConstant: 100),
            
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: arrow.trailingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            controlBarTop,
            controlBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            controlBar.heightAnchor.constraint(equalToConstant: 300),

            shadeView.topAnchor.constraint(equalTo: view.topAnchor),
            shadeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shadeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shadeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
            ])
        view.bringSubviewToFront(shadeView)
        shadeView.alpha = 0
        updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: textColor)
        
        gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(1).cgColor, UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
        gradient.locations = [0,0.4,0.6,1]
        gradientView.layer.addSublayer(gradient)
        gradientView.alpha = 0
        
    }
    
    private func setupGestures() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleControlToggle)))
        shadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShadeViewTap)))
        controlBar.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        controlBar.backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        controlBar.startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStart)))
        controlBar.fontSizeSlider.addTarget(self, action: #selector(handleFontSize(sender:)), for: .allEvents)
        controlBar.lineSpacingSlider.addTarget(self, action: #selector(handleLineSpacing(sender:)), for: .allEvents)
        controlBar.scrollSpeedSlider.addTarget(self, action: #selector(handleScrollSpeed(sender:)), for: .allEvents)
        controlBar.mirrorModeSwitch.addTarget(self, action: #selector(handleMirrorMode(sender:)), for: .allEvents)
        controlBar.arrowModeSwitch.addTarget(self, action: #selector(handleArrowMode(sender:)), for: .allEvents)
        controlBar.highlightModeSwitch.addTarget(self, action: #selector(handleFadeMode(sender:)), for: .allEvents)
        controlBar.backgroundColorButton.addTarget(self, action: #selector(handleBackgroundColor), for: .touchUpInside)
        controlBar.textColorButton.addTarget(self, action: #selector(handleTextColor), for: .touchUpInside)
    }
    
    //MARK: - Gesture Selectors
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let changeInY = gesture.translation(in: controlBar).y
        let velocityY = gesture.velocity(in: controlBar).y
        
        if changeInY < 0 {
            controlBarTop.constant = changeInY
            
            if gesture.state == .ended {
                if changeInY < controlBar.frame.height * 0.6 || velocityY > 800 {
                    handleControlToggle()
                } else {
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                        self.controlBarTop.constant = 0
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
            }
        }
    }
    
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
    
    @objc func handleMirrorMode(sender: UISwitch!) {
        
        textView.transform = sender.isOn ? CGAffineTransform.init(scaleX: -1, y: 1) : CGAffineTransform.init(scaleX: 1, y: 1)
//        arrow.transform = sender.isOn ? CGAffineTransform.init(scaleX: -1, y: 1) : CGAffineTransform.init(scaleX: 1, y: 1)
    }
    
    @objc func handleArrowMode(sender: UISwitch!) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.arrowLeading.isActive = !self.arrowLeading.isActive
            self.arrowTrailing.isActive = !self.arrowTrailing.isActive
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func handleFadeMode(sender: UISwitch!) {
        gradientView.alpha =  sender.isOn ? 1 : 0
        
    }
    
    @objc func handleBackgroundColor() {
        backgroundColorChosen = true
        displayColorPicker()
    }
    
    @objc func handleTextColor() {
        backgroundColorChosen = false
        displayColorPicker()
    }
    
    @objc func handleShadeViewTap() {
        dismissColorPicker()
    }
    
    //MARK: - Text Manipulator
    
    func updateTextStyle(lineSpacing: CGFloat, fontSize: CGFloat, color: UIColor) {
        let attributedString = NSMutableAttributedString(string: textInput)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineSpacing = lineSpacing
        mutableParagraphStyle.alignment = .center

        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: mutableParagraphStyle, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], range: NSMakeRange(0, textInput.count))
        
        textView.attributedText = attributedString

        controlBar.lineSpacingLabel.text = "Line Height: \(Int(lineSpacing))"
        controlBar.fontSizeLabel.text = "Font Size: \(Int(textSize))"
        
        
    }
    
    //MARK: - Color Picker Delegate
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        if backgroundColorChosen {
            view.backgroundColor = color
            controlBar.backgroundColorButton.backgroundColor = color
            if color.isLight {
                gradient.colors = [UIColor.white.withAlphaComponent(1).cgColor, UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(1).cgColor]
            } else {
                gradient.colors = [UIColor.black.withAlphaComponent(1).cgColor, UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
            }
        } else {
            updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: color)
            controlBar.textColorButton.backgroundColor = color
            arrow.tintColor = color
        }
        
        dismissColorPicker()
    }
    
    func dismissColorPicker() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 0
            self.neatColorPicker.alpha = 0
            self.neatColorPicker.frame.origin.y = self.neatColorPicker.frame.origin.y - 50
        }, completion: nil)
        
        neatColorPicker.removeFromSuperview()
    }

    func displayColorPicker() {
        let width: CGFloat = 480
        let x = (view.frame.width / 2) - CGFloat(width / 2)
        let y = (view.frame.height / 2) - CGFloat(width / 2)
        neatColorPicker = ChromaColorPicker(frame: CGRect(x: x, y: y, width: width, height: width))
        neatColorPicker.delegate = self
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.hexLabel.textColor = UIColor.white
        neatColorPicker.alpha = 0
        neatColorPicker.frame.origin.y = neatColorPicker.frame.origin.y + 50
        view.addSubview(neatColorPicker)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 1
            self.neatColorPicker.alpha = 1
            self.neatColorPicker.frame.origin.y = self.neatColorPicker.frame.origin.y - 50
        }, completion: nil)
    }
}
