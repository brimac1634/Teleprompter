//
//  ControlBar.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class ControlBar: BaseView {
    
    var universalFontSize: CGFloat = 20
    var groupedStack: UIStackView!
    
    let backButton: BaseButton = {
        let button = BaseButton()
        button.setImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        button.contentMode = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let picker: UIPickerView = {
        let picker = UIPickerView()
        picker.showsSelectionIndicator = true
        picker.tintColor = UIColor.netRoadshowBlue(a: 1)
        return picker
    }()
    
    let saveButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Save Default", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(UIColor.netRoadshowDarkGray(a: 1), for: .normal)
        return button
    }()
    
    let defaultButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Use Default", for: .normal)
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(UIColor.netRoadshowDarkGray(a: 1), for: .normal)
        return button
    }()
    
    let fontSizeLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Font Size: 80"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let fontSizeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 80
        slider.minimumValue = 18
        slider.maximumValue = 200
        slider.tintColor = UIColor.netRoadshowBlue(a: 1)
        return slider
    }()
    
    let lineSpacingLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Line Spacing: 40"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let lineSpacingSlider: UISlider = {
        let slider = UISlider()
        slider.value = 80
        slider.minimumValue = 0
        slider.maximumValue = 200
        slider.tintColor = UIColor.netRoadshowBlue(a: 1)
        return slider
    }()
    
    let scrollSpeedLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Scroll Speed: 30"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let scrollSpeedSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor.netRoadshowBlue(a: 1)
        slider.minimumValue = 5
        slider.maximumValue = 100
        return slider
    }()
    
    let mirrorModeLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Mirror Mode"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let mirrorModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.contentVerticalAlignment = .center
        toggle.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        toggle.onTintColor = UIColor.netRoadshowBlue(a: 1)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    let arrowModeLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Arrow Mode"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let arrowModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.contentVerticalAlignment = .center
        toggle.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        toggle.onTintColor = UIColor.netRoadshowBlue(a: 1)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    let highlightModeLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Fade Mode"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let highlightModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.contentVerticalAlignment = .center
        toggle.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        toggle.onTintColor = UIColor.netRoadshowBlue(a: 1)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    let backgroundColorLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Background Color"
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let backgroundColorButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.netRoadshowDarkGray(a: 1).cgColor
        return button
    }()
    
    let textColorLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Text Color"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let textColorButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.netRoadshowDarkGray(a: 1).cgColor
        return button
    }()
    
    
    let restartButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Restart", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(UIColor.netRoadshowDarkGray(a: 1), for: .normal)
        button.titleLabel?.textAlignment = .left
        button.contentMode = .left
        return button
    }()
    
    let markerInput: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.backgroundColor = UIColor.netRoadshowGray(a: 1)
        field.textColor = UIColor.netRoadshowDarkGray(a: 1)
        field.placeholder = "Skip to..."
        field.contentMode = .center
        field.textAlignment = .center
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let startButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.netRoadshowBlue(a: 1), for: .normal)
        button.titleLabel?.textAlignment = .right
        button.contentMode = .right
        return button
    }()
    
    override func setupView() {
       super.setupView()
        
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            markerInput.font = UIFont.systemFont(ofSize: 20)
        } else {
            markerInput.font = UIFont.systemFont(ofSize: 18)
        }
        
        
        markerInput.inputView = picker
        
        let switches = [[mirrorModeLabel, mirrorModeSwitch], [arrowModeLabel, arrowModeSwitch], [highlightModeLabel, highlightModeSwitch]]
        var switchViews: [UIView] = []
        for i in 0..<switches.count {
            let containerView = UIView()
            let label = switches[i][0]
            let switchView = switches[i][1]
            containerView.addSubview(label)
            containerView.addSubview(switchView)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                label.heightAnchor.constraint(equalTo: containerView.heightAnchor),
                label.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.55),
                label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                switchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                switchView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7),
                switchView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.35),
                switchView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])
            switchViews.append(containerView)
        }
        
        backgroundColor = UIColor.netRoadshowGray(a: 1)
        
        let verticalStack1 = UIStackView(arrangedSubviews: [fontSizeLabel, fontSizeSlider, lineSpacingLabel, lineSpacingSlider, scrollSpeedLabel, scrollSpeedSlider])
        verticalStack1.axis = .vertical
        verticalStack1.spacing = 8
        verticalStack1.distribution = .fillEqually
        verticalStack1.contentMode = .center
        
        
        let verticalStack2 = UIStackView(arrangedSubviews: [switchViews[0], switchViews[1], switchViews[2]])
        verticalStack2.axis = .vertical
        verticalStack2.spacing = 8
        verticalStack2.distribution = .fillEqually
        verticalStack2.contentMode = .center
        
        let verticalStack3 = UIStackView(arrangedSubviews: [backgroundColorLabel, backgroundColorButton, textColorLabel, textColorButton])
        verticalStack3.axis = .vertical
        verticalStack3.spacing = 8
        verticalStack3.distribution = .fillEqually
        verticalStack3.contentMode = .center
        
        
        groupedStack = UIStackView(arrangedSubviews: [verticalStack1, verticalStack2, verticalStack3])
        groupedStack.axis = .vertical
        groupedStack.distribution = .fillProportionally
        groupedStack.spacing = 16
        groupedStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backButton)
        addSubview(groupedStack)
        addSubview(defaultButton)
        addSubview(saveButton)
        addSubview(restartButton)
        addSubview(markerInput)
        addSubview(startButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            backButton.heightAnchor.constraint(equalToConstant: 28),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            
            saveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            saveButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            
            defaultButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            defaultButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            defaultButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            defaultButton.heightAnchor.constraint(equalTo: saveButton.heightAnchor),
            
            markerInput.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            markerInput.centerXAnchor.constraint(equalTo: centerXAnchor),
            markerInput.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45),
            markerInput.heightAnchor.constraint(equalTo: saveButton.heightAnchor),
            
            restartButton.centerYAnchor.constraint(equalTo: markerInput.centerYAnchor),
            restartButton.heightAnchor.constraint(equalTo: markerInput.heightAnchor),
            restartButton.leadingAnchor.constraint(equalTo: backButton.leadingAnchor),
            restartButton.trailingAnchor.constraint(equalTo: markerInput.leadingAnchor, constant: -8),
            
            startButton.centerYAnchor.constraint(equalTo: markerInput.centerYAnchor),
            startButton.heightAnchor.constraint(equalTo: markerInput.heightAnchor),
            startButton.leadingAnchor.constraint(equalTo: markerInput.trailingAnchor, constant: 8),
            startButton.trailingAnchor.constraint(equalTo: defaultButton.trailingAnchor),

            groupedStack.topAnchor.constraint(equalTo: defaultButton.bottomAnchor, constant: 32),
            groupedStack.leadingAnchor.constraint(equalTo: backButton.leadingAnchor),
            groupedStack.trailingAnchor.constraint(equalTo: defaultButton.trailingAnchor),
            groupedStack.bottomAnchor.constraint(equalTo: markerInput.topAnchor, constant: -32),
            ])
        
        fontSizeSlider.value = 80
        lineSpacingSlider.value = 40
        scrollSpeedSlider.value = 30
        mirrorModeSwitch.isOn = false
        arrowModeSwitch.isOn = false
        highlightModeSwitch.isOn = false
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleResignMark)))

    }
    

    //MARK: - Selector
    
    @objc func handleResignMark() {
        markerInput.resignFirstResponder()
    }
    
    
}
