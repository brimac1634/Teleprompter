//
//  FolderCell.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 13/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit

class FolderCell: UITableViewCell {
    
    var script: Script? {
        didSet {
            guard let selectedScript = script else {return}
            scriptLabel.text = selectedScript.scriptName
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .medium
            let date = formatter.string(from: selectedScript.dateCreated)
            dateLabel.text = date
            
        }
    }
    
    let scriptLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.netRoadshowBlue(a: 1)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.netRoadshowDarkGray(a: 1)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    fileprivate func setupView() {
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            scriptLabel.font = UIFont.boldSystemFont(ofSize: 28)
            dateLabel.font = UIFont.systemFont(ofSize: 28)
        } else {
            scriptLabel.font = UIFont.boldSystemFont(ofSize: 18)
            dateLabel.font = UIFont.systemFont(ofSize: 16)
        }
        
        addSubview(scriptLabel)
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            scriptLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            scriptLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scriptLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -16),
            scriptLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
