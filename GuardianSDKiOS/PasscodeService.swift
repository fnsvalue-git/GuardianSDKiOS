//
//  PasscodeService.swift
//  GuardianSDKiOS
//
//  Created by elite on 2021/04/23.
//  Copyright © 2021 fns_mac_pro. All rights reserved.
//

import Foundation
import LocalAuthentication

open class PasscodeService {
    
    public static let sharedInstance = PasscodeService()
    
    public init() {}
    
    // passcodeAuthentication
    public func passcodeAuthentication(reason: String = "Input your passcode to authenticate") -> Bool {
        //        let reason = "Input your passcode to authenticate"
        
        let secAccessControlbject: SecAccessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .devicePasscode,
            nil
        )!
        let dataToStore = "AnyData".data(using: .utf8)!
        
        
        let insertQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessControl: secAccessControlbject,
            kSecAttrService: "PasscodeAuthentication",
            kSecValueData: dataToStore as Any,
        ]
        
        let insertStatus = SecItemAdd(insertQuery as CFDictionary, nil)
        //        print(insertStatus)
        //        if insertStatus == 0 {
        //            SecItemDelete(insertQuery)
        //            print("Has passcode")
        //        }else{
        //            print("No Passcode")
        //        }
        
        
        let query: NSDictionary = [
            kSecClass:  kSecClassGenericPassword,
            kSecAttrService  : "PasscodeAuthentication",
            kSecUseOperationPrompt : reason
        ]
        
        var typeRef : CFTypeRef?
        
        let status: OSStatus = SecItemCopyMatching(query, &typeRef) //This will prompt the passcode.
        
        // Check authentication status
        if (status == errSecSuccess)
        {
            //            print("Authentication Succeeded")
            return  true
        } else {
            //            print("Authentication failed")
            return false
        }
    }
    
    public func deviceHasPasscode() -> Bool {
        let secret = "Device has passcode set?".data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        let attributes = [kSecClass as String:kSecClassGenericPassword, kSecAttrService as String:"LocalDeviceServices", kSecAttrAccount as String:"NoAccount", kSecValueData as String:secret!, kSecAttrAccessible as String:kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly] as [String : Any]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        //        print(status)
        if status == 0 {
            SecItemDelete(attributes as CFDictionary)
            //            print("Has passcode")
            return true
        }
        //        print("No Passcode")
        return false
    }
    
    // Same task as the function above, but using different method
    public func deviceHasPasscodeUsingLAContext() -> Bool {
        let myContext = LAContext()
        var authError: NSError? = nil
        if (myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError)){
            //            print("Has passcode")
            return true
        }else{
            //            print("No Passcode")
            return false
        }
    }
}
