//
//  Extension.swift
//  Takenoko
//
//  Created by Ngân Phan on 18/10/2023.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIViewController{
    func showAlert(title: String, message: String?){
        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
    
    func showLoading(isShow: Bool) {
        
        if isShow {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
