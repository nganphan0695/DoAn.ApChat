//
//  ReceiverProfileViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 04/11/2023.
//

import UIKit
import FirebaseAuth
import Kingfisher

class ReceiverProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var avatarView: UIView!
    
    private var items = [Profile]()
    
    var receiverEmail: String!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    func setupView(){
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.clipsToBounds = true
        
        if Network.shared.isConnected == false{
            showAlert(title: "Lỗi mạng", message: "Vui lòng kiểm tra kết nối internet!")
            return
        }else{
            showLoading(isShow: true)
            FirebaseManager.shared.getUserProfile(receiverEmail, completion: {[weak self] user in
                self?.updateUser(user)
                self?.showLoading(isShow: false)
            })
        }
    }
    
    func updateUser(_ user: UserResponse?){
        let name = Profile(item: .name, value: user?.name ?? "")
        let email = Profile(item: .email, value: user?.email ?? "")
        let gender = Profile(item: .gender, value: user?.gender ?? "")
        let birthday = Profile(item: .birthday, value: user?.birthday ?? "")
        let phone = Profile(item: .phone, value: user?.phone ?? "")
        let address = Profile(item: .address, value: user?.address ?? "")
        
        self.items = [name, email, gender, birthday, phone, address]
        
        DispatchQueue.main.async {
            if let photoUrl = user?.photoUrl, let url = URL(string: photoUrl){
                self.avatarImage.kf.setImage(with: url)
            }
            let userName = name.value.isEmpty ? email.value : name.value
            self.userNameLabel.text = userName
            self.tableView.reloadData()
        }
    }
    
    @IBAction func handleBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ReceiverProfileViewController: UITableViewDataSource, UITableViewDelegate{
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        let cell = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "ProfileTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profile = items[indexPath.row]
        let title = profile.item.tittle()
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        cell.textField.text = profile.value
        cell.textField.isEnabled = false
        cell.titleLabel.text = title
        cell.requiredlabel.isHidden = true
        return cell
    }
}
