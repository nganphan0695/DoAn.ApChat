//
//  Network.swift
//  Takenoko
//
//  Created by Ngân Phan on 11/11/2023.
//

import Foundation
import Network

class Network{
    static let shared = Network()
    let monitor = NWPathMonitor()
    var isConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
                Network.shared.isConnected = true
            } else {
                print("No connection!")
                Network.shared.isConnected = false
            }
        }
    }
    
    func start(){
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
