//
//  Alerts.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 8/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit

class Alerts {
    class func showAlert(title: String, text: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return alert
    }
}
