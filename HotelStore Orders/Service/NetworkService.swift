//
//  NetworkService.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 19.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import Foundation

class NetworkService {
    let model = DataModel.sharedData
    
    var urlMain = "https://crm.hotelstore.sg/"

    struct loginStruct: Codable {
        var data: dataStruct
        var message: String?
        var success: Bool
    }
    
    struct dataStruct: Codable {
        var token: String
        var id: Int
        var access: String
    }
    
    func login(login: String, password: String) -> Bool {

        var success: Bool = false
        let semaphore = DispatchSemaphore (value: 0)
        guard let url = URL(string: "\(urlMain)api/login") else {
            print("url error")
            return false
        }
        let parametrs = ["login": login, "password": password]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("iOS", forHTTPHeaderField: "user-agent")
        
        let config = URLSessionConfiguration.default
        let additionalHeaders = [
            "Accept": "application/json",
            "cache-control": "no-cache"
        ]
        config.httpAdditionalHeaders = additionalHeaders
        
        let postString = parametrs.compactMap{(key, value) -> String in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)

        let session = URLSession.init(configuration: config)
        session.dataTask(with: request){(data, response, error)  in
            guard let data = data else {
                print("data error")
                return
            }
            do {
                let json = try JSONDecoder().decode(loginStruct.self, from: data)
                self.model.token = json.data.token
                self.model.idProfile = json.data.id
                self.model.access = json.data.access
                success = json.success
            } catch {
                print(error)
            }
            semaphore.signal()
        }.resume()
        semaphore.wait()
        return success
    }
    
    func getOrders(){
        
        struct orderStruct: Codable {
            var data: [dataStruct]
            var message: String?
            var success: Bool
            var total: Int
        }
        
        struct dataStruct: Codable {
            var cart: [cartStruct]
            var comment: String?
            var customer: customerStruct
            var date: String
            var hotel: hotelStruct
            var id: Int
            var manager: managerStruct?
            var position: Int
            var room: String
            var status: String
            var time: String
        }
        
        struct cartStruct: Codable {
            var id: Int?
            var order: Int
            var product: productStruct
            var quantity: Int
        }
        
        struct productStruct: Codable {
            var brand: String
            var category: String?
            var category_id: Int?
            var description: String?
            var id: Int?
            var images: [imageStruct]?
            var price: Double
            var quantity: Int?
            var short_description: String?
            var title: String
        }
        
        struct imageStruct: Codable {
            var front: Bool
            var url: String
        }
        
        struct customerStruct: Codable {
            var count_orders: Int?
            var first_name: String
            var id: Int?
            var last_name: String?
        }
        
        struct hotelStruct: Codable {
            var address: String?
            var id: Int?
            var name: String
        }
        
        struct managerStruct: Codable {
            var id: Int
            var name: String
        }
        
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: "\(urlMain)api/order")!,timeoutInterval: Double.infinity)
        
        request.httpMethod = "GET"
        request.addValue(model.token, forHTTPHeaderField: "token")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do {
                let json = try JSONDecoder().decode(orderStruct.self, from: data)
                self.model.orders.removeAll()
                for number in 0..<json.data.count {
                    self.model.addOrder.comment = json.data[number].comment
                    self.model.addOrder.number = json.data[number].position
                    self.model.addOrder.date = json.data[number].date
                    self.model.addOrder.time = json.data[number].time
                    self.model.addOrder.userName = json.data[number].customer.first_name
                    self.model.addOrder.roomNumber = json.data[number].room
                    self.model.addOrder.status = json.data[number].status
                    self.model.addOrder.hotelName = json.data[number].hotel.name
                    if !self.model.hotels.contains(json.data[number].hotel.name) {
                        print(json.data[number].position)
                        self.model.hotels.append(json.data[number].hotel.name)
                    }
                    self.model.addOrder.products.removeAll()
                    for subNumber in 0..<json.data[number].cart.count {
                        self.model.addProduct.brand = json.data[number].cart[subNumber].product.brand
                        self.model.addProduct.title = json.data[number].cart[subNumber].product.title
                        self.model.addProduct.QTY = json.data[number].cart[subNumber].quantity
                        self.model.addProduct.price = json.data[number].cart[subNumber].product.price
                        self.model.addOrder.products.append(self.model.addProduct)
                    }
                    self.model.orders.append(self.model.addOrder)
                }
                self.model.hotelName = json.data[0].hotel.name
            } catch {
                print(error)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
}
