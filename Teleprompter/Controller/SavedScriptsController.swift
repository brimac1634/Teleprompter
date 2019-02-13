//
//  SavedScriptsController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 6/12/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit
import RealmSwift


class SavedScriptsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {
    
    let realm = try! Realm()
    var homeController: HomeController?
    var usingIpad: Bool = true
    var filteredtList: Results<Script>!

    var scriptList: Results<Script>? {
        didSet {
            loadData()
            filteredtList = scriptList
        }
    }
    
    
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(FolderCell.self, forCellReuseIdentifier: "cellID")
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.autocorrectionType = .no
        bar.delegate = self
        bar.searchBarStyle = .prominent
        bar.placeholder = "Search scripts..."
        bar.tintColor = UIColor.netRoadshowDarkGray(a: 1)
        bar.barTintColor = UIColor.netRoadshowGray(a: 1)
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            usingIpad = true
        } else {
            usingIpad = false
        }

        setupView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let logoImage = UIImageView(image: UIImage(named: "logo"))
        logoImage.contentMode = .scaleAspectFit
        navigationItem.titleView = logoImage
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let home = homeController else {return}
        if realm.objects(Script.self).filter("scriptName = %@", home.currentScriptName).first == nil {
            home.topLabel.text = "Teleprompter Text"
            home.currentScriptName = ""
            home.textBox.text = "Type or paste your script here..."
            home.textBox.textColor = .lightGray
        }
        
    }
    
    fileprivate func setupView() {
        view.addSubview(tableView)
        view.addSubview(searchBar)
        
        if #available(iOS 11.0, *) {
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 63).isActive = true
        }
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func loadData() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let script = filteredtList?[indexPath.row] {
            popToHomeWithScript(script: script)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredtList?.count ?? 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! FolderCell
        if let script = filteredtList?[indexPath.row] {
            cell.script = script
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let script = filteredtList?[indexPath.row] else {return}
        if editingStyle == .delete {
            deleteScript(script, tableView, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = usingIpad ? 100 : 60
        return height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    //MARK: - Gesture Methods
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        if indexPath != nil && gesture.state == .began {
            guard let list = scriptList else {return}
            guard let index = indexPath else {return}
            let script = list[index.row]
            
            let alert = UIAlertController(title: script.scriptName, message: nil, preferredStyle: .actionSheet)
            let useAction = UIAlertAction(title: "Use Script", style: .default) { (_) in
                self.popToHomeWithScript(script: script)
            }
            let editAction = UIAlertAction(title: "Edit Name", style: .default) { (_) in
                self.editScriptName(currentScript: script)
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                self.deleteScript(script, self.tableView, index)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(useAction)
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            if let popoverController = alert.popoverPresentationController {
                guard let cell = tableView.cellForRow(at: index) else {return}
                popoverController.sourceView = cell
                popoverController.sourceRect = CGRect(x: cell.bounds.midX, y: cell.bounds.midY, width: 0, height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func handleAdd() {
        guard let home = homeController else {return}
        self.navigationController?.popViewController(animated: true)
        home.createNewScriptButton()
    }
    
    //MARK: - Alert Methods
    
    fileprivate func popToHomeWithScript(script: Script) {
        guard let home = self.homeController else {return}
        home.textBox.text = script.scriptBody
        home.textBox.textColor = .black
        home.currentScriptName = script.scriptName
        home.topLabel.text = script.scriptName
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func deleteScript(_ script: Script, _ tableView: UITableView, _ indexPath: IndexPath) {
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
    
    fileprivate func overWriteAlert(oldScript: Script, newScript: Script) {
        let alert = UIAlertController(title: "There is already a script named \"\(oldScript.scriptName)\"", message: "Do you wish to save over it?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            try! self.realm.write {
                newScript.scriptName = oldScript.scriptName
                self.realm.delete(oldScript)
            }
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.editScriptName(currentScript: newScript)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func editScriptName(currentScript: Script) {
        let editAlert = UIAlertController(title: "Edit Name", message: "Give your script a new name", preferredStyle: .alert)
        editAlert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Type new name here"
        })
        editAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let textField = editAlert.textFields else {return}
            let field = textField[0]
            if let chosenScript = self.realm.objects(Script.self).filter("scriptName = %@", field.text!).first {
                self.overWriteAlert(oldScript: chosenScript, newScript: currentScript)
            } else {
                try! self.realm.write {
                    currentScript.scriptName = field.text ?? "Untitled"
                }
                self.loadData()
            }
        }))
        editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Search Bar Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.count == 0 {
            filteredtList = scriptList
        } else {
            filteredtList = scriptList?.filter("scriptName CONTAINS[cd] %@", searchText)
        }
        tableView.reloadData()
    }
    

}
