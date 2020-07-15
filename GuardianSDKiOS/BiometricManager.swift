//
//  BiometricManager.swift
//  GuardianFramework
//
//  Created by Jayhy on 08/07/2020.
//  Copyright © 2020 fns_mac_pro. All rights reserved.
//

import Foundation
import LocalAuthentication

open class BiometricManager{
    
    var context : LAContext = LAContext()
    var error : NSError?
    let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics
    
    public init() {
    }
    
    open func authenticate(msg: String, onSuccess: @escaping(Bool) -> Void, onFailed: @escaping(Int) -> Void) {
        if context.canEvaluatePolicy(deviceAuth, error: &error){
            context.evaluatePolicy(deviceAuth, localizedReason: msg, reply:{(success,e) in
                if success {
                    DispatchQueue.main.async {
                      onSuccess(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        onFailed(1)
                    }
                }
            })
        } else {
            onFailed(-1)
        }
    }
}
