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
    
    var tableData = [DataModel.orderStruct]()
    
    //MARK:- OUTLETS
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hotelNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var productsTable: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    
    
    override func viewWillAppear(_ animated: Bool) {
        productsTable.estimatedRowHeight = 200
        productsTable.rowHeight = UITableView.automaticDimension
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        setLabels()
        setConstraints()
        setShadow()
        saveButton.layer.cornerRadius = 22.5
        let distance = saveButton.frame.minY - view.frame.minY
        print(distance)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: distance + 50)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "ORDER"
        
        scrollHeight.constant = distance - 1000
    }
    
    private func registerTableViewCells() {
        productsTable.delegate = self
        productsTable.dataSource = self
        let orderCell = UINib(nibName: "ProductCell",
                                  bundle: nil)
        self.productsTable.register(orderCell,
                                forCellReuseIdentifier: "ProductCell")
        productsTable.rowHeight = UITableView.automaticDimension
        productsTable.tableFooterView = UIView(frame: .zero)
        
        tableHeight.constant = self.productsTable.contentSize.height * CGFloat(model.orders[orderNumber].products.count) + 15
    }
    
    private func setLabels(){
        numberLabel.addCharacterSpacing(kernValue: 1.05)
        dateLabel.addCharacterSpacing(kernValue: 1.05)
        timeLabel.addCharacterSpacing(kernValue: 1.05)
        hotelNameLabel.addCharacterSpacing(kernValue: 1.05)
        numberLabel.text = "#\(model.editedOrders[orderNumber].number)"
        dateLabel.text = model.editedOrders[orderNumber].date
        timeLabel.text = model.editedOrders[orderNumber].time
        hotelNameLabel.text = model.editedOrders[orderNumber].hotelName
        nameLabel.adjustsFontSizeToFitWidth = true
        roomLabel.adjustsFontSizeToFitWidth = true
        commentLabel.adjustsFontSizeToFitWidth = true
        nameLabel.text = model.editedOrders[orderNumber].userName
        roomLabel.text = model.editedOrders[orderNumber].roomNumber
        commentLabel.text = model.editedOrders[orderNumber].comment
        if model.editedOrders[orderNumber].status == "New" {
            statusLabel.textColor = UIColor(red: 182/255, green: 9/255, blue: 73/255, alpha: 1)
        }
        statusLabel.text = model.editedOrders[orderNumber].status
        setPrice()
    }
    
    private func setPrice(){
        var totalPrice: Double = 0
        for product in model.editedOrders[orderNumber].products{
            totalPrice = totalPrice + product.price * Double(product.QTY)
        }
        totalPriceLabel.text =  "\(totalPrice)"
    }
    
    private func setShadow(){
        buttonView.layer.cornerRadius = 17
        buttonView.layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        buttonView.layer.shadowOpacity = 1
        buttonView.layer.shadowOffset = .zero
        buttonView.layer.shadowRadius = 20
    }
    
     //MARK:- UIPICKERVIEW
    
    var isPickerChanged = false
    
    let pickerData = ["New", "Processing", "Finished", "Canceled", "Canceled by buyer"]
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    
    //MARK: - SAVE
    @IBAction func saveTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        model.editedOrders[orderNumber].status = statusLabel.text ?? ""
        var index = 0
        for order in model.orders {
            if order.number == model.editedOrders[orderNumber].number {
                model.orders[index].status = model.editedOrders[orderNumber].status
                break
            }
            index = index + 1
        }
        NetworkService().changeStatus2(id: model.orders[orderNumber].id, status: model.orders[index].status, manager_id: model.orders[orderNumber].manager_id)
    }
    

    
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
        if !isPickerChanged {
            statusLabel.textColor = UIColor(red: 182/255, green: 9/255, blue: 73/255, alpha: 1)
            statusLabel.text = "New"
        }
        isPickerChanged = false
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
        statusLabel.text = pickerData[row]
        if statusLabel.text == "New" {
            statusLabel.textColor = UIColor(red: 182/255, green: 9/255, blue: 73/255, alpha: 1)
        } else {
            statusLabel.textColor = UIColor.black
        }
        isPickerChanged = true
        statusLabel.text = pickerData[row]
    }
    
    //MARK:- CONSTRAINTS
    
    @IBOutlet weak var const1: NSLayoutConstraint!
    @IBOutlet weak var const2: NSLayoutConstraint!
    @IBOutlet weak var const3: NSLayoutConstraint!
    @IBOutlet weak var const4: NSLayoutConstraint!
    
    private func setConstraints(){
        const1.constant = self.view.frame.width * 0.107
        const2.constant = self.view.frame.width * 0.114
        const3.constant = self.view.frame.width * 0.226
        const4.constant = self.view.frame.width * 0.077
    }
}

extension OrderPageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.editedOrders[orderNumber].products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as? ProductCell {
            cell.numberLabel.text = "\(indexPath.row + 1)"
            cell.brandLabel.text = model.editedOrders[orderNumber].products[indexPath.row].brand
            cell.titleLabel.text = model.editedOrders[orderNumber].products[indexPath.row].title
            cell.qtyLabel.text = "\(model.editedOrders[orderNumber].products[indexPath.row].QTY)"
            cell.priceLabel.text = "\(model.editedOrders[orderNumber].products[indexPath.row].price)"
            cell.lengthDescr.constant = self.view.frame.width * 0.3
            cell.lengthBrand.constant = self.view.frame.width * 0.1313
            cell.lengthPrice.constant = self.view.frame.width * 0.07
            cell.titleLabel.adjustsFontSizeToFitWidth = true
            cell.brandLabel.adjustsFontSizeToFitWidth = true
            cell.priceLabel.adjustsFontSizeToFitWidth = true
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    private func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
