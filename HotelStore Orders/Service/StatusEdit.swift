//
//  StatusEdit.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 14.09.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import SocketIO

class StatusEdit {
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    func makeConnection(){
        let manager = SocketManager(socketURL: URL(string: "https://crm.hotelstore.sg/api/order")!, config: [.log(true), .compress])
        let socket = manager.defaultSocket

        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }

        socket.on("currentAmount") {data, ack in
            guard let cur = data[0] as? Double else { return }
            
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                socket.emit("update", ["amount": cur + 2.50])
            }

            ack.with("Got your currentAmount", "dude")
        }

        socket.connect()
    }
}





