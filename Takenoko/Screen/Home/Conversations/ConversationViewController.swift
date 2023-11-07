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
    @IBOutlet weak var avatarImage: UIImageView!
    
    var conversations = [Conversation]()
    var filters = [Conversation]()
    
    private var dispatchGroup = DispatchGroup()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
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
        
        guard let email = Auth.auth().currentUser?.email else {return}
        showLoading(isShow: true)
        FirebaseManager.shared.getUserProfile(email, completion: {[weak self] user in
            if let photoUrl = user?.photoUrl, let url = URL(string: photoUrl){
                self?.avatarImage.kf.setImage(with: url)
            }
            self?.showLoading(isShow: false)
        })
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
                querySnapshot?.documentChanges.forEach({ change in
                    switch change.type{
                    case .added:
                        self.addConversation(change)
                        
                    case .removed:
                        self.removeConversation(change)
                        self.tableView.reloadData()
                        
                    case .modified:
                        self.modifiedConversation(change)
                        
                    default:
                        break
                        
                    }
                })
            }
    }
    
    func addConversation(_ change: DocumentChange){
        if let conversation = createConversation(change){
            self.conversations.insert(conversation, at: 0)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func createConversation(_ change: DocumentChange) -> Conversation? {
        let documentID = change.document.documentID
        let dict = change.document.data()
        guard let text = dict[Constants.text] as? String else { return nil }
        guard let email = dict[Constants.email] as? String else { return nil }
        guard let fromId = dict[Constants.fromId] as? String else { return nil }
        guard let toId = dict[Constants.toId] as? String else { return nil }
        guard let timestamp = dict[Constants.timestamp] as? Timestamp else { return nil }
        let photoUrl = dict[Constants.photoURL] as? String
        let name = dict[Constants.name] as? String
        
        let conversation = Conversation(
            id: documentID,
            text: text,
            email: email,
            fromId: fromId,
            toId: toId,
            photoUrl: photoUrl,
            timeStamp: timestamp,
            name: name
        )
        return conversation
    }
    
    func modifiedConversation(_ change: DocumentChange){
        let documentID = change.document.documentID
        if let index = self.conversations.firstIndex(where: { rm in
            return rm.id == documentID
        }) {
            self.conversations.remove(at: index)
            if let conversation = createConversation(change){
                self.conversations.insert(conversation, at: index)
                self.tableView.reloadData()
            }
        }
    }
    
    func removeConversation(_ change: DocumentChange){
        let documentID = change.document.documentID
        if let index = self.conversations.firstIndex(where: { rm in
            return rm.id == documentID
        }) {
            self.conversations.remove(at: index)
        }
    }
    
    @IBAction func handleAddFriendBt(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let newMessageVC = storyboard.instantiateViewController(withIdentifier: "NewMessageViewController")
        self.navigationController?.pushViewController(newMessageVC, animated: true)
    }
    
    func showChatViewController(_ receiver: UserResponse){
        guard let currentUser = UserDefaultsManager.shared.getUser() else { return }
        let chatViewController = ChatViewController(currentUser: currentUser, receiver: receiver)
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
            
            if !conversation.text.isEmpty{
                let createdAt = conversation.timeStamp.dateValue()
                let now = Date()
                let createdAtDisplay = createdAt.timeSinceDate(fromDate: now)
                cell.timeAgoLabel.text = createdAtDisplay
            }else{
                cell.timeAgoLabel.text = nil
            }
        
            if let name = conversation.name, !name.isEmpty{
                cell.userLabel.text = name
            }else{
                cell.userLabel.text = conversation.email
            }
            
            cell.contentLabel.text = conversation.text
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let text = searchBar.text, !text.isEmpty{
            let conversation = self.filters[indexPath.row]
            let email = conversation.email
            FirebaseManager.shared.getUserProfile(email, completion: {[weak self] user in
                DispatchQueue.main.async {
                    if let user = user{
                        self?.showChatViewController(user)
                    }
                }
            })
        }else{
            let conversation = self.conversations[indexPath.row]
            let email = conversation.email
            FirebaseManager.shared.getUserProfile(email, completion: {[weak self] user in
                DispatchQueue.main.async {
                    if let user = user{
                        self?.showChatViewController(user)
                    }
                }
            })
        }
    }
    
    private func deleteConversation(at indexPath: IndexPath){
        self.dispatchGroup.enter()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let conversation = self.conversations[indexPath.row]
        let email = conversation.email
        FirebaseManager.shared.getUserProfile(email, completion: {[weak self] user in
            DispatchQueue.main.async {
                if let user = user{
                    FirebaseManager
                        .shared
                        .fireStore
                        .collection(Constants.conversations)
                        .document(uid)
                        .collection(Constants.lastmessage)
                        .document(user.uid)
                        .delete { error in
                            self?.dispatchGroup.leave()
                        }
                }
            }
        })
    }
    
    private func deleteMessage(at indexPath: IndexPath){
        self.dispatchGroup.enter()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let conversation = self.conversations[indexPath.row]
        let email = conversation.email
        FirebaseManager.shared.getUserProfile(email, completion: { user in
            if let user = user{
                FirebaseManager.shared.fireStore
                    .collection(Constants.messages)
                    .document(uid)
                    .collection(user.uid)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            if let documents = querySnapshot?.documents{
                                for document in documents {
                                    document.reference.delete()
                                }
                            }
                        }
                    }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {
            (action, sourceView, completionHandler) in
            let alertVC = UIAlertController(
                title: nil,
                message: "Xoá cuộc hội thoại?",
                preferredStyle: .alert
            )
            let delete = UIAlertAction(title: "Xoá", style: .destructive){action in
                self.deleteConversation(at: indexPath)
                self.deleteMessage(at: indexPath)
                completionHandler(true)
            }
            let cancel = UIAlertAction(title: "Huỷ", style: .cancel)
            alertVC.addAction(delete)
            alertVC.addAction(cancel)
            self.present(alertVC, animated: true)
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
