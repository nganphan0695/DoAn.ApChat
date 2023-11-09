//
//  ProfileViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 14/10/2023.
//

import UIKit
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var avatarView: UIView!

    var imagePickUp = UIImagePickerController()
    var imageHasChange: Bool = false
    
    private var items = [Profile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        cursorColor()
        
        guard let email = Auth.auth().currentUser?.email else {return}
        showLoading(isShow: true)
        FirebaseManager.shared.getUserProfile(email, completion: {[weak self] user in
            UserDefaultsManager.shared.save(user)
                    self?.updateUser(user)
                    self?.showLoading(isShow: false)
        })
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
    
    func setupView(){
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.clipsToBounds = true
        cameraView.layer.cornerRadius = cameraView.frame.height / 2
    }
    
    @IBAction func handleSaveBt(_ sender: Any) {
        self.view.endEditing(true)
        
        if validate(){
            callAPIUpdateAvatarAndProfile()
        }
    }
    
    func validate() -> Bool{
        guard let nameCell = getCellAtItem(item: .name) else {return false}
        guard let emailCell = getCellAtItem(item: .email) else {return false}
        
        let name = nameCell.textField.text ?? ""
        let email = emailCell.textField.text ?? ""

        var nameValid = false
        var emailValid = false


        if name.isEmpty{
            nameCell.error(textError: "Tên không được để trống")
        }else{
            nameValid = true
            nameCell.setUpView()
        }

        if email.isEmpty{
            emailCell.error(textError: "Email không được để trống")
        }else if isValidEmail(email) == false{
            emailCell.error(textError: "Email không đúng định dạng")
        }else{
            emailValid = true
            emailCell.setUpView()
        }

        if emailValid == true && nameValid == true{
            return true
        }else{
            return false
        }
    }
    
    func getCellAtItem(item: ProfileItem) -> ProfileTableViewCell?{
        guard let row = items.firstIndex(where: { profile in
            return profile.item == item
        }) else {
            return nil
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? ProfileTableViewCell else {
            return nil
        }
        return cell
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        showActionSheet()
    }
    
    private func showActionSheet(){
        let alertVC = UIAlertController(title: nil, message: "Chọn ảnh", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { action in
        }
        alertVC.addAction(camera)
        
        let thuVien = UIAlertAction(title: "Thư viện", style: .default, handler: {
               (alert: UIAlertAction) -> Void in
               if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                   self.imagePickUp.delegate = self
                   self.imagePickUp.sourceType = UIImagePickerController.SourceType.photoLibrary;
                   self.present(self.imagePickUp, animated: true, completion: nil)
               }

           })
        alertVC.addAction(thuVien)
        
        let cancel = UIAlertAction(title: "Huỷ", style: .cancel)
        alertVC.addAction(cancel)
        alertVC.view.tintColor = Colors.primaryColor
        present(alertVC, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.avatarImage.image = image
        imagePickUp.dismiss(animated: true, completion: { () -> Void in
            self.imageHasChange = true
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickUp.dismiss(animated: true, completion: { () -> Void in
        })
    }
}

extension ProfileViewController{
    
    private func callAPIUpdateAvatarAndProfile(){
     
        let name        = getValue(item: .name)
        let email       = getValue(item: .email)
        let gender      = getValue(item: .gender)
        let birthday    = getValue(item: .birthday)
        let phone       = getValue(item: .phone)
        let address     = getValue(item: .address)
        
        var values: [String: Any] = [
            "name": name,
            "email": email,
            "gender": gender,
            "birthday": birthday,
            "phone": phone,
            "address": address
        ]
        
        if imageHasChange{
            if let imageData = self.avatarImage.image?.jpegData(compressionQuality: 0.5){
                showLoading(isShow: true)
                FirebaseManager.shared.uploadImage(imageData) {[weak self] status, imageName, url in
                    guard let self = self else{
                        self?.showLoading(isShow: false)
                        return
                    }
                  
                    values.updateValue(imageName ?? "", forKey: "photoName")
                    values.updateValue(url ?? "", forKey: "photoUrl")
                    
                    FirebaseManager.shared.updateUserProfile(values) { success, user, message in
                        if success{
                            self.updateUser(user)
                            UserDefaultsManager.shared.save(user)
                            self.showLoading(isShow: false)
                            self.showAlert(title: "Thành công", message: message)
                        }else{
                            self.showLoading(isShow: false)
                            self.showAlert(title: "Thất bại", message: message)
                        }
                    }
                }
            }
        }else{
            showLoading(isShow: true)
            FirebaseManager.shared.updateUserProfile(values) {[weak self] success, userNoImage, message in
                self?.showLoading(isShow: false)
                guard let strongSelf = self else { return }
                if success{
                    strongSelf.updateUser(userNoImage)
                    UserDefaultsManager.shared.save(userNoImage)
                    strongSelf.showAlert(title: "Thành công", message: message)
                }else{
                    strongSelf.showAlert(title: "Thất bại", message: message)
                }
            }
        }
    }
    
    func getValue(item: ProfileItem) -> String{
        let profile = items.first(where: {$0.item == item})
        return profile?.value ?? ""
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate{
    
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
        let isShowRequired = profile.item.isHiddenRequired()
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        cell.textField.text = profile.value
        cell.titleLabel.text = title
        cell.requiredlabel.isHidden = isShowRequired
        cell.textField.delegate = self
        if profile.item == .gender{
            cell.setupPicker()
            cell.lastSelected = profile.value
        }
        return cell
    }
}

extension ProfileViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: pointInTable){
            let profile = items[indexPath.row]
            guard let text = textField.text else {return}
            profile.value = text
        }
    }
}



