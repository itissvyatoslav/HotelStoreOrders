//
//  Extensions.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit
import Locksmith

extension UILabel {
    func addCharacterSpacing(kernValue: Double = 1.15) {
      if let labelText = text, labelText.count > 0 {
        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
        attributedText = attributedString
      }
    }
}

extension UIViewController {
    func alertWindow(title: String, message: String){
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "Close",
            style: .default,
            handler: { _ in
                alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func alertLogout(){
        // Declare Alert message
        let dialogMessage = UIAlertController(title: "Log out", message: "Do you want to log out?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            NetworkService().logout()
            DataModel.sharedData.token = "default token"
            DataModel.sharedData.access = ""
            DataModel.sharedData.idProfile = 0
            do {
                try Locksmith.updateData(data: ["token": DataModel.sharedData.token, "access": DataModel.sharedData.access, "manager_id": DataModel.sharedData.idProfile], forUserAccount: "myUserAccount")
                print("update")
            } catch {
                print("error")
            }
            if #available(iOS 13.0, *) {
                let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(vc, animated: true)
                vc.navigationItem.hidesBackButton = true
                
            }
            
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
}
