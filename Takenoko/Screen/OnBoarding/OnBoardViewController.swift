//
//  OnBoardViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 12/10/2023.
//

import UIKit

class OnBoardViewController: UIViewController {

    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var appleView: UIView!
    
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
       setUpView()
    }
    
    func setUpView(){
        googleView.layer.cornerRadius = 24
        googleView.layer.borderWidth = 1
        googleView.layer.borderColor = UIColor.black.cgColor
        
        facebookView.layer.cornerRadius = 24
        facebookView.layer.borderWidth = 1
        facebookView.layer.borderColor = UIColor.black.cgColor
        
        appleView.layer.cornerRadius = 24
        appleView.layer.borderWidth = 1
        appleView.layer.borderColor = UIColor.black.cgColor
        
        facebookButton.layer.cornerRadius = 24
        appleButton.layer.cornerRadius = 24
        googleButton.layer.cornerRadius = 24
    }
    
    @IBAction func handleButton(_ sender: Any) {
        showAlert(title: "Xin lỗi", message: "Tính năng này sẽ được phát triển sau")
    }

    @IBAction func handleLoginBt(_ sender: Any) {
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func handleSignUpBt(_ sender: Any) {
        let registerViewController = RegisterViewController(nibName: "RegisterViewController", bundle: nil)
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
}
