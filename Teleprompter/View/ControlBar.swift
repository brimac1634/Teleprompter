//
//  ControlBar.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class ControlBar: BaseView {
    
    var universalFontSize: CGFloat = 24
    var groupedStack: UIStackView!
    
    let backButton: BaseButton = {
        let button = BaseButton()
        button.setTitle("Edit Text", for: .normal)
        button.setImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitleColor(UIColor.netRoadshowDarkGray(a: 1), for: .normal)
        button.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    let controlsView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .clear
        return view
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
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let mirrorModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        toggle.onTintColor = UIColor.netRoadshowBlue(a: 1)
        return toggle
    }()
    
    let arrowModeLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Arrow Mode"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let arrowModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        toggle.onTintColor = UIColor.netRoadshowBlue(a: 1)
        return toggle
    }()
    
    let highlightModeLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Fade Mode"
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    let highlightModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        toggle.onTintColor = UIColor.netRoadshowBlue(a: 1)
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
    
    
    let topButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Restart", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(UIColor.netRoadshowDarkGray(a: 1), for: .normal)
        return button
    }()
    
    let defaultButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Use Default", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(UIColor.netRoadshowDarkGray(a: 1), for: .normal)
        return button
    }()
    
    let startButton: BaseButton = {
        let button = BaseButton()
        button.backgroundColor = .clear
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.netRoadshowBlue(a: 1), for: .normal)
        return button
    }()
    
    override func setupView() {
       super.setupView()
        
        let switches = [[mirrorModeLabel, mirrorModeSwitch], [arrowModeLabel, arrowModeSwitch], [highlightModeLabel, highlightModeSwitch]]
        var stacks: [UIStackView] = []
        for i in 0..<switches.count {
            let newStack = UIStackView(arrangedSubviews: [switches[i][0], switches[i][1]])
            newStack.axis = .horizontal
            newStack.distribution = .fillEqually
            newStack.spacing = 8
            newStack.contentMode = .center
            newStack.alignment = .center
            stacks.append(newStack)
        }
        
        backgroundColor = UIColor.netRoadshowGray(a: 1)
        
        let verticalStack1 = UIStackView(arrangedSubviews: [fontSizeLabel, fontSizeSlider, lineSpacingLabel, lineSpacingSlider, scrollSpeedLabel, scrollSpeedSlider])
        verticalStack1.axis = .vertical
        verticalStack1.spacing = 8
        verticalStack1.distribution = .fillEqually
        verticalStack1.contentMode = .center
        
        
        let verticalStack2 = UIStackView(arrangedSubviews: [stacks[0], stacks[1], stacks[2]])
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
        
        let bottomStack = UIStackView(arrangedSubviews: [saveButton, defaultButton, startButton])
        bottomStack.axis = .horizontal
        bottomStack.distribution = .fillEqually
        bottomStack.contentMode = .center
        bottomStack.spacing = 8
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(backButton)
        addSubview(groupedStack)
        addSubview(topButton)
        addSubview(bottomStack)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalToConstant: 140),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            
            bottomStack.leadingAnchor.constraint(equalTo: backButton.leadingAnchor),
            bottomStack.heightAnchor.constraint(equalToConstant: 60),
            bottomStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            topButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            topButton.trailingAnchor.constraint(equalTo: bottomStack.trailingAnchor),
            topButton.widthAnchor.constraint(equalToConstant: 80),
            topButton.heightAnchor.constraint(equalToConstant: 40),
            
            groupedStack.topAnchor.constraint(equalTo: topButton.bottomAnchor, constant: 32),
            groupedStack.leadingAnchor.constraint(equalTo: backButton.leadingAnchor),
            groupedStack.trailingAnchor.constraint(equalTo: bottomStack.trailingAnchor),
            groupedStack.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -32)
            ])
        
        fontSizeSlider.value = 80
        lineSpacingSlider.value = 40
        scrollSpeedSlider.value = 30
        mirrorModeSwitch.isOn = false
        arrowModeSwitch.isOn = false
        highlightModeSwitch.isOn = false
        
        

    }
    

    
    
}
