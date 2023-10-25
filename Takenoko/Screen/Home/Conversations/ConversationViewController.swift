//  ConversationViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 14/10/2023.

import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

class ConversationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFriendView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var plusView: UIView!
    
    var conversations = [Conversation]()
    var filters = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
        getAllConversation()
        setupTableView()
    }
    
    func setupView(){
        addFriendView.layer.cornerRadius = addFriendView.frame.height / 2
        addFriendView.layer.borderWidth = 1
        addFriendView.layer.borderColor = UIColor.white.cgColor
        addFriendView.clipsToBounds = true
        
        searchBar.layer.cornerRadius = 25
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.clear
        plusView.layer.cornerRadius = plusView.frame.height / 2
        plusView.clipsToBounds = true
    }
    
    func getAllConversation(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        FirebaseManager
            .shared
            .fireStore
            .collection(Constants.conversations)
            .document(uid)
            .collection(Constants.lastmessage)
            .order(by: Constants.timestamp)
            .addSnapshotListener {[weak self] querySnapshot, error in
                
                if let error = error {
                    print(error)
                    return
                }
                
                guard let self = self else { return }
                
                querySnapshot?.documentChanges.forEach(
                    { change in
                        
                        let docId = change.document.documentID
                        if let index = self.conversations.firstIndex(where: { rm in
                            return rm.id == docId
                        }) {
                            self.conversations.remove(at: index)
                        }
                        
                        let dict = change.document.data()
                        guard let text = dict[Constants.text] as? String else { return }
                        guard let email = dict[Constants.email] as? String else { return }
                        guard let fromId = dict[Constants.fromId] as? String else { return }
                        guard let toId = dict[Constants.toId] as? String else { return }
                        guard let timestamp = dict[Constants.timestamp] as? Timestamp else { return }
                        let photoUrl = dict[Constants.photoURL] as? String
                        let name = dict[Constants.name] as? String
                        
                        let conversation = Conversation(
                            id: docId,
                            text: text,
                            email: email,
                            fromId: fromId,
                            toId: toId,
                            photoUrl: photoUrl,
                            timeStamp: timestamp,
                            name: name
                        )
                        
                        self.conversations.insert(conversation, at: 0)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                )
            }
    }
    
    @IBAction func handleAddFriendBt(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let newMessageVC = storyboard.instantiateViewController(withIdentifier: "NewMessageViewController")
        self.navigationController?.pushViewController(newMessageVC, animated: true)
    }
    
    func showChatViewController(_ user: UserResponse){
        guard let currentUser = UserDefaultsManager.shared.getUser() else { return }
        let chatViewController = ChatViewController(currentUser: currentUser, user: user)
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension ConversationViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.lowercased()
        self.filters = conversations.filter({ conversation in
            let name = conversation.name?.lowercased() ?? ""
            return conversation.email.lowercased().contains(text) ||
            name.contains(text)
        })
        self.tableView.reloadData()
    }
}

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate{
    
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
        if let text = searchBar.text, !text.isEmpty{
            return filters.count
        }else{
            return self.conversations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let text = searchBar.text, !text.isEmpty{
            let conversation = self.filters[indexPath.row]
            return configureCell(conversation, tableView: tableView, indexPath: indexPath)
        }else{
            let conversation = self.conversations[indexPath.row]
            return configureCell(conversation, tableView: tableView, indexPath: indexPath)
        }
    }
    
    func configureCell(
        _ conversation: Conversation,
        tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        if let urlString = conversation.photoUrl,
           let photoUrl = URL(string: urlString) {
            cell.avatarImage.kf.setImage(with: photoUrl)
        }
        cell.timeAgoLabel.text = "\(conversation.timeStamp.dateValue())"
        if let name = conversation.name, !name.isEmpty{
            cell.userLabel.text = name
        }else{
            cell.userLabel.text = conversation.email
        }
        
        cell.contentLabel.text = conversation.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = self.conversations[indexPath.row]
        let email = conversation.email.safeEmail()
       
        FirebaseManager.shared.getUserProfile(email, completion: {[weak self] user in
            DispatchQueue.main.async {
                if let user = user{
                    self?.showChatViewController(user)
                }
            }
        })
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
            self.showAlert(title: "Xin lỗi", message: "Tính năng này sẽ được phát triển sau")
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
