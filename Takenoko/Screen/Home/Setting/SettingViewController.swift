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
    
    private var items = [SettingItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        items = [.notification, .security, .help, .darkMode, .logOut]
        setUpTableView()
    }
    
    func setupView(){
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.clipsToBounds = true
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
//        let isShowSwitch = item.isHiddenSwitch()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.titleLabel.text = title
        cell.iconImageView.image = image
        cell.buttonView.isHidden = isShowBt
//        cell.switchView.isHidden = isShowSwitch
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let item = items[indexPath.row]
            switch item{
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
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            goToNavigationOnBoard()
        } catch let signOutError as NSError {
            showAlert(title: "Lỗi", message: signOutError.localizedDescription)
        }
    }
    
}
