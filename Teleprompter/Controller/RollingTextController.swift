//
//  RollingTextController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import ChromaColorPicker
import Firebase
import FirebaseDatabase


class RollingTextController: UIViewController, ChromaColorPickerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    
    var ref: DatabaseReference!
    
    let defaults = UserDefaults.standard
    var usingIpad: Bool = true

    var textInput: String = ""
    var textColor: UIColor = UIColor.white
    var backgroundColor: UIColor = UIColor.black
    var textSize: CGFloat = 80
    var lineSpacing: CGFloat = 40
    var scrollSpeed: CGFloat = 30
    var mirrorIsOn: Bool = false
    var arrowIsOn: Bool = false
    var fadeIsOn: Bool = false
    var scrollTimer: Timer?
    var backgroundColorChosen: Bool = true
    var controlPanelMultiplier: CGFloat = 300
    var lastScale: CGFloat = 0
    var markerArray: [String] = []
    var scrollViewIsScrolling: Bool = false
    
    var style: NSMutableParagraphStyle!
    var neatColorPicker: ChromaColorPicker!
    
    var controlBarLeading: NSLayoutConstraint!
    var controlBarTrailing: NSLayoutConstraint!
    var settingsButtonLeading: NSLayoutConstraint!
    var settingsButtonTrailing: NSLayoutConstraint!
    var arrowContainerLeading: NSLayoutConstraint!
    var arrowContainerTrailing: NSLayoutConstraint!
    var arrowContainerCenterY: NSLayoutConstraint!
    
    var scrollSpeedDoubleTapGesture: UITapGestureRecognizer!
    var arrowPanGesture: UIPanGestureRecognizer!
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.isEditable = false
        view.isSelectable = false
        view.textAlignment = .center
        view.contentMode = .center
        view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let settingsButton: UIImageView = {
        let button = UIImageView(image: UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate))
        button.tintColor = UIColor.white
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    let arrowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let shadeView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
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
    
    let gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.black.withAlphaComponent(1).cgColor, UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
        layer.locations = [0,0.2,0.4,1]
        return layer
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controlBar.picker.dataSource = self
        controlBar.picker.delegate = self
        
        if ( UIDevice.current.model.range(of: "iPad") != nil){
            usingIpad = true
        } else {
            usingIpad = false
        }
        
        setupView()
        setupGestures()
        configureDatabase()
        scrollViewIsScrolling = true
        updateStateOfScroll()
        updateMarkerList()
        observeStateChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults.bool(forKey: "fadeIsOn") {
            loadDefaults()
        } else {
            print("no defaults found")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if defaults.bool(forKey: "isFirstTime") == true {
            toggleControlPanel()
        } else {
            let guide = FirstTimeGuide()
            view.addSubview(guide)
            NSLayoutConstraint.activate([
                guide.topAnchor.constraint(equalTo: view.topAnchor),
                guide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                guide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                guide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ])
            guide.rollingController = self
            guide.presentGuide()
            
            defaults.set(true, forKey: "isFirstTime")
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        gradient.frame = gradientView.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustControlPanelForIphone()
    }

    
    private func setupView() {
        
        controlPanelMultiplier = usingIpad ? 0.5 : 1
        let arrowSize: CGFloat = usingIpad ? 100 : 40
        let settingSize: CGFloat = usingIpad ? 60 : 40
        adjustControlPanelOnLaunch()
        
        view.addSubview(textView)
        view.addSubview(gradientView)
        view.addSubview(arrowContainer)
        arrowContainer.addSubview(arrow)
        view.addSubview(settingsButton)
        view.addSubview(controlBar)
        view.addSubview(shadeView)
        gradientView.layer.addSublayer(gradient)
        
        controlBarLeading = controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        controlBarTrailing = controlBar.trailingAnchor.constraint(equalTo: view.leadingAnchor)
        
        settingsButtonLeading = settingsButton.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16)
        if #available(iOS 11.0, *) {
            settingsButtonTrailing = settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            arrowContainerLeading = arrow.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8)
        } else {
            // Fallback on earlier versions
            settingsButtonTrailing = settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            arrowContainerLeading = arrow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        }
        
        
        arrowContainerTrailing = arrow.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -8)
        arrowContainerCenterY = arrowContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                
                textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: arrowSize),
                textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16 - settingSize),
                textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
                ])
        } else {
            NSLayoutConstraint.activate([
                settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
                
                textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: arrowSize),
                textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16 - settingSize),
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
                ])
        }
        
        NSLayoutConstraint.activate([
            settingsButton.widthAnchor.constraint(equalToConstant: settingSize),
            settingsButton.heightAnchor.constraint(equalToConstant: settingSize),
            settingsButtonTrailing,
            
            
            arrowContainerCenterY,
            arrowContainer.widthAnchor.constraint(equalToConstant: arrowSize),
            arrowContainer.heightAnchor.constraint(equalTo: view.heightAnchor),
            arrowContainerTrailing,
            
            arrow.topAnchor.constraint(equalTo: arrowContainer.topAnchor, constant: view.frame.height / 4),
            arrow.leadingAnchor.constraint(equalTo: arrowContainer.leadingAnchor),
            arrow.widthAnchor.constraint(equalToConstant: arrowSize),
            arrow.heightAnchor.constraint(equalToConstant: arrowSize),
            
            
            
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            controlBar.heightAnchor.constraint(equalTo: view.heightAnchor),
            controlBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: controlPanelMultiplier),
            controlBar.topAnchor.constraint(equalTo: view.topAnchor),
            controlBarTrailing,

            shadeView.topAnchor.constraint(equalTo: view.topAnchor),
            shadeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shadeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shadeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
            ])
        
        arrow.alpha = 1
        view.bringSubviewToFront(shadeView)
        shadeView.alpha = 0
        
        updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: textColor)
        updateViewStyle(scroll: scrollSpeed, mirror: mirrorIsOn, arrow: arrowIsOn, fade: fadeIsOn, backColor: backgroundColor)
        
        gradient.frame = gradientView.bounds
        gradientView.alpha = 0
    }
    
    private func setupGestures() {
        let pauseStartGesture = UITapGestureRecognizer(target: self, action: #selector(handlePauseStart))
        textView.addGestureRecognizer(pauseStartGesture)
    
        textView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinchZoom)))
        
        scrollSpeedDoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScrollTap))
        scrollSpeedDoubleTapGesture.delegate = self
        scrollSpeedDoubleTapGesture.numberOfTouchesRequired = 2
        
        let settingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSettings))
        settingsTapGesture.delegate = self
        settingsTapGesture.numberOfTouchesRequired = 1
        settingsTapGesture.require(toFail: scrollSpeedDoubleTapGesture)
        
        arrowPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleArrowPan))
        view.addGestureRecognizer(scrollSpeedDoubleTapGesture)
        view.addGestureRecognizer(settingsTapGesture)
        view.addGestureRecognizer(arrowPanGesture)
        
        let shadeViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleShadeViewTap))
        shadeView.addGestureRecognizer(shadeViewGesture)
        controlBar.backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        
        controlBar.saveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSave)))
        controlBar.startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStart)))
        controlBar.defaultButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDefault)))
        controlBar.fontSizeSlider.addTarget(self, action: #selector(handleFontSize(sender:)), for: .allEvents)
        controlBar.lineSpacingSlider.addTarget(self, action: #selector(handleLineSpacing(sender:)), for: .allEvents)
        controlBar.scrollSpeedSlider.addTarget(self, action: #selector(handleScrollSpeed(sender:)), for: .allEvents)
        controlBar.mirrorModeSwitch.addTarget(self, action: #selector(handleMirrorMode(sender:)), for: .allEvents)
        controlBar.arrowModeSwitch.addTarget(self, action: #selector(handleArrowMode(sender:)), for: .allEvents)
        controlBar.highlightModeSwitch.addTarget(self, action: #selector(handleFadeMode(sender:)), for: .allEvents)
        controlBar.backgroundColorButton.addTarget(self, action: #selector(handleBackgroundColor), for: .touchUpInside)
        controlBar.textColorButton.addTarget(self, action: #selector(handleTextColor), for: .touchUpInside)
        controlBar.restartButton.addTarget(self, action: #selector(handleRestart), for: .touchUpInside)
    }
    
    //MARK: - Gesture Selectors
    
    @objc func handlePauseStart() {
        updateStateOfScroll()
        pauseStartScroll()
        
        
    }
    
    fileprivate func pauseStartScroll() {
        controlBar.markerInput.resignFirstResponder()
        guard let scrollTap = scrollSpeedDoubleTapGesture else {return}
        if let timer = scrollTimer {
            if timer.isValid {
                timer.invalidate()
                scrollTap.isEnabled = false
            } else {
                startScroll()
                scrollTap.isEnabled = true
            }
        } else {
            startScroll()
            scrollTap.isEnabled = true
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.settingsButtonTrailing.isActive = !self.settingsButtonTrailing.isActive
            self.settingsButtonLeading.isActive = !self.settingsButtonLeading.isActive
            self.controlBarTrailing.isActive = true
            self.controlBarLeading.isActive = false
            self.controlBarLeading.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func startScroll() {
        scrollTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1 / scrollSpeed), target: self, selector: #selector(fireScroll), userInfo: nil, repeats: true)
    }
    
    func toggleControlPanel() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.controlBarTrailing.isActive = !self.controlBarTrailing.isActive
            self.controlBarLeading.isActive = !self.controlBarLeading.isActive
            self.controlBarLeading.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleBack() {
        arrow.alpha = 0
        navigationController?.isNavigationBarHidden = false
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSettings(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        if settingsButton.frame.contains(point) {
            toggleControlPanel()
        }
        
    }
    
    @objc func handlePinchZoom(gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        if scale > lastScale {
            textSize += scale
        } else if scale < lastScale && textSize >= 18 {
            textSize -= scale
        }
        updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: textColor)
    
        if gesture.state == .ended {
            lastScale = 0
        } else {
            lastScale = scale
        }
        
        
    }
    
    @objc func handleScrollTap(gesture: UITapGestureRecognizer) {
        guard let timer = scrollTimer else {return}
        guard timer.isValid else {return}
        let point1 = gesture.location(ofTouch: 0, in: view)
        let point2 = gesture.location(ofTouch: 1, in: view)
        let rightSide = CGRect(x: view.frame.width / 2, y: 0, width: view.frame.width / 2, height: view.frame.height)
        let leftSide = CGRect(x: 0, y: 0, width: view.frame.width / 2, height: view.frame.height)
        
        if leftSide.contains(point1) && leftSide.contains(point2) && scrollSpeed > 5 {
            scrollSpeed = scrollSpeed - 5
        } else if rightSide.contains(point1) && rightSide.contains(point2) && scrollSpeed <= 95 {
            scrollSpeed = scrollSpeed + 5
        }
        
        updateTimerWithNewSpeed()
        updateScrollSpeed()

        controlBar.scrollSpeedLabel.text = "Scroll Speed: \(Int(scrollSpeed))"
        controlBar.scrollSpeedSlider.value = Float(scrollSpeed)
    }

    
    @objc func handleArrowPan(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: view)
        guard arrowContainer.frame.contains(point) && arrowContainerLeading.isActive else {return}
        let changeInY = gesture.translation(in: view).y - arrowContainerCenterY.constant
        arrowContainerCenterY.constant += changeInY
    }
    
    
    @objc func handleSave() {
        let alert = UIAlertController(title: "Save Default", message: "Are you sure you want to save these settings?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (finished) in
            self.saveDefaults()
            let alert = UIAlertController(title: "Saved", message: "Your default settings have been saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.preferredAction = alert.actions[0]
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @objc func handleDefault() {
        if defaults.bool(forKey: "fadeIsOn") {
            loadDefaults()
        } else {
            let alert = UIAlertController(title: "No Defaults", message: "There are no default settings saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func handleStart() {
        handlePauseStart()
    }
    
    @objc func fireScroll() {
        textView.contentOffset.y += 1
        if textView.contentOffset.y > textView.contentSize.height - (view.frame.height / 3) {
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
        updateScrollSpeed()
        controlBar.scrollSpeedLabel.text = "Scroll Speed: \(Int(scrollSpeed))"
    }
    
    @objc func handleMirrorMode(sender: UISwitch!) {
        mirrorIsOn = sender.isOn
        textView.transform = sender.isOn ? CGAffineTransform.init(scaleX: 1, y: -1) : CGAffineTransform.init(scaleX: 1, y: 1)
        gradientView.transform = sender.isOn ? CGAffineTransform.init(scaleX: 1, y: -1) : CGAffineTransform.init(scaleX: 1, y: 1)
    }
    
    @objc func handleArrowMode(sender: UISwitch!) {
        arrowIsOn = sender.isOn
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.arrowContainerLeading.isActive = sender.isOn ? true : false
            self.arrowContainerTrailing.isActive = sender.isOn ? false : true
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func handleFadeMode(sender: UISwitch!) {
        fadeIsOn = sender.isOn
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
    
    @objc func handleRestart() {
        scrollToTop()
        handlePauseStart()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - Save Method
    
    func saveDefaults() {
        defaults.set(textSize, forKey: "textSize")
        defaults.set(lineSpacing, forKey: "lineSpacing")
        defaults.set(scrollSpeed, forKey: "scrollSpeed")
        defaults.set(mirrorIsOn, forKey: "mirrorIsOn")
        defaults.set(arrowIsOn, forKey: "arrowIsOn")
        defaults.set(fadeIsOn, forKey: "fadeIsOn")
        defaults.setColor(color: backgroundColor, forKey: "backgroundColor")
        defaults.setColor(color: textColor, forKey: "textColor")
    }

    
    //MARK: - View Updaters
    
    fileprivate func updateTimerWithNewSpeed() {
        guard let timer = scrollTimer else {return}
        guard timer.isValid else {return}
        let newTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1 / scrollSpeed), target: self, selector: #selector(fireScroll), userInfo: nil, repeats: true)
        timer.invalidate()
        scrollTimer = newTimer
    }
    
    func scrollToTop() {
        textView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    fileprivate func updateTextWithMarkers(text: String, scriptColor: UIColor) -> NSMutableAttributedString {
        let marker = "##"
        var initialText = "\n\n\n\n"
        initialText.append(contentsOf: text)
        initialText.append("\n\n\n\n\n\n\n\n\n\n\n")
        let separatedTextArray = initialText.components(separatedBy: marker)
        let markerColor = UIColor.darkGray
        let newText = NSMutableAttributedString()
        var markerCount: Int = 0
        for i in 0..<separatedTextArray.count {
            print(separatedTextArray[i])
            let markerSymbol = NSMutableAttributedString(string: marker, attributes: [NSAttributedString.Key.foregroundColor : markerColor])
            if i % 2 != 0 {
                let markerName = NSMutableAttributedString(string: separatedTextArray[i], attributes: [NSAttributedString.Key.foregroundColor : markerColor])
                newText.append(markerName)
                newText.append(markerSymbol)
            } else {
                let scriptText = NSMutableAttributedString(string: separatedTextArray[i], attributes: [NSAttributedString.Key.foregroundColor : scriptColor])
                newText.append(scriptText)
                newText.append(markerSymbol)
                markerCount += 1
                
                let markerNumber = NSMutableAttributedString(string: " [\(markerCount)] ", attributes: [NSAttributedString.Key.foregroundColor : markerColor])
                
                newText.append(markerNumber)
            }
            
        }
        return newText
    }
    
    fileprivate func updateTextStyle(lineSpacing: CGFloat, fontSize: CGFloat, color: UIColor) {
        let attributedString = updateTextWithMarkers(text: textInput, scriptColor: color)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineSpacing = lineSpacing
        mutableParagraphStyle.alignment = .center

        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: mutableParagraphStyle, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], range: NSMakeRange(0, attributedString.length))
        
        textView.attributedText = attributedString
        arrow.tintColor = color
        settingsButton.tintColor = color

        controlBar.fontSizeSlider.value = Float(fontSize)
        controlBar.lineSpacingSlider.value = Float(lineSpacing)
        controlBar.textColorButton.backgroundColor = color
        controlBar.lineSpacingLabel.text = "Line Height: \(Int(lineSpacing))"
        controlBar.fontSizeLabel.text = "Font Size: \(Int(fontSize))"
    }
    
    fileprivate func updateViewStyle(scroll: CGFloat, mirror: Bool, arrow: Bool, fade: Bool, backColor: UIColor) {
        gradientView.alpha =  mirror ? 1 : 0
        
        controlBar.scrollSpeedSlider.value = Float(scroll)
        controlBar.mirrorModeSwitch.setOn(mirror, animated: true)
        controlBar.arrowModeSwitch.setOn(arrow, animated: true)
        controlBar.highlightModeSwitch.setOn(fade, animated: true)
        handleFadeMode(sender: controlBar.highlightModeSwitch)
        handleArrowMode(sender: controlBar.arrowModeSwitch)
        handleMirrorMode(sender: controlBar.mirrorModeSwitch)
        controlBar.backgroundColorButton.backgroundColor = backColor
        view.backgroundColor = backColor
        
        controlBar.scrollSpeedLabel.text = "Scroll Speed: \(Int(scroll))"
        
        view.layoutIfNeeded()
    }
    
    func adjustControlPanelForIphone() {
        if let arrowContainerY = arrowContainerCenterY {
            arrowContainerY.constant = 0
        }
        guard let groupStack = controlBar.groupedStack else {return}
        guard usingIpad == false else {return}
        if UIDevice.current.orientation.isLandscape {
            groupStack.axis = .horizontal
            groupStack.distribution = .fillEqually
            
        } else {
            groupStack.axis = .vertical
        }
        view.layoutSubviews()
        controlBar.layoutSubviews()
    }
    
    func adjustControlPanelOnLaunch() {
        guard let groupStack = controlBar.groupedStack else {return}
        guard usingIpad == false else {return}
        if view.frame.width > view.frame.height {
            groupStack.axis = .horizontal
            groupStack.distribution = .fillEqually
        } else {
            groupStack.axis = .vertical
        }
    }
    
    //MARK: - Color Picker Delegate
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        if backgroundColorChosen {
            view.backgroundColor = color
            backgroundColor = color
            controlBar.backgroundColorButton.backgroundColor = color
        } else {
            textColor = color
            updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: color)
            controlBar.textColorButton.backgroundColor = color
            arrow.tintColor = color
        }
        
        dismissColorPicker()
    }
    
    func dismissColorPicker() {
        arrowPanGesture.isEnabled = true
        
        shadeView.isUserInteractionEnabled = false
        
        guard let picker = neatColorPicker else {return}
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 0
            picker.alpha = 0
            picker.frame.origin.y = self.neatColorPicker.frame.origin.y - 50
        }, completion: nil)
        
        neatColorPicker.removeFromSuperview()
    }

    func displayColorPicker() {
        arrowPanGesture.isEnabled = false
        
        var width: CGFloat = 0
        if controlPanelMultiplier >= 0.8 {
            width = 300
        } else {
            width = 480
        }
        
        let x = (view.frame.width / 2) - CGFloat(width / 2)
        let y = (view.frame.height / 2) - CGFloat(width / 2)
        neatColorPicker = ChromaColorPicker(frame: CGRect(x: x, y: y, width: width, height: width))
        neatColorPicker.delegate = self
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.hexLabel.textColor = UIColor.white
        neatColorPicker.hexLabel.alpha = 0
        neatColorPicker.alpha = 0
        neatColorPicker.frame.origin.y = neatColorPicker.frame.origin.y + 50
        view.addSubview(neatColorPicker)
        shadeView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.shadeView.alpha = 1
            self.neatColorPicker.alpha = 1
            self.neatColorPicker.frame.origin.y = self.neatColorPicker.frame.origin.y - 50
        }, completion: nil)
    }
    
    //MARK: - Load Defaults
    
    func loadDefaults() {

        lineSpacing = CGFloat(defaults.float(forKey: "lineSpacing"))
        scrollSpeed = CGFloat(defaults.float(forKey: "scrollSpeed"))
        textSize = CGFloat(defaults.float(forKey: "textSize"))
        mirrorIsOn = defaults.bool(forKey: "mirrorIsOn")
        arrowIsOn = defaults.bool(forKey: "arrowIsOn")
        fadeIsOn = defaults.bool(forKey: "fadeIsOn")
        textColor = defaults.colorForKey(key: "textColor") ?? .white
        backgroundColor = defaults.colorForKey(key: "backgroundColor") ?? .black
        
        updateTextStyle(lineSpacing: lineSpacing, fontSize: textSize, color: textColor)
        updateViewStyle(scroll: scrollSpeed, mirror: mirrorIsOn, arrow: arrowIsOn, fade: fadeIsOn, backColor: backgroundColor)
        
        updateScrollSpeed()
    }
    
    //MARK: - ScrollView Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
//            print("no contentOffset needed")
        } else {
            if scrollView.contentOffset.x != 0 {
                scrollView.contentOffset.x = 0
            }
        }
        
    }
    
    //MARK: - Firebase functions
    
    fileprivate func configureDatabase() {
        ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
    }
    
    fileprivate func updateStateOfScroll() {
        scrollViewIsScrolling = !scrollViewIsScrolling
        TeleDatabase.saveData(values: ["scrollViewIsScrolling": scrollViewIsScrolling], uidChildren: nil)
    }
    
    fileprivate func updateScrollSpeed() {
        TeleDatabase.saveData(values: ["scrollSpeed": scrollSpeed], uidChildren: nil)
        
    }
    
    fileprivate func updateMarkerList() {
        TeleDatabase.saveData(values: ["markerList": markerArray], uidChildren: nil)
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
                    self.pauseStartScroll()
                }

            } else if key == "scrollSpeed" {
                let valueChange = snapshot.value as! CGFloat
                if valueChange != self.scrollSpeed {
                    self.scrollSpeed = valueChange
                    self.updateTimerWithNewSpeed()
                }
                
            }
        }, withCancel: nil)
    }
}
