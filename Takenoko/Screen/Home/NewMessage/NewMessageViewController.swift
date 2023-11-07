//
//  NewMessageViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 21/10/2023.
//

import UIKit
import Kingfisher

class NewMessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    var users = [UserResponse]()
    var filteredUsers = [UserResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        searchBar.delegate = self
        
        FirebaseManager.shared.getAllUser {[weak self] users in
            self?.users = users
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func setupView(){
        searchBar.layer.cornerRadius = 25
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.clear
    }
    
    @IBAction func handleBackBt(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension NewMessageViewController: UITableViewDataSource, UITableViewDelegate{
    
    func setupTableView(){
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        let newMessageTableViewCell = UINib(nibName: "NewMessageTableViewCell", bundle: nil)
        tableView.register(newMessageTableViewCell, forCellReuseIdentifier: "NewMessageTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageTableViewCell", for: indexPath) as! NewMessageTableViewCell
        let user = filteredUsers[indexPath.row]
        cell.nameLabel.text = user.name
        cell.emailLabel.text = user.email
        cell.numberPhoneLabel.text = user.phone
        if let photoUrl = user.photoUrl, let url = URL(string: photoUrl){
            let placeholder = UIImage(systemName: "person.circle.fill")
            cell.avatarImage.kf.setImage(with: url, placeholder: placeholder)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let receiver = self.filteredUsers[indexPath.row]
        guard let currentUser = UserDefaultsManager.shared.getUser() else { return }
        let chatViewController = ChatViewController(currentUser: currentUser, receiver: receiver)
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension NewMessageViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercase = searchText.lowercased()
        self.filteredUsers = self.users.filter({
            $0.name.lowercased().contains(lowercase) ||
            $0.email.lowercased().contains(lowercase) ||
            $0.phone.lowercased().contains(lowercase)
        })
        print(filteredUsers.count)
        self.tableView.reloadData()
    }
}
