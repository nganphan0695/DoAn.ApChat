//
//  ForgotPasswordViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 15/10/2023.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
   
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var resetPasswordBt: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var clearEmailView: UIView!
    @IBOutlet weak var emailText: UITextField!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        resetPasswordBt.isEnabled = false
        setUpView()
        setupEmailView()
        emailText.text = email
        cursorColor()
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
        
        emailText.autocorrectionType = .no
    }
    
    func setupEmailView(){
        emailText.backgroundColor = .white
        emailText.addTarget(self, action: #selector(textFieldDidEditing(_:)), for: .editingChanged)
        emailText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        clearEmailView.isHidden = true
        emailErrorView.isHidden = true
    }
    
    @objc func textFieldDidEditing(_ textField: UITextField){
        let _ = validate()
    }
    
    func emailError(textError: String){
        emailErrorView.isHidden = false
        emailText.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        emailText.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        clearEmailView.isHidden = false
        clearEmailView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        emailErrorLabel.text = textError
    }
    
    @IBAction func clearEmail(_ sender: Any) {
        emailText.text = ""
        setupEmailView()
    }
    
    func validate() -> Bool{
        let email: String = emailText.text ?? ""
        var emailValid = false
        
        if email.isEmpty{
            emailError(textError: "Email không được để trống")
        }else if isValidEmail(email) == false{
            emailError(textError: "Email không đúng định dạng")
        }else{
            emailValid = true
            setupEmailView()
        }
        
        if emailValid == true{
            resetPasswordBt.isEnabled = true
            return true
        }else{
            return false
        }
    }
    
    @IBAction func faceBookAndGoogleAndApple(_ sender: Any) {
        showAlert(title: "Xin lỗi", message: "Tính năng này sẽ được phát triển sau")
    }
    
    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleResetPassword(_ sender: Any) {
        if validate(){
            if Network.shared.isConnected == false{
                showAlert(title: "Lỗi mạng", message: "Vui lòng kiểm tra kết nối internet!")
                return
            }else{
                callAPI()
            }
        }
    }
    
    func callAPI(){
        let email: String = emailText.text ?? ""
        
        showLoading(isShow: true)
        Auth.auth().sendPasswordReset(withEmail: email){ [weak self] error in
            guard let strongSelf = self else {
                self?.showLoading(isShow: false)
                return
            }
            guard error == nil else{
                strongSelf.showLoading(isShow: false)
                strongSelf.showAlert(title: "Lỗi", message: "Yêu cầu chưa được xử lý thành công\n Vui lòng thử lại sau")
                return
            }
            strongSelf.showLoading(isShow: false)
            
            let alertVC = UIAlertController(
                title: "Thành công",
                message: "Vui lòng kiểm tra email để đặt mật khẩu mới",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel){ action in
                strongSelf.navigationController?.popViewController(animated: true)
            }
            alertVC.addAction(okAction)
            alertVC.view.tintColor = Colors.primaryColor
            strongSelf.present(alertVC, animated: true)
        }
    }
}

