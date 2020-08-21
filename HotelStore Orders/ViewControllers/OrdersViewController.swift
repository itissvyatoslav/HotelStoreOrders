//
//  OrdersViewController.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let model = DataModel.sharedData
    var tableData = [DataModel.orderStruct]()
    var selectedHotelInPicker = ""
    var isPickerChanged = false
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var hotelButton: UIButton!
    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var ordersLabel: UILabel!
    @IBOutlet weak var hotelNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        orderTable.reloadData()
    }
    
    override func viewDidLoad() {
        NetworkService().getOrders()
        super.viewDidLoad()
        setLabels()
        setConstraints()
        registerTableViewCells()
        model.editedOrders = model.orders
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setLabels(){
        ordersLabel.addCharacterSpacing(kernValue: 1.05)
        hotelNameLabel.addCharacterSpacing(kernValue: 1.05)
        if model.access == "admin" {
            hotelNameLabel.text = "All hotels"
        } else {
            hotelNameLabel.text = model.hotelName
            hotelButton.isHidden = true
        }
        
    }
    
    private func registerTableViewCells() {
        orderTable.delegate = self
        orderTable.dataSource = self
        let orderCell = UINib(nibName: "OrderCell",
                                  bundle: nil)
        self.orderTable.register(orderCell,
                                forCellReuseIdentifier: "OrderCell")
        orderTable.rowHeight = UITableView.automaticDimension
        orderTable.tableFooterView = UIView(frame: .zero)
    }
    
    //MARK:- CONSTRAINTS
    
    @IBOutlet weak var cons1: NSLayoutConstraint!
    @IBOutlet weak var cons2: NSLayoutConstraint!
    @IBOutlet weak var cons3: NSLayoutConstraint!
    @IBOutlet weak var cons4: NSLayoutConstraint!
    @IBOutlet weak var cons5: NSLayoutConstraint!
    
    private func setConstraints(){
        cons1.constant = self.view.frame.width * 0.06
        cons2.constant = self.view.frame.width * 0.08
        cons3.constant = self.view.frame.width * 0.1
        cons4.constant = self.view.frame.width * 0.1
        cons5.constant = self.view.frame.width * 0.09
    }
    
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var hotelPicker = [String]()
    
    @IBAction func hotelAction(_ sender: Any) {
        hotelPicker = model.hotels
        var picker2  = UIPickerView()
        picker2 = UIPickerView.init()
        picker2.delegate = self
        picker2.dataSource = self
        picker2.backgroundColor = UIColor.white
        picker2.setValue(UIColor.black, forKey: "textColor")
        picker2.autoresizingMask = .flexibleWidth
        picker2.contentMode = .center
        picker2.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        picker = picker2
        self.view.addSubview(picker)
        
        var toolBar2 = UIToolbar()
        toolBar2 = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar2.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        toolBar = toolBar2
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        if !isPickerChanged {
            selectedHotelInPicker = ""
            hotelNameLabel.text = "All hotels"
        }
        if selectedHotelInPicker == "" {
            model.editedOrders = model.orders
        } else {
            model.editedOrders.removeAll()
            for order in model.orders {
                if order.hotelName == selectedHotelInPicker{
                    model.editedOrders.append(order)
                }
            }
        }
        orderTable.reloadData()
        isPickerChanged = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hotelPicker.count + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "All"
        } else {
            return hotelPicker[row - 1]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        isPickerChanged = true
        if row == 0 {
            hotelNameLabel.text = "All hotels"
            selectedHotelInPicker = ""
        } else {
            hotelNameLabel.text = hotelPicker[row - 1]
            selectedHotelInPicker = hotelPicker[row - 1]
        }
        
    }
}

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.editedOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as? OrderCell {
            cell.dataLabel.text = model.editedOrders[indexPath.row].date
            cell.numberLabel.text = "\( model.editedOrders[indexPath.row].number)"
            cell.timeLabel.text = model.editedOrders[indexPath.row].time
            cell.roomLabel.text = model.editedOrders[indexPath.row].roomNumber
            cell.statusLabel.text = model.editedOrders[indexPath.row].status
            cell.dataLabel.adjustsFontSizeToFitWidth = true
            cell.numberLabel.adjustsFontSizeToFitWidth = true
            cell.timeLabel.adjustsFontSizeToFitWidth = true
            cell.roomLabel.adjustsFontSizeToFitWidth = true
            cell.statusLabel.adjustsFontSizeToFitWidth = true
            cell.cons2.constant = self.view.frame.width * 0.07
            cell.cons3.constant = self.view.frame.width * 0.06
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 13.0, *) {
            let vc = storyboard?.instantiateViewController(identifier: "OrderPageViewController") as! OrderPageViewController
            vc.orderNumber = indexPath.item
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
