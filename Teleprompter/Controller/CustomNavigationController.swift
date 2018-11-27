//
//  CustomNavigationController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 27/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    var rollingTextController: RollingTextController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rollingTextController = RollingTextController()
    }
    

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override var shouldAutorotate: Bool {
        guard let rollingController = rollingTextController else {return true}
        if rollingController.controlPanelIsOn {
            return false
        } else {
            return true
        }
        
    }

}
