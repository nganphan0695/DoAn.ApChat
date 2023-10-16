//
//  MessageViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 14/10/2023.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var avatarImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
        setupTableView()
    }
    
    func setupView(){
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.clipsToBounds = true
        
        searchBar.layer.cornerRadius = 25
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.clear
    }
    
    @IBAction func handleProfileBt(_ sender: Any) {
        goToProfile()
    }
    
    func goToProfile(){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)

        let navigationVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController

        self.navigationController?.pushViewController(navigationVC, animated: true)
    }

}

extension MessageViewController: UITableViewDataSource, UITableViewDelegate{
    
    func setupTableView(){
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        let messageTableViewCell = UINib(nibName: "MessageTableViewCell", bundle: nil)
        tableView.register(messageTableViewCell, forCellReuseIdentifier: "MessageTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatViewController = ChatViewController(nibName: "ChatViewController", bundle: nil)
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {
            (action, sourceView, completionHandler) in
            //test action
            
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let notificationAction = UIContextualAction(style: .normal, title: nil) {
            (action, sourceView, completionHandler) in
            //
            completionHandler(true)
        }
        notificationAction.image = UIImage(systemName: "bell")
        notificationAction.backgroundColor = UIColor(red: 255/255.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0)
  
        let lockAction = UIContextualAction(style: .normal, title: "Share") {
            (action, sourceView, completionHandler) in
            //
            completionHandler(true)
        }
        lockAction.image = UIImage(systemName: "lock")
        lockAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, lockAction, notificationAction])

        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }
    
}
