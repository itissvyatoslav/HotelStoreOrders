//
//  OrdersViewController.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController{
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var ordersLabel: UILabel!
    @IBOutlet weak var hotelNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        orderTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        setConstraints()
        registerTableViewCells()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    let model = DataModel.sharedData
    
    private func setLabels(){
        ordersLabel.addCharacterSpacing(kernValue: 1.05)
        hotelNameLabel.addCharacterSpacing(kernValue: 1.05)
        hotelNameLabel.text = model.hotelName
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
}

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as? OrderCell {
            cell.dataLabel.text = model.orders[indexPath.row].date
            cell.numberLabel.text = model.orders[indexPath.row].number
            cell.timeLabel.text = model.orders[indexPath.row].time
            cell.roomLabel.text = model.orders[indexPath.row].roomNumber
            cell.statusLabel.text = model.orders[indexPath.row].status
            cell.cons1.constant = self.view.frame.width * 0.06
            cell.cons2.constant = self.view.frame.width * 0.07
            cell.cons3.constant = self.view.frame.width * 0.06
            cell.cons4.constant = self.view.frame.width * 0.114
            cell.cons5.constant = self.view.frame.width * 0.163
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
