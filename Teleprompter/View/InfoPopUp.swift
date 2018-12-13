//
//  InfoPopUp.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 13/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class InfoPopUp: BaseView {
    
    let firstLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "\"####\""
        label.textColor = UIColor.netRoadshowDarkGray(a: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    let firstTextView: BaseTextView = {
        let textView = BaseTextView()
        textView.text = "Press the \"Add Mark\" button, or manually type \"####\" where you want to add a directory heading. This will allow you to skip to particular sections of your script easily and quickly."
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let secondLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "\"##Slide 4##\""
        label.textColor = UIColor.netRoadshowDarkGray(a: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    let secondTextView: BaseTextView = {
        let textView = BaseTextView()
        textView.text = "Type a custom directory heading in the middle of the marker, or leave it blank to default to simple numbered sections."
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    
    override func setupView() {
        alpha = 0
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 12
        dropShadow()
        
        let infoStack = UIStackView(arrangedSubviews: [firstLabel, firstTextView, secondLabel, secondTextView])
        infoStack.axis = .vertical
        infoStack.distribution = .fillProportionally
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.spacing = 8
        
        addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            infoStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            infoStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            ])
        
        
    }
    
    func animatePopUp() {
        frame.origin.y = frame.origin.y + 50
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.frame.origin.y = self.frame.origin.y - 50
        }, completion: nil)
    }
    
    func animatePopDown() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.alpha = 0
            self.frame.origin.y = self.frame.origin.y + 50
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}
