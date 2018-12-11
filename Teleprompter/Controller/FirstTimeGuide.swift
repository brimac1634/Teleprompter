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
    var secondTap: UITapGestureRecognizer!
    var thirdTap: UITapGestureRecognizer!
    var fourthTap: UITapGestureRecognizer!
    
    var rollingController: RollingTextController!
    
    var circles: [UIView] = []
    
    let shadeView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.netRoadshowGray(a: 1).cgColor
        view.layer.borderWidth = 5
        view.backgroundColor = .clear
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
        isUserInteractionEnabled = true
        if let rolling = rollingController {
            rolling.settingsButton.isUserInteractionEnabled = false
        }
        
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            guideLabel.font = UIFont.systemFont(ofSize: 36)
        } else {
            guideLabel.font = UIFont.systemFont(ofSize: 22)
        }
        
        let circleContainer = BaseView()
        
        for _ in 0 ..< 2 {
            let circle = BaseView()
            circle.backgroundColor = .white
            circle.layer.cornerRadius = 20
            circle.alpha = 0
            circle.isUserInteractionEnabled = false
            circleContainer.addSubview(circle)
            circles.append(circle)
        }
        
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            for circle in self.circles {
                circle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }, completion: nil)
        
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
            guideLabel.leadingAnchor.constraint(equalTo: shadeView.leadingAnchor, constant: 16),
            guideLabel.trailingAnchor.constraint(equalTo: shadeView.trailingAnchor, constant: -16),
            
            circleContainer.topAnchor.constraint(equalTo: shadeView.centerYAnchor),
            circleContainer.leadingAnchor.constraint(equalTo: shadeView.leadingAnchor),
            circleContainer.bottomAnchor.constraint(equalTo: shadeView.bottomAnchor),
            circleContainer.trailingAnchor.constraint(equalTo: shadeView.trailingAnchor),
            
            circles[0].widthAnchor.constraint(equalToConstant: 40),
            circles[0].heightAnchor.constraint(equalToConstant: 40),
            circles[0].centerXAnchor.constraint(equalTo: circleContainer.centerXAnchor, constant: -30),
            circles[0].centerYAnchor.constraint(equalTo: circleContainer.centerYAnchor, constant: 30),
            
            circles[1].widthAnchor.constraint(equalToConstant: 40),
            circles[1].heightAnchor.constraint(equalToConstant: 40),
            circles[1].centerXAnchor.constraint(equalTo: circleContainer.centerXAnchor, constant: 30),
            circles[1].centerYAnchor.constraint(equalTo: circleContainer.centerYAnchor, constant: -30)
            ])
        
        setupGestures()
        
        guideLabel.frame.origin.y = guideLabel.frame.origin.y + 50
        
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            self.shadeView.alpha = 1
        }) { (finished) in
            UIView.animate(withDuration: 0.25, animations: {
                self.guideLabel.alpha = 1
                self.circles[0].alpha = 0.8
                self.guideLabel.frame.origin.y -= 50
            })
        }
    }
    
    
    
    //MARK: - Gesture Methods
    
    fileprivate func setupGestures() {
        firstTap = UITapGestureRecognizer(target: self, action: #selector(handleFirst))
        secondTap = UITapGestureRecognizer(target: self, action: #selector(handleSecond))
        secondTap.numberOfTouchesRequired = 2
        thirdTap = UITapGestureRecognizer(target: self, action: #selector(handleThird))
        thirdTap.numberOfTouchesRequired = 2
        
        secondTap.isEnabled = false
        thirdTap.isEnabled = false
        
        shadeView.addGestureRecognizer(firstTap)
        shadeView.addGestureRecognizer(secondTap)
        shadeView.addGestureRecognizer(thirdTap)
    }
    
    @objc func handleFirst() {
        firstTap.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.guideLabel.frame.origin.y += 50
            self.guideLabel.alpha = 0
            for circle in self.circles {
                circle.alpha = 0
            }
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.shadeViewTrailing.isActive = false
                self.shadeViewTrailingCenter.isActive = true
                self.guideLabel.text = "Two finger tap on the left side of the screen to slow down scrolling"
                self.layoutIfNeeded()
            }, completion: { (_) in
                UIView.animate(withDuration: 0.25, animations: {
                    self.guideLabel.frame.origin.y -= 50
                    self.guideLabel.alpha = 1
                    for circle in self.circles {
                        circle.alpha = 0.8
                    }
                }, completion: { (_) in
                    self.secondTap.isEnabled = true
                })
            })
        }
    }
    
    @objc func handleSecond() {
        secondTap.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.guideLabel.frame.origin.y += 50
            self.guideLabel.alpha = 0
            for circle in self.circles {
                circle.alpha = 0
            }
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.shadeViewTrailingCenter.isActive = false
                self.shadeViewTrailing.isActive = true
                self.shadeViewLeading.isActive = false
                self.shadeViewLeadingCenter.isActive = true
                self.guideLabel.text = "Two finger tap on the right side of the screen to speed up scrolling"
                self.layoutIfNeeded()
            }, completion: { (_) in
                UIView.animate(withDuration: 0.25, animations: {
                    self.guideLabel.frame.origin.y -= 50
                    self.guideLabel.alpha = 1
                    for circle in self.circles {
                        circle.alpha = 0.8
                    }
                }, completion: { (_) in
                    self.thirdTap.isEnabled = true
                })
            })
        }
        
    }
    
    @objc func handleThird() {
        thirdTap.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.guideLabel.frame.origin.y += 50
            self.guideLabel.alpha = 0
            for circle in self.circles {
                circle.alpha = 0
            }
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.shadeView.alpha = 0
            }, completion: { (_) in
                self.removeFromSuperview()
                guard let rolling = self.rollingController else {return}
                rolling.settingsButton.isUserInteractionEnabled = true
                rolling.toggleControlPanel()
            })
        }
    }
    
}
