//
//  ProfileViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 14/10/2023.
//

import UIKit


class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var avatarView: UIView!
    
    var imagePickUp = UIImagePickerController()
    
    private var items = [ProfileItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
        
//        let name = Profile(item: .name, value: "")
//        let email = Profile(item: .email, value: "")
//        let gender = Profile(item: .gender, value: "")
//        let birthday = Profile(item: .birthday, value: "")
//        let phone = Profile(item: .phone, value: "")
//        let address = Profile(item: .address, value: "")
        
        items = [.name, .email, .gender, .birthday, .phone, .address]
        setupTableView()

    }
    
    func setupView(){
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.clipsToBounds = true
        cameraView.layer.cornerRadius = cameraView.frame.height / 2
    }

    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleCheckmarkBt(_ sender: Any) {
      
        self.view.endEditing(true)
        if let imageData = self.avatarImage.image?.jpegData(compressionQuality: 0.5){
            callAPIUpdateAvatar(imageData: imageData)
        }
        
        if validate(){
            callAPIUpdateProfile()
            self.navigationController?.popViewController(animated: true)
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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func getCellAtItem(item: ProfileItem) -> ProfileTableViewCell?{
        guard let row = items.firstIndex(where: { profile in
            return profile == item
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
}

extension ProfileViewController{
    private func showActionSheet(){
        let alertVC = UIAlertController(title: nil, message: "Chọn ảnh", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { action in
            print("camera")
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
        
        present(alertVC, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.avatarImage.image = image
        imagePickUp.dismiss(animated: true, completion: { () -> Void in
            // Dismiss
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickUp.dismiss(animated: true, completion: { () -> Void in
            // Dismiss
        })
    }
}

extension ProfileViewController{
    
    private func callAPIUpdateAvatar(imageData: Data){
        
    }
    
    private func callAPIUpdateProfile(){
        
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
        let item = items[indexPath.row]
        let title = item.tittle()
        let isShowRequired = item.isHiddenRequired()
//        let errorView = item.isHiddenErrorView()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
//        cell.textField.text = items[indexPath.row].value
        cell.nameLabel.text = title
        cell.label.isHidden = isShowRequired
//        cell.errorView.isHidden = errorView
        
        cell.textField.delegate = self
        return cell
    }
}

extension ProfileViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: pointInTable){
            let item = items[indexPath.row]
//            switch item{
//            case .name:
//                self.updateProfileResponse.fullName = textField.text ?? ""
//            case .bio:
//                self.updateProfileResponse.bio = textField.text ?? ""
//            default:
//                break
//            }
        }
    }
}

