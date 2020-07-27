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
        
        if(!hasRegisterBiometric()) {
            return RtCode.BIOMETRIC_NOT_ENROLLED_APP
        }
        
        return RtCode.AUTH_SUCCESS
    }
    
    public func authenticate(msg: String, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String?)-> Void) {
        let initCode = initBiometric()
        if(initBiometric() != .AUTH_SUCCESS) {
            onFailed(initCode, "")
        } else {
            let context = LAContext()
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: msg, reply:{(success,e) in
                if success {
                    DispatchQueue.main.async {
                        print("Biometric auth success")
                        onSuccess(RtCode.AUTH_SUCCESS, "")
                    }
                } else {
                    DispatchQueue.main.async {
                        switch self.error {
                        // 시스템(운영체제)에 의해 인증 과정이 종료 LAError.systemCancel:
    //                            case LAError.systemCancel:
    //                                RtCode.BIO_
    //                                self.notifyUser(msg: "시스템에 의해 중단되었습니다.", err: error?.localizedDescription)
    //                            // 사용자가 취소함 LAError.userCancel
    //                            case LAError.userCancel:
    //                                self.notifyUser(msg: "인증이 취소 되었습니다.", err: error?.localizedDescription)
                        // 터치아이디 대신 암호 입력 버튼을 누른경우(터치아이디 1회 틀리면 암호 입력 버튼 나옴) LAError.userFallback
    //                            case LAError.userFallback:
    //                                self.notifyUser(msg: "터치 아이디 인증", err: "암호 입력을 선택했습니다.")
                        default:
                            onFailed(RtCode.BIOMETRIC_AUTH_FAILED, self.error?.localizedDescription)
                        }
                    }
                }
            })
        }
    }
    
    public func hasNewBiometricEnrolled(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        if(!hasRegisterBiometric()) {
            onFailed(RtCode.BIOMETRIC_NOT_ENROLLED_APP, "")
        } else {
            self.newBioContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: strBioType, reply:{(success,e) in
                if success {
                    DispatchQueue.main.async {
                        let context = LAContext()
                        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
                            if let domainState = context.evaluatedPolicyDomainState {
                                let strData = String(data: domainState.base64EncodedData(), encoding: .utf8)
                                let cData = KeychainService.loadPassword(service: getPackageName(), account: "biometrics")
                                if(strData != cData) {
                                    onSuccess(RtCode.BIOMETRIC_CHANGE_ENROLLED, "")
                                } else {
                                    onSuccess(RtCode.BIOMETRIC_NORMAL, "")
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        switch self.error {
                        default:
                            onFailed(RtCode.BIOMETRIC_AUTH_FAILED, "")
                        }
                    }
                }
            })
        }
    }
    
    public func registerBiometric(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        initBiometric()
        do {
            if(hasRegisterBiometric()) {
                onFailed(RtCode.BIOMETRIC_ENROLLED_DUPLICATION, "")
            } else {
                let context = LAContext()
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: strBioType, reply:{(success,e) in
                    if success {
                        DispatchQueue.main.async {
                            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                                if let domainState = context.evaluatedPolicyDomainState {
                                    if let strData = String(data: domainState.base64EncodedData(), encoding: .utf8) {
                                        KeychainService.savePassword(service: getPackageName(), account: "biometrics", data: strData)
                                        onSuccess(RtCode.AUTH_SUCCESS, "")
                                    }
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            switch self.error! {
                            default:
                                onFailed(RtCode.BIOMETRIC_AUTH_FAILED, self.error!.localizedDescription)
                            }
                        }
                    }
                })
            }
        } catch {
            onFailed(RtCode.BIOMETRIC_ERROR, "")
        }
    }
    
    public func reRegisterBiometric(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        initBiometric()
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: strBioType, reply:{(success,e) in
            if success {
                DispatchQueue.main.async {
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                        if let domainState = context.evaluatedPolicyDomainState {
                            if let strData = String(data: domainState.base64EncodedData(), encoding: .utf8) {
                                
                                if(self.hasRegisterBiometric()) {
                                    KeychainService.updatePassword(service: getPackageName(), account: "biometrics", data: strData)
                                } else {
                                    KeychainService.savePassword(service: getPackageName(), account: "biometrics", data: strData)
                                }
                                onSuccess(RtCode.AUTH_SUCCESS, "")
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    switch self.error! {
                    default:
                        onFailed(RtCode.BIOMETRIC_AUTH_FAILED, self.error!.localizedDescription)
                    }
                }
            }
        })
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
