//
//  OrdersViewController.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit
import SocketIO

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
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        orderTable.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        NetworkService().regPushes(device_token: model.device_token)
        if model.orders.isEmpty {
            NetworkService().getOrders()
        }
        super.viewDidLoad()
        socketManager()
        setLabels()
        setConstraints()
        registerTableViewCells()
        model.editedOrders = model.orders
        self.navigationController?.navigationBar.tintColor = UIColor(named: "subTextColor")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        logoutButton.tintColor = UIColor(named: "subTextColor")
    }
    
    private func registerTableViewCells() {
        refreshControl.tintColor = UIColor(red:182/255, green:9/255, blue:73/255, alpha:1.0)
        orderTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateOrders(_:)), for: .valueChanged)
        orderTable.delegate = self
        orderTable.dataSource = self
        let orderCell = UINib(nibName: "OrderCell",
                              bundle: nil)
        self.orderTable.register(orderCell,
                                forCellReuseIdentifier: "OrderCell")
        orderTable.rowHeight = UITableView.automaticDimension
        orderTable.tableFooterView = UIView(frame: .zero)
    }
    
    @objc private func updateOrders(_ sender: Any) {
        if NetworkService().getOrders() {
            model.editedOrders = model.orders
            orderTable.reloadData()
            if model.access == "admin" {
                hotelNameLabel.text = "All hotels"
            }
        }
        self.refreshControl.endRefreshing()
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
        pickerView.isHidden = true
        backgroundView.isHidden = true
    }
    
    
    //MARK:- Picker
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBAction func hotelButton(_ sender: Any) {
        backgroundView.isHidden = false
        pickerView.layer.cornerRadius = 25
        pickerView.isHidden = false
        picker.delegate = self
        picker.dataSource = self
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
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
        pickerView.isHidden = true
        backgroundView.isHidden = true
        orderTable.reloadData()
        isPickerChanged = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model.hotels.count + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "All"
        } else {
            return model.hotels[row - 1]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        isPickerChanged = true
        if row == 0 {
            hotelNameLabel.text = "All hotels"
            selectedHotelInPicker = ""
        } else {
            hotelNameLabel.text = model.hotels[row - 1]
            selectedHotelInPicker = model.hotels[row - 1]
        }
        
    }
    
    @IBAction func moreTapped(_ sender: Any) {
        alertLogout()
    }
    
    //MARK:- Socket
    
    var manager:SocketManager!
    var socketIOClient: SocketIOClient!
    
    func socketManager(){
        
        struct orderStruct: Codable {
            var comment: String?
            var goods_list: [String]?
            var message: String
            var order_id: Int
            var order_position: Int
            var room_number: String
            var status_update: String
        }
        
        manager = SocketManager(socketURL: URL(string: "https://crm.hotelstore.sg")!, config: [.log(true), .compress])
        socketIOClient = manager.socket(forNamespace: "/notifs")
        
        socketIOClient.on(clientEvent: .connect) {data, ack in
            //print(data)
            self.socketIOClient.emit("join", self.model.token)
            print("socket connected")
        }
        
        socketIOClient.on("NewStatus") {data, ack in
            print("Status:")
            print(data)
            //do {
            //    let json = try JSONDecoder().decode(orderStruct.self, from: data)
            //} catch {
            //
            //}
        }
        
        socketIOClient.on("newOrder") {data, ack in
            print("New order:")
            print(data)
        }
        
        socketIOClient.on(clientEvent: .error) { (data, eck) in
            print(data)
            print("socket error")
        }
        
        socketIOClient.on(clientEvent: .disconnect) { (data, eck) in
            print(data)
            print("socket disconnect")
        }
        
        socketIOClient.on(clientEvent: SocketClientEvent.reconnect) { (data, eck) in
            print(data)
            print("socket reconnect")
        }
        
        socketIOClient.connect()
    }
    
    //MARK:- UPDATE TABLE
    
    private let refreshControl = UIRefreshControl()
    
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
