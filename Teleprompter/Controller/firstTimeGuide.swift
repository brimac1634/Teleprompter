//
//  firstTimeGuide.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 4/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class FirstTimeGuide: NSObject {
    
    var shadeViewTrailing: NSLayoutConstraint!
    var shadeViewLeading: NSLayoutConstraint!
    
    
    let shadeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let guideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        label.text = "Single click anywhere on the screen to pause or start scrolling"
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    func presentGuide() {
        shadeView.alpha = 0
        guideLabel.alpha = 0
        guard let window = UIApplication.shared.keyWindow else {return}
        
        shadeViewTrailing = shadeView.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        shadeViewLeading = shadeView.leadingAnchor.constraint(equalTo: window.leadingAnchor)
        
        window.addSubview(shadeView)
        shadeView.addSubview(guideLabel)
        
        NSLayoutConstraint.activate([
            shadeView.topAnchor.constraint(equalTo: window.topAnchor),
            shadeView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            shadeViewLeading,
            shadeViewTrailing,
            
            guideLabel.centerXAnchor.constraint(equalTo: shadeView.centerXAnchor),
            guideLabel.centerYAnchor.constraint(equalTo: shadeView.centerYAnchor),
            guideLabel.widthAnchor.constraint(equalTo: shadeView.widthAnchor),
            guideLabel.heightAnchor.constraint(equalToConstant: 200)
            ])
        
        guideLabel.frame.origin.y = guideLabel.frame.origin.y + 50
        
        UIView.animate(withDuration: 0.5, animations: {
            self.shadeView.alpha = 1
        }) { (finished) in
            UIView.animate(withDuration: 0.25, animations: {
                self.guideLabel.alpha = 1
                self.guideLabel.frame.origin.y -= 50
            })
        }
    }
    

}
