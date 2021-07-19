//
//  TOTP.swift
//  GuardianSDKiOS
//
//  Created by elite on 2021/07/05.
//  Copyright © 2021 fns_mac_pro. All rights reserved.
//

import Foundation
import SwiftOTP

public class TotpService {
    public static let sharedInstance = TotpService()
    
    
    public init() {}
    
    //MARK: - generateTOTP return
    /// Return 6 digits of TOTP number
    /// - Parameter secretKey: secret string, which will be use to generate TOTP
    /// - Returns: `TOTP number`
    public func generateTOTP(with secretKey: String) -> String{
        let decodedData: Data? = base32DecodeToData(secretKey)
        if let data = decodedData {
            let date : Date = Date()
            
            if let totp = TOTP(secret: data, timeInterval: 60, algorithm: .sha1) {
                let result = totp.generate(time: date)
                if let otpString = result {
                    return otpString
                }
                return "Fail to make otp"
            }
        }
        return "Fail to make data"
    }
    
    //MARK: - generateTOTP Callback
    /// Get TOTP Number via callback function
    /// - Parameters:
    ///   - secretKey: secret string, which will be use to generate TOTP
    ///   - onSuccess: get TOTP number as String value via a callback
    ///   - onFailed: get error message
    public func generateTOTP(with secretKey: String, onSuccess: @escaping(String)-> Void, onFailed: @escaping(String)-> Void){
        let decodedData: Data? = base32DecodeToData(secretKey)
        
        if let data = decodedData {
            let date : Date = Date()
            
            if let totp = TOTP(secret: data, timeInterval: 60, algorithm: .sha1) {
                let result = totp.generate(time: date)
                
                if let otpString = result {
                    onSuccess(otpString)
                } else {
                    onFailed("OTP Generation Error")
                }
            } else {
                onFailed("TOTP Setup error")
            }
        } else {
            onFailed("Data Ecoding Error")
        }
    }
}

