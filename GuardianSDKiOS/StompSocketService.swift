//
//  StompSocketService.swift
//  GuardianSDKiOS
//
//  Created by Jayhy on 08/09/2020.
//  Copyright © 2020 fns_mac_pro. All rights reserved.
//

import Foundation
import StompClientLib

public class StompSocketService : StompClientLibDelegate {
    
    public static let sharedInstance = StompSocketService()
    
    public var socketClient = StompClientLib()
    
    public var _connectCallback : (Bool) -> Void
    public var _authProcessCallback : (String?) -> Void
    
    private init() {
        func initProcess(status : String?) -> Void{}
        func initConnectCallback(result : Bool) -> Void{}
        self._authProcessCallback = initProcess
        self._connectCallback = initConnectCallback
    }
    
    public func connect(dataMap : Dictionary<String, String>, connectCallback : @escaping(Bool) -> Void){
        self.socketClient = StompClientLib()
        let socketUrl : String = getWebSocketUrl(dataMap : dataMap) ?? ""
        print(socketUrl)
        let url = NSURL(string: socketUrl)!
        self.socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL) , delegate: self)
        self._connectCallback = connectCallback
    }
    
    public func isConnect() -> Bool {
        var result : Bool = false
        if self.socketClient.isConnected() {
            result = true
        }
        return result
    }
    
    public func subscribe(authProcessCallback : @escaping(String?) -> Void) {
        self._authProcessCallback = authProcessCallback
    }
    
    public func disconnect() {
        self.socketClient.unsubscribe(destination: "/user/queue")
        self.socketClient.disconnect()
    }
    
    private func getWebSocketUrl(dataMap : Dictionary<String, String>) -> String {
        var result : String
        let replaceUrl = getBaseUrlToWebSocketUrl()
        
        if dataMap["clientKey"] != nil {
            result = "\(replaceUrl)/ws/v3/app/websocket?clientKey=\(dataMap["clientKey"]!)&deviceId=\(dataMap["deviceId"]!)&channelKey=\(dataMap["channelKey"]!)"
        } else {
            result = "\(replaceUrl)/ws/v3/app/websocket?os=\(dataMap["os"]!)&appPackage=\(dataMap["packageName"]!)&deviceId=\(dataMap["deviceId"]!)&channelKey=\(dataMap["channelKey"]!)"
        }
        return result
    }
    
    private func getBaseUrlToWebSocketUrl() -> String {
        var replaceUrl : String = ""
        var baseUrl = GuardianService.sharedInstance.getBaseUrl()
        if baseUrl.range(of: "http://") != nil {
            replaceUrl = baseUrl.replacingOccurrences(of: "http://", with: "ws://") ?? ""
        } else if baseUrl.range(of: "https://") != nil {
            replaceUrl = baseUrl.replacingOccurrences(of: "https://", with: "wss://") ?? ""
        }
        return replaceUrl
    }
    
    public func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?,
                            akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("Destination : \(destination)")
        print("JSON Body : \(String(describing: jsonBody))")
        print("String Body : \(stringBody ?? "nil")")
        
        do {
            let strStringBody = stringBody ?? ""
            let data = strStringBody.data(using: .utf8)!
            if let authStatusObject = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, String>
            {
                self._authProcessCallback(authStatusObject["status"])
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func stompClientDidConnect(client: StompClientLib!) {
        print("Socket is connected")
        self.socketClient.subscribe(destination: "/user/queue")
        self._connectCallback(true)
    }
    
    public func stompClientDidDisconnect(client: StompClientLib!) {
        print("Socket is Disconnected")
        self._connectCallback(false)
    }

    public func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String){
        print("Receipt : \(receiptId)")
    }

    public func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("Error Send : \(String(describing: message))")
    }

    public func serverDidSendPing() {
        print("Server ping")
    }

}
