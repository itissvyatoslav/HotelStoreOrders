//
//  OrderPageViewController.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit

class OrderPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var orderNumber = 0
    let model = DataModel.sharedData
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hotelNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        setShadow()
    }
    
    private func setLabels(){
        orderLabel.addCharacterSpacing(kernValue: 1.05)
        numberLabel.addCharacterSpacing(kernValue: 1.05)
        dateLabel.addCharacterSpacing(kernValue: 1.05)
        timeLabel.addCharacterSpacing(kernValue: 1.05)
        hotelNameLabel.addCharacterSpacing(kernValue: 1.05)
        numberLabel.text = "#\(model.orders[orderNumber].number)"
        dateLabel.text = model.orders[orderNumber].date
        timeLabel.text = model.orders[orderNumber].time
        hotelNameLabel.text = model.hotelName
        nameLabel.adjustsFontSizeToFitWidth = true
        roomLabel.adjustsFontSizeToFitWidth = true
        commentLabel.adjustsFontSizeToFitWidth = true
        nameLabel.text = model.orders[orderNumber].userName
        roomLabel.text = model.orders[orderNumber].roomNumber
        commentLabel.text = model.orders[orderNumber].comment
        if model.orders[orderNumber].status == "New" {
            statusLabel.textColor = UIColor(red: 182/255, green: 9/255, blue: 73/255, alpha: 1)
        }
        statusLabel.text = model.orders[orderNumber].status
    }
    
    private func setShadow(){
        buttonView.layer.cornerRadius = 17
        buttonView.layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        buttonView.layer.shadowOpacity = 1
        buttonView.layer.shadowOffset = .zero
        buttonView.layer.shadowRadius = 20
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
     //MARK:- UIPICKERVIEW
    
    let pickerData = ["New", "Processing", "Finished", "Canceled", "Canceled by buyer"]
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    
    @IBAction func statusTapped(_ sender: Any) {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        model.orders[orderNumber].status = pickerData[row]
        if model.orders[orderNumber].status == "New" {
            statusLabel.textColor = UIColor(red: 182/255, green: 9/255, blue: 73/255, alpha: 1)
        } else {
            statusLabel.textColor = UIColor.black
        }
        statusLabel.text = model.orders[orderNumber].status
    }
}
