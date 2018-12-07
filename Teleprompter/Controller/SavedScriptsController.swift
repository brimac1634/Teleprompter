//
//  SavedScriptsController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 6/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import RealmSwift

class SavedScriptsController: UITableViewController, UIActionSheetDelegate {
    
    let realm = try! Realm()
    var homeController: HomeController?
    var usingIpad: Bool = true

    var scriptList: Results<Script>? {
        didSet {
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            usingIpad = true
        } else {
            usingIpad = false
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let logoImage = UIImageView(image: UIImage(named: "logo"))
        logoImage.contentMode = .scaleAspectFit
        navigationItem.titleView = logoImage
    }
    
    private func loadData() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let script = scriptList?[indexPath.row] {
            let alert = UIAlertController(title: script.scriptName, message: nil, preferredStyle: .actionSheet)
            let useAction = UIAlertAction(title: "Use Script", style: .default) { (_) in
                guard let home = self.homeController else {return}
                home.textBox.text = script.scriptBody
                home.textBox.textColor = .black
                home.currentScriptName = script.scriptName
                home.topLabel.text = script.scriptName
                self.navigationController?.popViewController(animated: true)
            }
            let editAction = UIAlertAction(title: "Edit Name", style: .default) { (_) in
                let editAlert = UIAlertController(title: "Edit Name", message: "Give your script a new name", preferredStyle: .alert)
                editAlert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Type new name here"
                })
                editAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                    guard let textField = editAlert.textFields else {return}
                    let field = textField[0]
                    try! self.realm.write {
                        script.scriptName = field.text ?? ""
                    }
                    self.loadData()
                }))
                editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(editAlert, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(useAction)
            alert.addAction(editAction)
            alert.addAction(cancelAction)
            
            if let popoverController = alert.popoverPresentationController {
                guard let cell = tableView.cellForRow(at: indexPath) else {return}
                popoverController.sourceView = cell
                popoverController.sourceRect = CGRect(x: cell.bounds.midX, y: cell.bounds.midY, width: 0, height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scriptList?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.textColor = UIColor.netRoadshowBlue(a: 1)
        cell.textLabel?.font = usingIpad ? UIFont.systemFont(ofSize: 28) : UIFont.systemFont(ofSize: 18)
        if let script = scriptList?[indexPath.row] {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .medium
            let date = formatter.string(from: script.dateCreated)
            cell.textLabel?.text = "\(date) - \(script.scriptName)"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let script = scriptList?[indexPath.row] else {return}
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Script", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                try! self.realm.write {
                    self.realm.delete(script)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = usingIpad ? 100 : 60
        return height
    }

    
}
