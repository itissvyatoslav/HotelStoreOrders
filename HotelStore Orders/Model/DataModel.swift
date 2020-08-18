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
    
    var token = ""
    var hotelName = "1 Fullerton Square"
    
    struct orderStruct {
        var number: String
        var date: String
        var time: String
        var userName: String
        var roomNumber: String
        var comment: String?
        var status: String
        var products: [productStruct]
    }
    
    struct productStruct {
        var brand: String
        var title: String
        var QTY: Int
        var price: Double
    }
    
    var addOrder = orderStruct(number: "", date: "", time: "", userName: "", roomNumber: "", comment: "", status: "", products: [])
    var orders = [orderStruct(number: "23", date: "4/03/20", time: "13:15", userName: "Stas", roomNumber: "201", comment: "After 14:00", status: "New", products: [productStruct(brand: "Oral-B", title: "Electric toothbrush Vitality 3D White", QTY: 1, price: 49), productStruct(brand: "Xiaomi", title: "LeFan massage sleep neck pillow, grey", QTY: 1, price: 30)]), orderStruct(number: "22", date: "4/03/20", time: "12:48", userName: "Polina", roomNumber: "324", comment: "Before 14:00", status: "Is being shipping", products: [productStruct(brand: "Samsung", title: "Samsung Galaxy Note 20 Max Ultra Super Fast Charge and Very very very cheap", QTY: 1, price: 102), productStruct(brand: "Brand", title: "AirPods Pro Max Ultra Super Fast Charge and Very very very cheap", QTY: 1, price: 12.3), productStruct(brand: "brand", title: "title", QTY: 1, price: 1)])]
}
