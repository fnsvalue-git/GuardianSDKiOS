//
//  PasscodeService.swift
//  GuardianSDKiOS
//
//  Created by elite on 2021/04/23.
//  Copyright © 2021 fns_mac_pro. All rights reserved.
//

import Foundation
import LocalAuthentication

public class PasscodeService {
    
    public static let sharedInstance = PasscodeService()
    
    public init() {}
    
    // createKeyChainItem
    public func createKeychainItem() -> Bool {
         let stringData = "string data"
         let theData = stringData.data(using: .utf8)
         let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAlways, .devicePasscode, nil)
         let query = [
              kSecClass as String : kSecClassGenericPassword as String,
              kSecAttrAccessControl as String : accessControl,
              kSecAttrAccount as String : "myAccount",
              kSecAttrService as String : "myService",
              kSecValueData as String : theData!
         ] as [String: Any]

         let status = SecItemAdd(query as CFDictionary, nil)
         if status == noErr || status == errSecDuplicateItem {
              print("successfully added passcode-protected item to keychain")
         }
         return status == noErr || status == errSecDuplicateItem
    }
    
    // passcodeAuthentication
    public func passcodeAuthentication(reason: String = "Input your passcode to authenticate") -> Bool {
        
        //        print("In passcodeAuthentication")
        
        var success = createKeychainItem()
             if success {
//                  var dataTypeRef:AnyObject?
                  let retrieveQuery: NSDictionary = [
                       kSecClass as String : kSecClassGenericPassword as String,
                       kSecAttrAccount as String : "myAccount",
                       kSecAttrService as String : "myService",
                    kSecReturnData as String : kCFBooleanTrue,
                       kSecMatchLimit as String : kSecMatchLimitOne,
                    kSecUseOperationPrompt as String : reason
                  ] as NSDictionary
                  let status = SecItemCopyMatching(retrieveQuery as CFDictionary, nil)
                  success = (status == errSecSuccess)
//                print("=== \(success) ===")
                  if status == errSecUserCanceled {
                       print("user canceled authentication")
                  }
             }
             return success
        
        
        //
        
//        let secAccessControlObject: SecAccessControl = SecAccessControlCreateWithFlags(
//            kCFAllocatorDefault,
//            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
//            .devicePasscode,
//            nil
//        )!
//
//
////                print(secAccessControlObject)
////                let dataToStore = "AnyData".data(using: .utf8)!
//
//
////                let insertQuery: NSDictionary = [
////                    kSecClass: kSecClassGenericPassword,
////                    kSecAttrAccessControl: secAccessControlObject,
////                    kSecAttrService: "PasscodeAuthentication",
////                    kSecValueData: dataToStore as Any,
////                ]
//
////                let insertStatus = SecItemAdd(insertQuery as CFDictionary, nil)
//
////                SecItemDelete(insertQuery as CFDictionary)
//
//
//        let query: NSDictionary = [
//            kSecClass:  kSecClassGenericPassword,
//            kSecAttrAccessControl: secAccessControlObject,
//            kSecAttrService  : "PasscodeAuthentication",
//            kSecUseOperationPrompt : reason
//        ]
//
////        SecItemDelete(query as CFDictionary)
//
//
//        //        print(query)
//
////        var typeRef : CFTypeRef?
//
//
//        let status: OSStatus = SecItemCopyMatching(query, nil) //This will prompt the passcode.
//
//        // Check authentication status
//        if (status == errSecSuccess)
//        {
//            print("Authentication Succeeded")
//            return  true
//        } else {
//            print("Authentication failed, OSStatus : \(status)")
//
//            return false
//        }
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
//                        print("Has passcode")
            return true
        }else{
            //            print("No Passcode")
            return false
        }
    }
}
