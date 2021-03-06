//
//  ProfileController.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 3/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MessageUI

class ProfileController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var homeController: HomeController!
    var currentEmail: String = ""
    var loadingIndicator: UIActivityIndicatorView!
    
    let logoView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "NetRoadshowTeleprompterIcon"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let userLabel: BaseTextView = {
        let label = BaseTextView()
        label.textAlignment = .center
        label.isEditable = false
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var logoutButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("Logout", for: .normal)
        btn.setTitleColor(UIColor.netRoadshowBlue(a: 1), for: .normal)
        btn.backgroundColor = UIColor.netRoadshowGray(a: 1)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return btn
    }()
    
    lazy var resetPasswordButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("Reset Password", for: .normal)
        btn.setTitleColor(UIColor.netRoadshowBlue(a: 1), for: .normal)
        btn.backgroundColor = UIColor.netRoadshowGray(a: 1)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return btn
    }()
    
    lazy var removeAdsButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("Remove Ads", for: .normal)
        btn.titleLabel?.textColor = UIColor.white
        btn.backgroundColor = UIColor.netRoadshowBlue(a: 1)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleRemoveAds), for: .touchUpInside)
        return btn
    }()
    
    lazy var restorePurchaseButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("Restore Purchase", for: .normal)
        btn.setTitleColor(UIColor.netRoadshowBlue(a: 1), for: .normal)
        btn.backgroundColor = UIColor.netRoadshowGray(a: 1)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleRestorePurchase), for: .touchUpInside)
        return btn
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        configureDatabase()
        configureIAP()
        
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(logoView)
        view.addSubview(userLabel)
        view.addSubview(logoutButton)
        view.addSubview(resetPasswordButton)
        view.addSubview(removeAdsButton)
        view.addSubview(restorePurchaseButton)
        
        if ( UIDevice.current.model.range(of: "iPad") != nil) {
            NSLayoutConstraint.activate([
                logoView.widthAnchor.constraint(equalToConstant: 200),
                logoView.heightAnchor.constraint(equalToConstant: 200),
                logoutButton.heightAnchor.constraint(equalToConstant: 50)
                ])
            
        } else {
            NSLayoutConstraint.activate([
                logoView.widthAnchor.constraint(equalToConstant: 150),
                logoView.heightAnchor.constraint(equalToConstant: 150),
                logoutButton.heightAnchor.constraint(equalToConstant: 45)
                ])
            
        }
        
        NSLayoutConstraint.activate([
            userLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -12),
            userLabel.widthAnchor.constraint(equalToConstant: 280),
            userLabel.heightAnchor.constraint(equalToConstant: 100),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 8),
            logoutButton.widthAnchor.constraint(equalTo: userLabel.widthAnchor),
            
            resetPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetPasswordButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 8),
            resetPasswordButton.widthAnchor.constraint(equalTo: userLabel.widthAnchor),
            resetPasswordButton.heightAnchor.constraint(equalTo: logoutButton.heightAnchor),
            
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.bottomAnchor.constraint(equalTo: userLabel.topAnchor, constant: -12),
            
            removeAdsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeAdsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            removeAdsButton.widthAnchor.constraint(equalTo: userLabel.widthAnchor),
            removeAdsButton.heightAnchor.constraint(equalTo: logoutButton.heightAnchor),
            
            restorePurchaseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restorePurchaseButton.bottomAnchor.constraint(equalTo: removeAdsButton.topAnchor, constant: -8),
            restorePurchaseButton.widthAnchor.constraint(equalTo: userLabel.widthAnchor),
            restorePurchaseButton.heightAnchor.constraint(equalTo: logoutButton.heightAnchor)
            ])
        

        let deleteButton = UIBarButtonItem(image: UIImage(named: "waste"), style: .plain, target: self, action: #selector(handleDeleteAccount))
        deleteButton.tintColor = UIColor.netRoadshowBlue(a: 1)
        
        
        let supportButton = UIBarButtonItem(image: UIImage(named: "support"), style: .plain, target: self, action: #selector(handleSupport))
        supportButton.tintColor = UIColor.netRoadshowBlue(a: 1)
        navigationItem.rightBarButtonItems = [deleteButton, supportButton]
    }
    
    //MARK: - Selector Methods
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Unable to sign out: ", error)
        }
        
        guard let home = homeController else {return}
        navigationController?.popViewController(animated: true)
        home.handleLogout()
    }
    
    @objc func handleDeleteAccount() {
        if Reachability.isConnectedToNetwork() {
            guard let user = Auth.auth().currentUser else {return}
            let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete this account? All user data will be deleted forever and cannot be undone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                self.deleteData(uid: user.uid)
                user.delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let alert = UIAlertController(title: "Account Deleted", message: "Your user account has successfully been deleted.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                            self.perform(#selector(self.handleLogout), with: nil, afterDelay: 0)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.present(Alerts.showAlert(title: "No Internet", text: "You must be connected to the internet in order to delete your user account."), animated: true, completion: nil)
        }
        
    }
    
    @objc func handleResetPassword() {
        if Reachability.isConnectedToNetwork() {
            guard currentEmail.count > 0 else {return}
            let alert = UIAlertController(title: "Reset Password", message: "Are you sure you wish to reset your password?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Reset", style: .default, handler: { (_) in
                Auth.auth().sendPasswordReset(withEmail: self.currentEmail) { (error) in
                    if error != nil {
                        self.present(Alerts.showAlert(title: "Error", text: "There was an error while sending the password reset request. Please try again later."), animated: true, completion: nil)
                        return
                    } else {
                        self.present(Alerts.showAlert(title: "Reset Password", text: "Please check your email for a password reset link."), animated: true, completion: nil)
                    }
                    
                }
            }))
            alert.preferredAction = alert.actions[0]
            self.present(alert, animated: true, completion: nil)
        } else {
            self.present(Alerts.showAlert(title: "No Internet", text: "You must be connected to the internet in order to delete your user account."), animated: true, completion: nil)
        }
        
    }
    
    @objc func handleRemoveAds() {
        if Reachability.isConnectedToNetwork() {
            presentLoadIndicator()
            IAPHandler.shared.purchaseMyProduct(index: IAPHandler.shared.NON_CONSUMABLE_PURCHASE_PRODUCT_ID)
        } else {
            self.present(Alerts.showAlert(title: "No Internet", text: "You must be connected to the internet in order to delete your user account."), animated: true, completion: nil)
        }
    }
    
    @objc func handleRestorePurchase() {
        if Reachability.isConnectedToNetwork() {
            presentLoadIndicator()
            IAPHandler.shared.restorePurchase()
        } else {
            self.present(Alerts.showAlert(title: "No Internet", text: "You must be connected to the internet in order to delete your user account."), animated: true, completion: nil)
        }
    }
    
    @objc func handleSupport() {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["bmacpherson@netroadshow.com"])
            mailVC.setCcRecipients(["brimac1634@gmail.com"])
            mailVC.setSubject("NRS Teleprompter Support - profile: \(currentEmail)")
            mailVC.setMessageBody(
                "Name: \n Email: \(currentEmail) \n Message: If you are experiencing difficulties with the teleprompter or simply want to provide input, please explain the issue here and we will get back to you as soon as possible.", isHTML: false)
            self.present(mailVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Support Email", message: "If you require support, please email a description of your issue to: Brimac1634@gmail.com", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Copy Email", style: .default, handler: { (_) in
                UIPasteboard.general.string = "Brimac1634@gmail.com"
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.preferredAction = alert.actions[0]
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func presentLoadIndicator() {
        loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .gray
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    //MARK: - Firebase Methods
    
    fileprivate func configureDatabase() {
        if Reachability.isConnectedToNetwork() {
            presentLoadIndicator()
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
            ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String: AnyObject] {
                    guard let currentUser = value["email"] else {return}
                    let currentUserString = String(describing: currentUser)
                    self.currentEmail = currentUserString
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: "You are currently signed in as...\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.netRoadshowDarkGray(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                    attributedString.append(NSAttributedString(string: currentUserString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.netRoadshowBlue(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                    self.userLabel.attributedText = attributedString
                    
                    self.loadingIndicator.stopAnimating()
                } else {
                    self.displayNoUserFound()
                    self.loadingIndicator.stopAnimating()
                }
            }, withCancel: nil)
        } else {
            displayNoUserFound()
        }
        
        
    }
    
    fileprivate func displayNoUserFound() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        self.userLabel.attributedText = NSAttributedString(string: "Unable to retrieve current user. Please check internet signal...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.netRoadshowDarkGray(a: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    fileprivate func deleteData(uid: String) {
        let ref = Database.database().reference(fromURL: "https://netroadshow-teleprompter.firebaseio.com/")
        let userRef = ref.child("users").child(uid)
        userRef.removeValue { (error, dataRef) in
            if error != nil {
                print(error)
            }
        }
        
    }
    
    //MARK: - IAP Methods
    
    fileprivate func configureIAP() {
        guard homeController.defaults.bool(forKey: "canSkipAds") == false else {return}
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            print("type", type)
            guard let strongSelf = self else{ return }
            if type == .purchased {
                strongSelf.setCanSkipAds(type, strongSelf)
            } else if type == .restored {
                strongSelf.setCanSkipAds(type, strongSelf)
            } else {
                strongSelf.loadingIndicator.stopAnimating()
                strongSelf.present(Alerts.showAlert(title: "Purchase Incomplete", text: "Your purchase was not completed"), animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func setCanSkipAds(_ type: (IAPHandlerAlertType), _ strongSelf: ProfileController) {
        TeleDatabase.saveData(values: ["canSkipAds": true], uidChildren: nil)
        let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            
        })
        alertView.addAction(action)
        strongSelf.present(alertView, animated: true, completion: nil)
        strongSelf.homeController.defaults.set(true, forKey: "canSkipAds")
        loadingIndicator.stopAnimating()
    }
    
    //MARK: - MFMailComposeViewController Method
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
        if result.rawValue == 2 {
            self.present(Alerts.showAlert(title: "Thank You", text: "We will get in touch with you shortly"), animated: true, completion: nil)
        }
    }
    
}
