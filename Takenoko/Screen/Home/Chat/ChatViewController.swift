//
//  ChatViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 16/10/2023.
//

import UIKit
import Photos
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Kingfisher
import SwiftHEXColors

class ChatViewController: MessagesViewController {
    
    private var isSendingPhoto = false {
        didSet {
            messageInputBar.leftStackViewItems.forEach { item in
                guard let item = item as? InputBarButtonItem else {
                    return
                }
                item.isEnabled = !self.isSendingPhoto
            }
        }
    }
    
    private let database = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    private let user: UserResponse!
    private let currentUser: UserResponse!
    var receptImage: UIImage?
    var senderImage: UIImage?
    
    deinit {
        messageListener?.remove()
    }
    
    init(currentUser: UserResponse, user: UserResponse) {
     
        self.user = user
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
        if let receptURL = self.user.photoUrl,
           let url = URL(string: receptURL){
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: nil,
                progressBlock: nil
            ) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.receptImage = value.image
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
     
        if let senderURL = self.currentUser.photoUrl,
           let url = URL(string: senderURL){
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: nil,
                progressBlock: nil
            ) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.senderImage = value.image
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setNavigationItem(){
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.addTarget(self, action: #selector(didClickBack(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.sizeToFit()
        button.tintColor = UIColor.white
   
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.primaryColor
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func didClickBack(_ sender: UIBarButtonItem){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenToMessages()
        
        let name = self.user.name
        let title = name.isEmpty ? self.user.email : name
        setNavigationItem()
        navigationItem.title = title
        setUpMessageView()
        addCameraBarButton()
    }
    
    private func listenToMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        let toId = user.uid
        messageListener?.remove()
        
        messageListener = FirebaseManager.shared.fireStore
            .collection(Constants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: Constants.created)
            .addSnapshotListener {[weak self] querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        self?.handleDocumentChange(diff)
                    }
                  
                    if (diff.type == .modified) {
                        print("Modified message: \(diff.document.data())")
                    }
                    
                    if (diff.type == .removed) {
                        print("Removed Message: \(diff.document.data())")
                    }
                }
            }
    }
    
    private func setUpMessageView() {
        messageInputBar.inputTextView.tintColor = .blue
        messageInputBar.sendButton.setTitle("Gửi", for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    private func addCameraBarButton() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = Colors.primaryColor
        cameraItem.image = UIImage(systemName: "camera")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed),
            for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    // MARK: - Actions
    @objc private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // MARK: - Helpers
    private func save(_ message: Message) {
        FirebaseManager.shared.sendMessage(
            sender: currentUser,
            recipient: self.user,
            message: message
        ) {
            print("Gửi tin nhắn thành công")
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        if messages.contains(message) {
            return
        }
        
        messages.append(message)
        messages.sort()
        messagesCollectionView.reloadData()
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else { return }
        insertNewMessage(message)
    }
    
    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true
        if let data = image.jpegData(compressionQuality: 0.4){
            FirebaseManager.shared.sendImage(data) {[weak self] status, url in
                guard let self = self else { return }
                if let urlString = url,
                   let downloadURL = URL(string: urlString) {
                    var message = Message(user: currentUser, image: image)
                    message.downloadURL = downloadURL
                    self.save(message)
                    self.messagesCollectionView.scrollToLastItem()
                    self.isSendingPhoto = false
                    
                }else{
                    print("downloadURL Error")
                }
            }
        }
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Colors.primaryColor : Colors.recipentBackgroundColor
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = self.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }
    
    func getAvatarFor(sender: SenderType) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first?.uppercased()
        let lastName = sender.displayName.components(separatedBy: " ").last?.uppercased()
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        
        if user.uid == sender.senderId{
            return Avatar(image:self.receptImage, initials: initials)
        }else{
            return Avatar(image:self.senderImage, initials: initials)
        }
    }
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        switch message.kind {
        case .photo(let media):
            if let imageURL = media.url {
                imageView.kf.setImage(with: imageURL)
            }else{
                imageView.kf.cancelDownloadTask()
            }
        default:
            break
        }
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> SenderType {
        let name = currentUser.name
        let displayName = name.isEmpty ? currentUser.email : name
        return Sender(senderId: currentUser.uid, displayName: displayName)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ])
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(user: self.currentUser, content: text)
        save(message)
        inputBar.inputTextView.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: nil
            ) { result, _ in
                guard let image = result else {
                    return
                }
                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

