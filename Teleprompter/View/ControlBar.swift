//
//  ControlBar.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class ControlBar: BaseView {
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.netRoadshowBlue(a: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        label.text = "Highlight Mode"
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
            newStack.distribution = .fillProportionally
            newStack.contentMode = .center
            newStack.alignment = .center
            stacks.append(newStack)
        }
        
        backgroundColor = UIColor.netRoadshowGray(a: 1)
        
        let verticalStack1 = UIStackView(arrangedSubviews: [fontSizeLabel, fontSizeSlider, lineSpacingLabel, lineSpacingSlider, scrollSpeedLabel, scrollSpeedSlider])
        verticalStack1.axis = .vertical
        verticalStack1.distribution = .fillEqually
        verticalStack1.contentMode = .center
        
        
        let verticalStack2 = UIStackView(arrangedSubviews: [stacks[0], stacks[1], stacks[2]])
        verticalStack2.axis = .vertical
        verticalStack2.distribution = .fillEqually
        verticalStack2.contentMode = .center
        
        let verticalStack3 = UIStackView(arrangedSubviews: [backgroundColorLabel, backgroundColorButton, textColorLabel, textColorButton])
        verticalStack3.axis = .vertical
        verticalStack3.distribution = .fillEqually
        verticalStack3.contentMode = .center
        
        let groupedStack = UIStackView(arrangedSubviews: [verticalStack1, verticalStack2, verticalStack3])
        groupedStack.axis = .horizontal
        groupedStack.distribution = .fillProportionally
        groupedStack.spacing = 32
        groupedStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(backButton)
        addSubview(groupedStack)
        addSubview(startButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            backButton.heightAnchor.constraint(equalToConstant: 28),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            groupedStack.topAnchor.constraint(equalTo: backButton.topAnchor),
            groupedStack.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 32),
            groupedStack.trailingAnchor.constraint(equalTo: startButton.leadingAnchor, constant: -32),
            groupedStack.bottomAnchor.constraint(equalTo: startButton.bottomAnchor),
            ])
        
        fontSizeSlider.value = 80
        lineSpacingSlider.value = 40
        scrollSpeedSlider.value = 30
        mirrorModeSwitch.isOn = false
        arrowModeSwitch.isOn = true
        highlightModeSwitch.isOn = true
        
        

    }
    

    
    
}
