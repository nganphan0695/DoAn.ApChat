//
//  SettingViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 15/10/2023.
//

import UIKit

enum SettingItem: Int {
    case notification = 0
    case security
    case help
    case darkMode
    case logOut
    
    func tittle() -> String{
        switch self{
        case .notification:
            return "Thông báo"
        case .security:
            return "Bảo mật"
        case .help:
            return "Trợ giúp"
        case .darkMode:
            return "Giao diện"
        case .logOut:
            return "Đăng xuất"
        }
    }
    
    func image() -> UIImage?{
        switch self{
        case .notification:
            return UIImage(systemName: "bell")
        case .security:
            return UIImage(systemName: "lock")
        case .help:
            return UIImage(systemName: "questionmark.circle")
        case .darkMode:
            return UIImage(systemName: "moon")
        case .logOut:
            return UIImage(systemName: "rectangle.portrait.and.arrow.right")
        }
    }
    
//    func isHiddenSwitch() -> Bool{
//        switch self{
//        case .darkMode:
//            return false
//        default:
//            return true
//        }
//    }
    
    func isHiddenButton() -> Bool{
        switch self{
        case .notification, .security, .help:
            return false
        default:
            return true
        }
    }
}

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
                AuthServices.shared.clearAccessToken()
                if let unWindow = (UIApplication.shared.delegate as? AppDelegate)?.window{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let navigationVC = storyboard.instantiateViewController(withIdentifier: "NavigationOnBoard")
                    unWindow.rootViewController = navigationVC
                    unWindow.makeKeyAndVisible()
                }
            default:
                return showAlert()
            }
        }
    func showAlert(){
        let alertVC = UIAlertController(title: "Xin lỗi", message: "Tính năng này sẽ được phát triển sau", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel)
        alertVC.addAction(cancel)
        present(alertVC, animated: true)
    }
    
}
