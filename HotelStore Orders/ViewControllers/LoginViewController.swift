//
//  LoginViewController.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //MARK: - OUTLETS
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var miniLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setLabels()
        setGesture()
        setButton()
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
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if loginTF.text == "Test" && passwordTF.text == "Test"{
            if #available(iOS 13.0, *) {
                let vc = storyboard?.instantiateViewController(identifier: "OrdersViewController") as! OrdersViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            alertWindow(title: "Try again", message: "Wrong login or password")
        }
    }
    
}

