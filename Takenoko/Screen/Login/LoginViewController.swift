//  LoginViewController.swift
//  Takenoko
//  Created by Ngân Phan on 13/10/2023.

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var clearEmailView: UIView!
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var secureTextEntry: UIView!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var secureTextEntryImage: UIImageView!
    
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var loginBt: UIButton!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupEmailView()
        setupPasswordView()
        setUpView()
        loginBt.isEnabled = false
        emailText.text = email
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
        passwordText.autocorrectionType = .no
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
        secureTextEntry.backgroundColor = .white
        passwordText.layer.borderColor = UIColor(red: 0.31, green: 0.29, blue: 0.40, alpha: 1.00).cgColor
        passwordErrorView.isHidden = true
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
    
    func passError(textError: String){
        passwordErrorView.isHidden = false
        passwordText.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        passwordText.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        secureTextEntry.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        passwordErrorLabel.text = textError
    }
    
    @IBAction func secureButton(_ sender: Any) {
        passwordText.isSecureTextEntry = !passwordText.isSecureTextEntry
        let isSecureTextEntry = passwordText.isSecureTextEntry
        let hideImage = UIImage(systemName: "eye.slash")
        let showImage = UIImage(systemName: "eye")
        secureTextEntryImage.image = isSecureTextEntry ? hideImage : showImage
    }
    
    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleButton(_ sender: Any) {
        showAlert(title: "Xin lỗi", message: "Tính năng này sẽ được phát triển sau")
    }
    
    @IBAction func handleLoginBt(_ sender: Any) {
        if validate(){
            callAPILogin()
        }
    }
    
    @IBAction func handleForgotPassword(_ sender: Any) {
        let navigationVC = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(navigationVC, animated: true)
    }
    
    @objc func textFieldDidEditing(_ textField: UITextField){
        let _ = validate()
    }
}

extension LoginViewController{
    
    func validate() -> Bool{
        let email: String = emailText.text ?? ""
        let password: String = passwordText.text ?? ""
        
        var emailValid = false
        var passwordValid = false
        
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
        
        if emailValid == true && passwordValid == true{
            loginBt.isEnabled = true
            return true
        }else{
            return false
        }
    }
    
    func goToHome(){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeUITabBarViewController")
        let navigation = UINavigationController(rootViewController: homeVC)
        
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = navigation
        keyWindow?.makeKeyAndVisible()
    }
    
    func callAPILogin(){
        let email: String = emailText.text ?? ""
        let password: String = passwordText.text ?? ""
        
        showLoading(isShow: true)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                self?.showLoading(isShow: false)
                return
            }
            guard error == nil else{
                self?.showLoading(isShow: false)
                let alertVC = UIAlertController(title: "Lỗi", message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertVC.addAction(okAction)
                strongSelf.present(alertVC, animated: true)
                return
            }
            UserDefaultsManager.shared.setIsLogin(true)
            if let userEmail = authResult?.user.email?.safeEmail(){
                FirebaseManager.shared.getUserProfile(userEmail) { user in
            
                    if let user = user{
                        self?.showLoading(isShow: false)
                        UserDefaultsManager.shared.save(user)
                        strongSelf.goToHome()
                    }else{
                        self?.showLoading(isShow: false)
                        strongSelf.goToHome()
                    }
                }
            }else{
                self?.showLoading(isShow: false)
                strongSelf.goToHome()
            }
        }
    }
}
