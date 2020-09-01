//
//  DataModel.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import Foundation

class DataModel {
    static let sharedData = DataModel()
    
    var token = "default token"
    var hotelName = "Hotel"
    var idProfile = 0
    var access = ""
    
    struct orderStruct {
        var id: Int
        var number: Int
        var date: String
        var time: String
        var userName: String
        var roomNumber: String
        var comment: String?
        var status: String
        var products: [productStruct]
        var hotelName: String
    }
    
    struct productStruct {
        var brand: String
        var title: String
        var QTY: Int
        var price: Double
    }
    
    var addProduct = productStruct(brand: "", title: "", QTY: 0, price: 0)
    var addOrder = orderStruct(id: 0, number: 0, date: "", time: "", userName: "", roomNumber: "", comment: "", status: "", products: [], hotelName: "")
    var orders = [orderStruct]()
    var editedOrders = [orderStruct]()
    var hotels = [String]()
}
