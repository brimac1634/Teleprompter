//
//  TeleDatabase.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 11/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

public class TeleDatabase {
    
    class func saveData(values: [String: Any?], uidChildren: [String]?){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
        var userRef: DatabaseReference!
        var dataValues = values
        for (key, value) in values {
            if value is Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .medium
                let date = formatter.string(from: value as! Date)
                dataValues[key] = date
            }
        }
        
        
        if let nodes = uidChildren {
            userRef = ref.child("users").child(uid)
            for node in nodes {
                if node == "" {
                    userRef = userRef.childByAutoId()
                } else {
                   userRef = userRef.child(node)
                }
            }
        } else {
            userRef = ref.child("users").child(uid)
        }
        userRef.updateChildValues(dataValues, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
        })
    }
}
