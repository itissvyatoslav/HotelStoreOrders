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
    var urlTest = "http://176.119.157.195:8080/"

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
                let json1 = try JSONSerialization.jsonObject(with: data, options: [])
                print(json1)
                
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
    
    func getOrders() -> Bool {
        
        struct orderStruct: Codable {
            var data: [dataStruct]?
            var message: String?
            var success: Bool
            var total: Int?
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
        
        struct cartStruct2: Codable {
            var id: Int?
            var order: Int
            var product: productStruct2
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
        
        struct productStruct2: Codable {
            var id: Int
            var message: String
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
        
        var success = false
        
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: "\(urlMain)api/order?page=1")!,timeoutInterval: Double.infinity)
        
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
                if !(json.data?.isEmpty ?? true) {
                    for number in 0..<json.data!.count {
                        self.model.addOrder.manager_id = json.data![number].manager?.id ?? -1
                        self.model.addOrder.id = json.data![number].id
                        self.model.addOrder.comment = json.data![number].comment
                        self.model.addOrder.number = json.data![number].position
                        self.model.addOrder.date = json.data![number].date
                        self.model.addOrder.time = json.data![number].time
                        self.model.addOrder.userName = json.data![number].customer.first_name
                        self.model.addOrder.roomNumber = json.data![number].room
                        self.model.addOrder.status = json.data![number].status
                        self.model.addOrder.hotelName = json.data![number].hotel.name
                        if !self.model.hotels.contains(json.data![number].hotel.name) {
                            self.model.hotels.append(json.data![number].hotel.name)
                        }
                        self.model.addOrder.products.removeAll()
                        for subNumber in 0..<json.data![number].cart.count {
                            self.model.addProduct.brand = json.data![number].cart[subNumber].product.brand
                            self.model.addProduct.title = json.data![number].cart[subNumber].product.title
                            self.model.addProduct.QTY = json.data![number].cart[subNumber].quantity
                            self.model.addProduct.price = json.data![number].cart[subNumber].product.price
                            self.model.addOrder.products.append(self.model.addProduct)
                        }
                        self.model.orders.append(self.model.addOrder)
                    }
                    
                    self.model.hotelName = json.data![0].hotel.name
                }
                success = json.success
            } catch {
                print(error)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return success
    }
    
    func regPushes(device_token: String) {

        let semaphore = DispatchSemaphore (value: 0)
        guard let url = URL(string: "\(urlMain)api/checkdevice") else {
            print("url error")
            return
        }
        let parametrs = ["device_id": device_token, "device_os": "iOS"]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(model.token, forHTTPHeaderField: "token")
        
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
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
            semaphore.signal()
        }.resume()
        print("Send")
        semaphore.wait()
    }
    
    func changeStatus(id: Int, status: String){
        let semaphore = DispatchSemaphore (value: 0)
        guard let url = URL(string: "\(urlMain)api/order") else {
            print("url error")
            return
        }
        let parametrs = ["id": "\(id)", "status": status]
        print(id, status)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(model.token, forHTTPHeaderField: "token")
        
        let config = URLSessionConfiguration.default
        let additionalHeaders = [
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
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
            semaphore.signal()
        }.resume()
        semaphore.wait()
    }
    
    func changeStatus2(id: Int, status: String, manager_id: Int) {
        var semaphore = DispatchSemaphore (value: 0)

        let parameters = [
            [
                "key": "id",
                "value": "\(id)",
                "type": "text"
            ],
            [
                "key": "status",
                "value": status,
                "type": "text"
            ],
            [
                "key": "manager_id",
                "value": "\(manager_id)",
                "type": "text"
            ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        var error: Error? = nil
        print(parameters)
        for param in parameters {
          if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            let paramType = param["type"] as! String
            if paramType == "text" {
              let paramValue = param["value"] as! String
              body += "\r\n\r\n\(paramValue)\r\n"
            } else {
              let paramSrc = param["src"] as! String
              let fileData = try? NSData(contentsOfFile:paramSrc, options:[]) as Data
              let fileContent = String(data: fileData!, encoding: .utf8)!
              body += "; filename=\"\(paramSrc)\"\r\n"
                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            }
          }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://crm.hotelstore.sg/api/order")!,timeoutInterval: Double.infinity)
        request.addValue(model.token, forHTTPHeaderField: "token")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "PUT"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
    func logout(){
        let semaphore = DispatchSemaphore (value: 0)
        guard let url = URL(string: "\(urlMain)api/logout") else {
            print("url error")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(model.token, forHTTPHeaderField: "token")
        
        let config = URLSessionConfiguration.default
        let additionalHeaders = [
            "Accept": "application/json",
            "cache-control": "no-cache"
        ]
        config.httpAdditionalHeaders = additionalHeaders

        let session = URLSession.init(configuration: config)
        session.dataTask(with: request){(data, response, error)  in
            guard let data = data else {
                print("data error")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
            semaphore.signal()
        }.resume()
        semaphore.wait()
    }
}
