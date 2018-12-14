//
//  InfoPopUp.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 13/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class InfoPopUp: UIView {
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let popUp: BaseView = {
        let view = BaseView()
        view.alpha = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    let topLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "Markers"
        label.backgroundColor = UIColor.netRoadshowBlue(a: 1)
        label.textColor = UIColor.netRoadshowGray(a: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    let firstLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "####"
        label.textColor = UIColor.netRoadshowDarkGray(a: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    let firstTextView: BaseTextView = {
        let textView = BaseTextView()
        textView.text = "Press the \"Add Mark\" button, or manually type \"####\" where you want to add a navigational break. This will allow you to skip to particular sections of your script easily and quickly."
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let secondLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "##Slide 4##"
        label.textColor = UIColor.netRoadshowDarkGray(a: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    let secondTextView: BaseTextView = {
        let textView = BaseTextView()
        textView.text = "Give the break point a custom name by writing in the middle of the marker, or leave it blank to default to simple numbered sections."
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        background.alpha = 0
        popUp.alpha = 0
        
        let infoStack = UIStackView(arrangedSubviews: [firstLabel, firstTextView, secondLabel, secondTextView])
        infoStack.axis = .vertical
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.spacing = 8
        
        addSubview(background)
        addSubview(popUp)
        popUp.addSubview(topLabel)
        popUp.addSubview(infoStack)
        
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            NSLayoutConstraint.activate([
                popUp.widthAnchor.constraint(equalToConstant: 450),
                popUp.heightAnchor.constraint(equalToConstant: 550),
                popUp.centerXAnchor.constraint(equalTo: centerXAnchor),
                popUp.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([
                popUp.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
                popUp.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75),
                popUp.centerXAnchor.constraint(equalTo: centerXAnchor),
                popUp.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
        }
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),

            topLabel.topAnchor.constraint(equalTo: popUp.topAnchor),
            topLabel.leadingAnchor.constraint(equalTo: popUp.leadingAnchor),
            topLabel.trailingAnchor.constraint(equalTo: popUp.trailingAnchor),
            topLabel.heightAnchor.constraint(equalToConstant: 45),
            
            infoStack.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 16),
            infoStack.leadingAnchor.constraint(equalTo: popUp.leadingAnchor, constant: 16),
            infoStack.trailingAnchor.constraint(equalTo: popUp.trailingAnchor, constant: -16),
            infoStack.bottomAnchor.constraint(equalTo: popUp.bottomAnchor, constant: -16),
            
            firstLabel.heightAnchor.constraint(equalTo: infoStack.heightAnchor, multiplier: 0.15),
            firstTextView.heightAnchor.constraint(equalTo: infoStack.heightAnchor, multiplier: 0.36),
            secondLabel.heightAnchor.constraint(equalTo: infoStack.heightAnchor, multiplier: 0.15),
            secondTextView.heightAnchor.constraint(equalTo: infoStack.heightAnchor, multiplier: 0.25),
            ])
        
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackground)))
        
        animatePopUp()
    }
    
    func animatePopUp() {
        popUp.frame.origin.y = popUp.frame.origin.y + 50
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.background.alpha = 1
            self.popUp.alpha = 1
            self.popUp.frame.origin.y = self.popUp.frame.origin.y - 50
        }, completion: nil)
    }
    
    func animatePopDown() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.background.alpha = 0
            self.popUp.alpha = 0
            self.popUp.frame.origin.y = self.popUp.frame.origin.y + 50
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @objc func handleBackground() {
        animatePopDown()
    }
}
