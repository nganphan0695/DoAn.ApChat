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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
        if Network.shared.isConnected == false{
            showAlert(title: "Lỗi mạng", message: "Vui lòng kiểm tra kết nối internet!")
        }else{
            getAllConversation()
            setAvatar()
        }
        setupTableView()
    }
    
    func setAvatar(){
        if let user = UserDefaultsManager.shared.getUser(),
           let photoUrl = user.photoUrl,
           let url = URL(string: photoUrl){
            self.avatarImage.kf.setImage(with: url)
        }
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
        
        var islock: Bool = false
        var password: String = ""
        
        if let isLockValue = dict[Constants.isLock] as? Bool,
           let passwordValue = dict[Constants.password] as? String{
            islock = isLockValue
            password = passwordValue
        }
        
        let conversation = Conversation(
            id: documentID,
            text: text,
            email: email,
            fromId: fromId,
            toId: toId,
            photoUrl: photoUrl,
            timeStamp: timestamp,
            name: name,
            isLock: islock,
            password: password
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
                self.conversations.insert(conversation, at: 0)
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
        if conversation.isLock{
            cell.lockImage.isHidden = false
        }else{
            cell.lockImage.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Network.shared.isConnected == false{
            showAlert(title: "Lỗi mạng", message: "Vui lòng kiểm tra kết nối internet!")
            return
        }
        if let text = searchBar.text, !text.isEmpty{
            let conversation = self.filters[indexPath.row]
            if conversation.isLock{
                self.checkPassword(conversation)
                return
            }
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
            if conversation.isLock{
                self.checkPassword(conversation)
                return
            }
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
        
        let conversation = self.conversations[indexPath.row]
        let isLock = conversation.isLock
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {
            (action, sourceView, completionHandler) in
            if Network.shared.isConnected == false{
                self.showAlert(title: "Lỗi mạng", message: "Vui lòng kiểm tra kết nối internet!")
                return
            }
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
            alertVC.view.tintColor = Colors.primaryColor
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
        
        let lockAction = UIContextualAction(style: .normal, title: nil) {
            (action, sourceView, completionHandler) in
            if isLock{
                self.unlockConversation(indexPath)
            }else{
                self.lockConversation(indexPath)
            }
            completionHandler(true)
        }
        
        var image = UIImage(systemName: "lock")
        if isLock{
            image = UIImage(systemName: "lock.open")
        }
        
        lockAction.image = image
        lockAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, notificationAction, lockAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }
    
    func lockConversation(_ indexPath: IndexPath){
        let conversation = self.conversations[indexPath.row]
        let alertVC = UIAlertController(
            title: nil,
            message: "Khoá cuộc hội thoại?",
            preferredStyle: .alert
        )
        
        let lock = UIAlertAction(title: "Khoá", style: .destructive){ action in
            if let password = alertVC.textFields?[0].text{
                conversation.isLock = true
                conversation.password = password
                self.updateConversation(conversation)
            }
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        lock.isEnabled = false
        
        let cancel = UIAlertAction(title: "Huỷ", style: .cancel)
        
        alertVC.addTextField { textField in
            textField.placeholder = "Nhập mật khẩu tối thiểu 6 ký tự"
            textField.isSecureTextEntry = true
            textField.addTarget(alertVC, action: #selector(alertVC.textDidChangePasswordAlert), for: .editingChanged)
        }
        alertVC.addAction(lock)
        alertVC.addAction(cancel)
        alertVC.view.tintColor = Colors.primaryColor
        self.present(alertVC, animated: true)
    }
    
    
    //MARK: - Unlock
    func unlockConversation(_ indexPath: IndexPath){
        let conversation = self.conversations[indexPath.row]
        let alertVC = UIAlertController(
            title: nil,
            message: "Mở khoá cuộc hội thoại?",
            preferredStyle: .alert
        )
        
        let lock = UIAlertAction(title: "Mở khoá", style: .destructive){ alert in
            if let password = alertVC.textFields?[0].text{
                if conversation.password != password{
                    self.showAlert(title: "Lỗi", message: "Mật khẩu không khớp!")
                    return
                }
                conversation.isLock = false
                conversation.password = ""
                self.updateConversation(conversation)
            }
        }
        lock.isEnabled = false
        
        let cancel = UIAlertAction(title: "Huỷ", style: .cancel)
        
        alertVC.addTextField { textField in
            textField.placeholder = "Nhập mật khẩu tối thiểu 6 ký tự"
            textField.isSecureTextEntry = true
            textField.addTarget(alertVC, action: #selector(alertVC.textDidChangePasswordAlert), for: .editingChanged)
        }
        
        alertVC.addAction(lock)
        alertVC.addAction(cancel)
        alertVC.view.tintColor = Colors.primaryColor
        self.present(alertVC, animated: true)
    }
    
    func updateConversation(_ conversation: Conversation){
        if Network.shared.isConnected == false{
            showAlert(title: "Lỗi mạng", message: "Vui lòng kiểm tra kết nối internet!")
            return
        }
        let email = conversation.email
        guard let curentUserId = Auth.auth().currentUser?.uid else { return }
        FirebaseManager.shared.getUserProfile(email, completion: { user in
            if let user = user{
                FirebaseManager.shared.updateRecentMessage(
                    isLock: conversation.isLock,
                    password: conversation.password,
                    currentUserId: curentUserId,
                    recipientId: user.uid
                ) { status in
                    let title: String = conversation.isLock ? "Khóa cuộc hội thoại" :  "Mở khoá cuộc hội thoại"
                    if status{
                        self.showAlert(title: title, message: "Thành công!")
                    }else{
                        self.showAlert(title: title, message: "Thất bại!")
                    }
                }
            }
        })
    }
    
    func checkPassword(_ conversation: Conversation){
        if Network.shared.isConnected == false{
            self.showAlert(title: "Lỗi mạng", message: "Vui lòng kiểm tra kết nối internet!")
            return
        }
        let alertVC = UIAlertController(
            title: nil,
            message: "Nhập mật khẩu",
            preferredStyle: .alert
        )
        
        let lock = UIAlertAction(title: "Xác minh", style: .default){ alert in
            if let password = alertVC.textFields?[0].text{
                if conversation.password != password{
                    self.showAlert(title: "Lỗi", message: "Mật khẩu không khớp!")
                    return
                }
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
        
        lock.isEnabled = false
        
        let cancel = UIAlertAction(title: "Huỷ", style: .cancel)
        
        alertVC.addTextField { textField in
            textField.placeholder = "Nhập mật khẩu tối thiểu 6 ký tự"
            textField.isSecureTextEntry = true
            textField.addTarget(alertVC, action: #selector(alertVC.textDidChangePasswordAlert), for: .editingChanged)
        }
        
        alertVC.addAction(lock)
        alertVC.addAction(cancel)
        alertVC.view.tintColor = Colors.primaryColor
        self.present(alertVC, animated: true)
    }
}


extension UIAlertController {
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6 && password.rangeOfCharacter(from: .whitespacesAndNewlines) == nil
    }
    
    @objc func textDidChangePasswordAlert() {
        if let password = textFields?[0].text,
           let action = actions.first {
            action.isEnabled = isValidPassword(password)
        }
    }
}
