//
//  LoginViewController.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit
import Locksmith

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK: - OUTLETS
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var miniLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setLabels()
        setGesture()
        setButton()
        activityView.layer.cornerRadius = 10
        activityView.isHidden = true
    }
    
    private func setLabels(){
        welcomeLabel.addCharacterSpacing(kernValue: 1.05)
        miniLabel.addCharacterSpacing(kernValue: 0.05)
        loginLabel.addCharacterSpacing(kernValue: 0.05)
        passwordLabel.addCharacterSpacing(kernValue: 0.05)
    }
    
    private func setButton(){
        loginButton.layer.cornerRadius = 22.5
    }

    private func setGesture(){
        loginTF.delegate = self
        passwordTF.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        activityView.isHidden = false
        DispatchQueue.main.async {
            if NetworkService().login(login: self.loginTF.text ?? "", password: self.passwordTF.text ?? ""){
                if #available(iOS 13.0, *) {
                    let vc = self.storyboard?.instantiateViewController(identifier: "OrdersViewController") as! OrdersViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.saveToken()
                }
            } else {
                self.activityView.isHidden = true
                self.alertWindow(title: "Try again", message: "Wrong login or password")
            }
        }
    }
    
    private func saveToken(){
        do {
            try Locksmith.saveData(data: ["token": DataModel.sharedData.token, "access": DataModel.sharedData.access, "manager_id": DataModel.sharedData.idProfile], forUserAccount: "myUserAccount")
            print("save")
        } catch {
            print("SAVE ERROR")
        }
        do {
            try Locksmith.updateData(data: ["token": DataModel.sharedData.token, "access": DataModel.sharedData.access, "manager_id": DataModel.sharedData.idProfile], forUserAccount: "myUserAccount")
            print("update")
        } catch {
            print("UPDATE ERROR")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

