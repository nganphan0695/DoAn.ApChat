//
//  ForgotPasswordViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 15/10/2023.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)


    }
    
    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleResetPassword(_ sender: Any) {
        callAPI()
        self.navigationController?.popViewController(animated: true)
    }
    
    func callAPI(){
    }
}

