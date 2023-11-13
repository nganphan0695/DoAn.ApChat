//
//  ProfileTableViewCell.swift
//  Takenoko
//
//  Created by Ngân Phan on 15/10/2023.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var requiredlabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var picker = UIPickerView()
    var datePicker = UIDatePicker()
    
    let gender = ["Nam", "Nữ", "Khác"]
    var lastSelected: String = ""
    var lastSelectedDate: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.autocorrectionType = .no        
        setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupPicker(){
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45)
        let toolbar = UIToolbar(frame: frame)
        toolbar.barStyle = .default
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let chooseButton = UIBarButtonItem(title: "Chọn", style: .plain, target: self, action: #selector(chooseButtonClicked(_:)))
        let cancelButton = UIBarButtonItem(title: "Huỷ", style: .plain, target: self, action: #selector(cancelButtonClicked(_:)))
        toolbar.setItems([cancelButton, flexibleSpace, chooseButton], animated: false)
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
    }
    
    func setupDatePicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.didChangeDate(_:)), for: .allEvents)
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45)
        let toolbar = UIToolbar(frame: frame)
        toolbar.barStyle = .default
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let chooseButton = UIBarButtonItem(title: "Chọn", style: .plain, target: self, action: #selector(chooseDateButtonClicked(_:)))
        let cancelButton = UIBarButtonItem(title: "Huỷ", style: .plain, target: self, action: #selector(cancelDateButtonClicked(_:)))
        toolbar.setItems([cancelButton, flexibleSpace, chooseButton], animated: false)
        textField.inputAccessoryView = toolbar
        self.textField.inputView = datePicker
    }
    
    @objc func didChangeDate(_ picker: UIDatePicker){
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormater.string(from: picker.date)
        self.textField.text = dateString
    }
    
    @objc func chooseDateButtonClicked(_ sender: UIBarButtonItem){
        self.textField.resignFirstResponder()
    }
    
    @objc func cancelDateButtonClicked(_ sender: UIBarButtonItem){
        self.textField.text = self.lastSelectedDate
        self.textField.resignFirstResponder()
    }
    
    
    @objc func chooseButtonClicked(_ sender: UIBarButtonItem){
        self.textField.resignFirstResponder()
    }
    
    @objc func cancelButtonClicked(_ sender: UIBarButtonItem){
        self.textField.text = self.lastSelected
        self.textField.resignFirstResponder()
    }
    
    func setUpView(){
        errorView.isHidden = true
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.black.cgColor
    }
    
    func error(textError: String){
        errorView.isHidden = false
        textField.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        textField.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        errorLabel.text = textError
    }
    
}

extension ProfileTableViewCell:UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField.text = "\(gender[row])"
    }
}
