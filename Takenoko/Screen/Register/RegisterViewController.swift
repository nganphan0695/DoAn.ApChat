//
//  RegisterViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 13/10/2023.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var clearEmailView: UIView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var clearNameView: UIView!
    @IBOutlet weak var nameErrorView: UIView!
    @IBOutlet weak var nameErrorLabel: UILabel!
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var secureImage: UIImageView!
    @IBOutlet weak var secureTextEntryView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupNameView()
        setupEmailView()
        setupPasswordView()

    }
    
    func setupEmailView(){
        emailText.backgroundColor = .white
        emailText.addTarget(self, action: #selector(textFieldDidEditing(_:)), for: .editingChanged)
        emailText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        clearEmailView.isHidden = true
        emailErrorView.isHidden = true
    }
    
    func setupPasswordView(){
        passwordText.backgroundColor = .white
        passwordText.addTarget(self, action: #selector(textFieldDidEditing(_:)), for: .editingChanged)
        secureTextEntryView.backgroundColor = .white
        passwordText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        passwordErrorView.isHidden = true
    }
    
    func setupNameView(){
        nameText.backgroundColor = .white
        nameText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        nameText.addTarget(self, action: #selector(textFieldDidEditing(_:)), for: .editingChanged)
        clearNameView.isHidden = true
        nameErrorView.isHidden = true
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
    
    func nameError(textError: String){
        nameErrorView.isHidden = false
        clearNameView.isHidden = false
        nameText.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        nameText.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        clearNameView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        nameErrorLabel.text = textError
    }
    
    @IBAction func clearName(_ sender: Any) {
        nameText.text = ""
        setupNameView()
    }
    
    func passError(textError: String){
        passwordErrorView.isHidden = false
        passwordText.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        passwordText.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        secureTextEntryView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        passwordErrorLabel.text = textError
    }
    
    @IBAction func isSecureText(_ sender: Any) {
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
            let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.pushViewController(loginViewController, animated: true)
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
        let name: String = nameText.text ?? ""
        
        var emailValid = false
        var passwordValid = false
        var nameValid = false
        
        if name.isEmpty{
            nameError(textError: "Tên không được để trống")
        }else{
            nameValid = true
            setupNameView()
        }
        
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
        
        if emailValid == true && passwordValid == true && nameValid == true{
            return true
        }else{
            return false
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func callAPILogin(){
        
    }
}
