//
//  BiometricManager.swift
//  GuardianFramework
//
//  Created by Jayhy on 08/07/2020.
//  Copyright © 2020 fns_mac_pro. All rights reserved.
//

import Foundation
import LocalAuthentication

open class BiometricService{
    
    public static let sharedInstance = BiometricService()
    
    var newBioContext = LAContext()
    var error : NSError?
    var strBioType : String = ""
    
    public init() {
    }
    
    private func initBiometric() -> RtCode {
        // Touch ID & Face ID not allow
        let context = LAContext()
        context.localizedFallbackTitle = ""
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            switch context.biometryType {
            case .faceID:
                strBioType = "Face ID"
                break
            case .touchID:
                strBioType = "Touch ID"
                break
            case .none:
                break
            }
        } else {
            switch error! {
            case LAError.biometryNotAvailable:
                return RtCode.BIOMETRIC_NOT_AVILABLE
            case LAError.biometryLockout:
                return RtCode.BIOMETRIC_LOCK_OUT
            case LAError.biometryNotEnrolled:
                return RtCode.BIOMETRIC_NOT_ENROLLED_DEVICE
            // 디바이스의 패스코드를 설정 하지 않았다.
    //            case LAError.passcodeNotSet:
    //                return RtCode.BIO
            default:
                return RtCode.BIOMETRIC_NOT_SUPPORT_HARDWARE
            }
        }
        
        return RtCode.AUTH_SUCCESS
    }
    
    public func authenticate(msg: String, onSuccess: @escaping(RtCode, String, Array<[String:String]>)-> Void, onFailed: @escaping(RtCode, String?)-> Void) {
        let initCode = initBiometric()
        if(initCode != .AUTH_SUCCESS) {
//            if(PasscodeService().deviceHasPasscode()) {
//                let result = PasscodeService().passcodeAuthentication()
//                if(result) {
//                    onSuccess(RtCode.AUTH_SUCCESS, "", self.getBiometricTypeList())
//                }
//            } else {
//                onFailed(initCode, getLocalizationMessage(rtCode : initCode))
//            }
            let result = PasscodeService().passcodeAuthentication()
            if(result) {
                onSuccess(RtCode.AUTH_SUCCESS, "", self.getBiometricTypeList())
            } else {
                onFailed(initCode, getLocalizationMessage(rtCode : initCode))
            }
        } else {
            if(!hasRegisterBiometric()) {
                onFailed(RtCode.BIOMETRIC_NOT_ENROLLED_APP, getLocalizationMessage(rtCode : RtCode.BIOMETRIC_NOT_ENROLLED_APP))
            } else {
                let context = LAContext()
                context.localizedFallbackTitle = ""
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
                    if let domainState = context.evaluatedPolicyDomainState {
                        let strData = String(data: domainState.base64EncodedData(), encoding: .utf8)
                        let cData = KeychainService.loadPassword(service: getPackageName(), account: "biometrics")
                        if(strData != cData) {
                            onSuccess(RtCode.BIOMETRIC_CHANGE_ENROLLED, self.getLocalizationMessage(rtCode : RtCode.BIOMETRIC_CHANGE_ENROLLED), self.getBiometricTypeList())
                        } else {
                            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Biometric", reply:{(success, error) in
                                if success {
                                    DispatchQueue.main.async {
                                        onSuccess(RtCode.AUTH_SUCCESS, "", self.getBiometricTypeList())
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        let message: String
                                        switch error {
                                        case LAError.authenticationFailed?:
                                            message = "There was a problem verifying your identity."
                                        case LAError.userCancel?:
                                            message = "You pressed cancel."
                                        case LAError.userFallback?:
                                            message = "You pressed password."
                                        case LAError.biometryNotAvailable?:
                                            message = "Face ID/Touch ID is not available."
                                        case LAError.biometryNotEnrolled?:
                                            message = "Face ID/Touch ID is not set up."
                                        case LAError.biometryLockout?:
                                            message = "Face ID/Touch ID is locked."
                                        default:
                                            message = "Face ID/Touch ID may not be configured"
                                        }
                                            
                                        onFailed(RtCode.BIOMETRIC_AUTH_FAILED, message)
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    public func hasNewBiometricEnrolled(onSuccess: @escaping(RtCode, String, Array<[String:String]>)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let initCode = initBiometric()
        if(initCode != .AUTH_SUCCESS) {
            onSuccess(RtCode.BIOMETRIC_PASSCODE, "", self.getBiometricTypeList())
//            if(PasscodeService().deviceHasPasscode()) {
//                let result = PasscodeService().passcodeAuthentication()
//                if(result) {
//                    onSuccess(RtCode.BIOMETRIC_PASSCODE, "", self.getBiometricTypeList())
//                }
//            } else {
//                onFailed(initCode, getLocalizationMessage(rtCode : initCode))
//            }
        } else {
            if(!hasRegisterBiometric()) {
                onFailed(RtCode.BIOMETRIC_NOT_ENROLLED_APP, getLocalizationMessage(rtCode : RtCode.BIOMETRIC_NOT_ENROLLED_APP))
            } else {
                DispatchQueue.main.async {
                    let context = LAContext()
                    context.localizedFallbackTitle = ""
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
                        if let domainState = context.evaluatedPolicyDomainState {
                            let strData = String(data: domainState.base64EncodedData(), encoding: .utf8)
                            let cData = KeychainService.loadPassword(service: getPackageName(), account: "biometrics")
                            if(strData != cData) {
                                onSuccess(RtCode.BIOMETRIC_CHANGE_ENROLLED, self.getLocalizationMessage(rtCode : RtCode.BIOMETRIC_CHANGE_ENROLLED), self.getBiometricTypeList())
                            } else {
                                onSuccess(RtCode.BIOMETRIC_NORMAL, self.getLocalizationMessage(rtCode : RtCode.BIOMETRIC_NORMAL), self.getBiometricTypeList())
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func registerBiometric(onSuccess: @escaping(RtCode, String, Array<[String:String]>)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let initCode = initBiometric()
        if(initCode != .AUTH_SUCCESS) {
            onFailed(initCode, getLocalizationMessage(rtCode : initCode))
        } else {
            do {
                let context = LAContext()
                context.localizedFallbackTitle = ""
//                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: strBioType, reply:{(success, error) in
//                    if success {
//                        DispatchQueue.main.async {
//                            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
//                                if let domainState = context.evaluatedPolicyDomainState {
//                                    if let strData = String(data: domainState.base64EncodedData(), encoding: .utf8) {
//                                        KeychainService.savePassword(service: getPackageName(), account: "biometrics", data: strData)
//                                        onSuccess(RtCode.AUTH_SUCCESS, "", self.getBiometricTypeList())
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            let message: String
//                            switch error {
//                            case LAError.authenticationFailed?:
//                                message = "There was a problem verifying your identity."
//                            case LAError.userCancel?:
//                                message = "You pressed cancel."
//                            case LAError.userFallback?:
//                                message = "You pressed password."
//                            case LAError.biometryNotAvailable?:
//                                message = "Face ID/Touch ID is not available."
//                            case LAError.biometryNotEnrolled?:
//                                message = "Face ID/Touch ID is not set up."
//                            case LAError.biometryLockout?:
//                                message = "Face ID/Touch ID is locked."
//                            default:
//                                message = "Face ID/Touch ID may not be configured"
//                            }
//                            onFailed(RtCode.BIOMETRIC_AUTH_FAILED, message)
//                        }
//                    }
//                })
                DispatchQueue.main.async {
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                        if let domainState = context.evaluatedPolicyDomainState {
                            if let strData = String(data: domainState.base64EncodedData(), encoding: .utf8) {
                                KeychainService.savePassword(service: getPackageName(), account: "biometrics", data: strData)
                                onSuccess(RtCode.AUTH_SUCCESS, "", self.getBiometricTypeList())
                            }
                        }
                    }
                }
            } catch {
                onFailed(RtCode.BIOMETRIC_ERROR, "")
            }
        }
    }
    
    public func resetBiometric(onSuccess: @escaping(RtCode, String, Array<[String:String]>)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let initCode = initBiometric()
        if(initCode != .AUTH_SUCCESS) {
            onFailed(initCode, getLocalizationMessage(rtCode : initCode))
        } else {
            let context = LAContext()
            context.localizedFallbackTitle = ""
            
            DispatchQueue.main.async {
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    if let domainState = context.evaluatedPolicyDomainState {
                        if let strData = String(data: domainState.base64EncodedData(), encoding: .utf8) {
                            
                            if(self.hasRegisterBiometric()) {
                                KeychainService.updatePassword(service: getPackageName(), account: "biometrics", data: strData)
                            } else {
                                KeychainService.savePassword(service: getPackageName(), account: "biometrics", data: strData)
                            }
                            onSuccess(RtCode.AUTH_SUCCESS, "", self.getBiometricTypeList())
                        }
                    }
                }
            }
            
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: strBioType, reply:{(success, error) in
//                if success {
//                    DispatchQueue.main.async {
//                        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
//                            if let domainState = context.evaluatedPolicyDomainState {
//                                if let strData = String(data: domainState.base64EncodedData(), encoding: .utf8) {
//
//                                    if(self.hasRegisterBiometric()) {
//                                        KeychainService.updatePassword(service: getPackageName(), account: "biometrics", data: strData)
//                                    } else {
//                                        KeychainService.savePassword(service: getPackageName(), account: "biometrics", data: strData)
//                                    }
//                                    onSuccess(RtCode.AUTH_SUCCESS, "", self.getBiometricTypeList())
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        let message: String
//                        switch error {
//                        case LAError.authenticationFailed?:
//                            message = "There was a problem verifying your identity."
//                        case LAError.userCancel?:
//                            message = "You pressed cancel."
//                        case LAError.userFallback?:
//                            message = "You pressed password."
//                        case LAError.biometryNotAvailable?:
//                            message = "Face ID/Touch ID is not available."
//                        case LAError.biometryNotEnrolled?:
//                            message = "Face ID/Touch ID is not set up."
//                        case LAError.biometryLockout?:
//                            message = "Face ID/Touch ID is locked."
//                        default:
//                            message = "Face ID/Touch ID may not be configured"
//                        }
//
//                        onFailed(RtCode.BIOMETRIC_AUTH_FAILED, message)
//                    }
//                }
//            })
        }
    }
    
    private func getBiometricTypeList() -> Array<[String:String]> {
        var returnValue = Array<[String:String]>()
        var dic = [String:String]()
        dic["type"] = self.strBioType
        returnValue.append(dic)
        return returnValue
    }
    
    private func getLocalizationMessage(rtCode : RtCode) -> String {
        return LocalizationMessage.sharedInstance.getLocalization(code: rtCode.rawValue) as? String ?? ""
    }
    
    private func hasRegisterBiometric() -> Bool {
        var result : Bool = false
        let cData = KeychainService.loadPassword(service: getPackageName(), account: "biometrics")
        if(cData == nil) {
            result = false
        } else {
            result = true
        }
        return result
    }

}
