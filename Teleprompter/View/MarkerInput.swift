//
//  MarkerInput.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 17/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit

class MarkerInput: BaseView {
    
    let markerInputField: UITextField = {
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
    
    let picker: UIPickerView = {
        let picker = UIPickerView()
        picker.showsSelectionIndicator = true
        picker.tintColor = UIColor.netRoadshowBlue(a: 1)
        return picker
    }()
    
    override func setupView() {
        
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            markerInputField.font = UIFont.systemFont(ofSize: 20)
        } else {
            markerInputField.font = UIFont.systemFont(ofSize: 18)
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        markerInputField.inputView = picker
        
        addSubview(markerInputField)
        
        NSLayoutConstraint.activate([
            markerInputField.topAnchor.constraint(equalTo: topAnchor),
            markerInputField.leadingAnchor.constraint(equalTo: leadingAnchor),
            markerInputField.trailingAnchor.constraint(equalTo: trailingAnchor),
            markerInputField.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        
        
    }
    
}
