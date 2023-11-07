//  SettingViewController.swift
//  Takenoko
//  Created by Ngân Phan on 15/10/2023.

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    private var items = [SettingItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
        items = [.notification, .resetPassword, .introduce, .darkMode, .logOut]
        setUpTableView()
    }
    
    func setupView(){
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.clipsToBounds = true
        
        guard let email = Auth.auth().currentUser?.email else {return}
        showLoading(isShow: true)
        FirebaseManager.shared.getUserProfile(email, completion: {[weak self] user in
            DispatchQueue.main.async {
                if let photoUrl = user?.photoUrl, let url = URL(string: photoUrl){
                    self?.avatarImage.kf.setImage(with: url)
                }
                let userName = user?.name
                if userName != nil && !userName!.isEmpty{
                    self?.userNameLabel.text = userName
                }else{
                    self?.userNameLabel.text = email
                }
                
            }
                self?.showLoading(isShow: false)
        })
    }
    
    private func setUpTableView(){
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        let cell = UINib(nibName: "SettingTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "SettingTableViewCell")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let title = item.tittle()
        let image = item.image()
        let isShowBt = item.isHiddenButton()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.titleLabel.text = title
        cell.iconImageView.image = image
        cell.buttonView.isHidden = isShowBt
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let item = items[indexPath.row]
            switch item{
            case .resetPassword:
                handleResetPassword()
            case .introduce:
                handleIntroduce()
            case .logOut:
                handleLogout()
            default:
                return showAlert(title: "Xin lỗi", message: "Tính năng này sẽ được phát triển sau")
            }
        }
    
    func goToNavigationOnBoard(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationVC = storyboard.instantiateViewController(withIdentifier: "NavigationOnBoard")
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = navigationVC
        keyWindow?.makeKeyAndVisible()
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            UserDefaultsManager.shared.remove()
            goToNavigationOnBoard()
        } catch let signOutError as NSError {
            showAlert(title: "Lỗi", message: signOutError.localizedDescription)
        }
    }
    
    func handleResetPassword(){
        let forgotPasswordViewController = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    func handleIntroduce(){
        let introduceViewController = IntroduceViewController(nibName: "IntroduceViewController", bundle: nil)
        self.navigationController?.pushViewController(introduceViewController, animated: true)
    }
}
