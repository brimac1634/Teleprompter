//
//  firstTimeGuide.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 4/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class FirstTimeGuide: BaseView {
    
    var shadeViewTrailing: NSLayoutConstraint!
    var shadeViewLeading: NSLayoutConstraint!
    var shadeViewTrailingCenter: NSLayoutConstraint!
    var shadeViewLeadingCenter: NSLayoutConstraint!
    
    var firstTap: UITapGestureRecognizer!
    var secondTap: UIPanGestureRecognizer!
    var thirdTap: UITapGestureRecognizer!
    var fourthTap: UITapGestureRecognizer!
    
    var rollingController: RollingTextController!
    
    var circles: [UIView] = []
    
    let shadeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "Click anywhere on the screen to start or stop scrolling"
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    func presentGuide() {
        
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            guideLabel.font = UIFont.systemFont(ofSize: 36)
        } else {
            guideLabel.font = UIFont.systemFont(ofSize: 22)
        }
        
        let circleContainer = UIView()
        
        for _ in 0 ..< 2 {
            let circle = BaseView()
            circle.backgroundColor = .white
            circle.layer.cornerRadius = 20
            circle.alpha = 0
            circleContainer.addSubview(circle)
            circles.append(circle)
        }
        
        animateCircles()
        
        shadeView.alpha = 0
        guideLabel.alpha = 0
        
        
        shadeViewTrailing = shadeView.trailingAnchor.constraint(equalTo: trailingAnchor)
        shadeViewLeading = shadeView.leadingAnchor.constraint(equalTo: leadingAnchor)
        shadeViewLeadingCenter = shadeView.leadingAnchor.constraint(equalTo: centerXAnchor)
        shadeViewTrailingCenter = shadeView.trailingAnchor.constraint(equalTo: centerXAnchor)
        
        addSubview(shadeView)
        shadeView.addSubview(guideLabel)
        shadeView.addSubview(circleContainer)
        
        NSLayoutConstraint.activate([
            shadeView.topAnchor.constraint(equalTo: topAnchor),
            shadeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shadeViewLeading,
            shadeViewTrailing,
            
            guideLabel.topAnchor.constraint(equalTo: shadeView.topAnchor),
            guideLabel.bottomAnchor.constraint(equalTo: shadeView.centerYAnchor),
            guideLabel.widthAnchor.constraint(equalTo: shadeView.widthAnchor),
            guideLabel.centerXAnchor.constraint(equalTo: shadeView.centerXAnchor),
            
            circleContainer.topAnchor.constraint(equalTo: shadeView.centerYAnchor),
            circleContainer.leadingAnchor.constraint(equalTo: shadeView.leadingAnchor),
            circleContainer.bottomAnchor.constraint(equalTo: shadeView.bottomAnchor),
            circleContainer.trailingAnchor.constraint(equalTo: shadeView.trailingAnchor),
            
            circles[0].widthAnchor.constraint(equalToConstant: 40),
            circles[0].heightAnchor.constraint(equalToConstant: 40),
            circles[0].centerXAnchor.constraint(equalTo: shadeView.centerXAnchor, constant: -20),
            circles[0].centerYAnchor.constraint(equalTo: shadeView.centerYAnchor, constant: 20),
            
            circles[1].widthAnchor.constraint(equalToConstant: 40),
            circles[1].heightAnchor.constraint(equalToConstant: 40),
            circles[1].centerXAnchor.constraint(equalTo: shadeView.centerXAnchor, constant: 20),
            circles[1].centerYAnchor.constraint(equalTo: shadeView.centerYAnchor, constant: -20)
            ])
        
        setupGestures()
        
        guideLabel.frame.origin.y = guideLabel.frame.origin.y + 50
        
        UIView.animate(withDuration: 0.5, animations: {
            self.shadeView.alpha = 1
        }) { (finished) in
            UIView.animate(withDuration: 0.25, animations: {
                self.guideLabel.alpha = 1
                self.circles[0].alpha = 0.9
                self.guideLabel.frame.origin.y -= 50
            })
        }
    }
    
    
    
    //MARK: - Gesture Methods
    
    fileprivate func setupGestures() {
        firstTap = UITapGestureRecognizer(target: self, action: #selector(handleFirst))
        secondTap = UIPanGestureRecognizer(target: self, action: #selector(handleSecond))
        thirdTap = UITapGestureRecognizer(target: self, action: #selector(handleThird))
        fourthTap = UITapGestureRecognizer(target: self, action: #selector(handleFourth))
        
        shadeView.addGestureRecognizer(firstTap)
        shadeView.addGestureRecognizer(secondTap)
        shadeView.addGestureRecognizer(thirdTap)
        shadeView.addGestureRecognizer(fourthTap)
    }
    
    @objc func handleFirst() {
        
    }
    
    @objc func handleSecond() {
        
    }
    
    @objc func handleThird() {
        
    }
    
    @objc func handleFourth() {
        
    }

    
    //MARK: - Animation Method
    
    fileprivate func animateCircles() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            for circle in self.circles {
                circle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }, completion: nil)
    }
    
}
