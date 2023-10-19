//  RegisterViewController.swift
//  Takenoko
//  Created by Ngân Phan on 13/10/2023.

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var clearEmailView: UIView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var confirmPasswordSecureImage: UIImageView!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var confirmPasswordSecureView: UIView!
    @IBOutlet weak var confirmPasswordErrorView: UIView!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var secureImage: UIImageView!
    @IBOutlet weak var secureTextEntryView: UIView!
    
    @IBOutlet weak var registerBt: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupConfirmPasswordView()
        setupEmailView()
        setupPasswordView()
        registerBt.isEnabled = false
    }
    
    func setupEmailView(){
        emailText.backgroundColor = .white
        emailText.addTarget(self, action: #selector(textFieldDidEditing(_:)), for: .editingChanged)
        emailText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        clearEmailView.isHidden = true
        emailErrorView.isHidden = true
        emailText.autocorrectionType = .no
    }
    
    func setupPasswordView(){
        passwordText.backgroundColor = .white
        passwordText.addTarget(self, action: #selector(textFieldDidEditing(_:)), for: .editingChanged)
        secureTextEntryView.backgroundColor = .white
        passwordText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        passwordErrorView.isHidden = true
        passwordText.autocorrectionType = .no
    }
    
    func setupConfirmPasswordView(){
        confirmPasswordText.backgroundColor = .white
        confirmPasswordText.addTarget(self, action: #selector(textFieldDidEditing(_:)), for: .editingChanged)
        confirmPasswordSecureView.backgroundColor = .white
        confirmPasswordText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        confirmPasswordErrorView.isHidden = true
        confirmPasswordText.autocorrectionType = .no
    }
    
    func emailError(textError: String){
        emailErrorView.isHidden = false
        clearEmailView.isHidden = false
        emailText.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        emailText.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        clearEmailView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        emailErrorLabel.text = textError
    }
    
    @IBAction func clearEmail(_ sender: Any) {
        emailText.text = ""
        setupEmailView()
    }
    
    func confirmPasswordError(textError: String){
        confirmPasswordErrorView.isHidden = false
        confirmPasswordText.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        confirmPasswordText.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        confirmPasswordSecureView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        confirmPasswordErrorLabel.text = textError
    }
    
    @IBAction func isSecureTextConfirmPassword(_ sender: Any) {
        confirmPasswordText.isSecureTextEntry = !confirmPasswordText.isSecureTextEntry
        let isSecureTextEntry = confirmPasswordText.isSecureTextEntry
        let hideImage = UIImage(systemName: "eye.slash")
        let showImage = UIImage(systemName: "eye")
        confirmPasswordSecureImage.image = isSecureTextEntry ? hideImage : showImage
    }
    
    func passError(textError: String){
        passwordErrorView.isHidden = false
        passwordText.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        passwordText.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        secureTextEntryView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        passwordErrorLabel.text = textError
    }
    
    @IBAction func isSecureTextPassword(_ sender: Any) {
        passwordText.isSecureTextEntry = !passwordText.isSecureTextEntry
        let isSecureTextEntry = passwordText.isSecureTextEntry
        let hideImage = UIImage(systemName: "eye.slash")
        let showImage = UIImage(systemName: "eye")
        secureImage.image = isSecureTextEntry ? hideImage : showImage
    }
    
    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleRegisterBt(_ sender: Any) {
        if validate(){
            callAPILogin()
        }
    }
    
    @objc func textFieldDidEditing(_ textField: UITextField){
        let _ = validate()
    }
}

extension RegisterViewController{
    
    func validate() -> Bool{
        let email: String = emailText.text ?? ""
        let password: String = passwordText.text ?? ""
        let confirmPassword: String = confirmPasswordText.text ?? ""
        
        var emailValid = false
        var passwordValid = false
        var confirmPasswordValid = false
        
        if email.isEmpty{
            emailError(textError: "Email không được để trống")
        }else if isValidEmail(email) == false{
            emailError(textError: "Email không đúng định dạng")
        }else{
            emailValid = true
            setupEmailView()
        }

        if password.isEmpty{
            passError(textError: "Mật khẩu không được để trống")
        }else if password.count < 8 || password.count > 20 {
            passError(textError: "Mật khẩu dài từ 8 đến 20 ký tự")
        }else{
            passwordValid = true
            setupPasswordView()
        }
        
        if confirmPassword.isEmpty{
            confirmPasswordError(textError: "Mật khẩu không được để trống")
        }else if confirmPassword != password{
            confirmPasswordError(textError: "Mật khẩu chưa đúng")
        }else{
            confirmPasswordValid = true
            setupConfirmPasswordView()
        }
        
        if emailValid == true && passwordValid == true && confirmPasswordValid == true{
            registerBt.isEnabled = true
            return true
        }else{
            return false
        }
    }

    func callAPILogin(){
        let email: String = emailText.text ?? ""
        let password: String = passwordText.text ?? ""
//        let confirmPassword: String = confirmPasswordText.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] authResult, error in
            guard let self = self else {return}
            
            guard error == nil else{
                switch AuthErrorCode.Code(rawValue: error!._code){
                case .emailAlreadyInUse:
                    self.showAlert(title: "Lỗi", message: "Email đã tồn tại")
                case .invalidEmail:
                    self.showAlert(title: "Lỗi", message: "Email không hợp lệ")
                default:
                    self.showAlert(title: "Lỗi", message: error?.localizedDescription ?? "")
                }
                return
            }
//            let user = authResult?.user
            let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(loginViewController, animated: true)
        }
    }
}
