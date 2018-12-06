//
//  Script.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 6/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import RealmSwift

class Script: Object {
    @objc dynamic var scriptName: String = ""
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var scriptBody: String = ""
}

