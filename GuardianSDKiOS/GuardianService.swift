//
//  GuardianService.swift
//  GuardianFramework
//
//  Created by Jayhy on 07/07/2020.
//  Copyright © 2020 fns_mac_pro. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift
import CoreMotion
import AVFoundation

public enum RtCode : Int {
    case AUTH_SUCCESS = 0
    case AUTH_PROCESSING = 2010
    
    case COMM_FIND_CLIENT_FAIL = 2000
    case COMM_SERVER_ERROR = 2001
    case COMM_REQUEST_PARAM_ERROR = 2002
    case COMM_SESSION_ERROR = 2003
    case AUTH_CHANNDEL_NOT_EXIST = 2004
    case MEMBER_MAX_USER_LICENSE_EXPIRY = 2005
    case MEMBER_MAX_AUTH_LICENSE_EXPIRY = 2006
    case MEMBER_NOT_REGISTER = 2007
    case MEMBER_DEVICE_NOT_REGISTER = 2008
    case MEMBER_MULTIPLE_JOIN = 2009

    case COMM_FAIL_LICENSE_CONSISTENCY = 2011
    case COMM_MAINTENANCE_SERVER = 2012
    case MEMBER_LICENSE_TERM_EXPIRY = 2013
    case COMM_FIND_LICENSE_FAIL = 2014
    case COMM_DUPLICATE_CLIENT = 2015
    case COMM_DUPLICATE_LICENSE = 2016
    case COMM_DUPLICATE_REQUEST_LICENSE = 2017

    case MEMBER_FIND_AUTH_TYPE_FAIL = 3000
    case MEMBER_FIND_ICON_SELECT_FAIL = 3001
    case MEMBER_FIND_PERSONAL_INFO_AGREE_FAIL = 3002
    case MEMBER_FIND_UUID_INFO_AGREE_FAIL = 3003
    case MEMBER_AUTH_NOMAL = 3004
    case MEMBER_FAIL_VAILD_AUTH_NUM = 3005
    case MEMBER_FAIL_VAILD = 3006
    case MEMBER_FAIL_VAILD_DEVICE_ID = 3007
    case MEMBER_NO_ACCESS_ADMIN_PAGE = 3008
    case MEMBER_FIND_FCM_TOKEN_FAIL = 3009
    case MEMBER_FIND_STATUS_FAIL = 3010
    
    case AUTH_CERT_TIME_OUT = 5000
    case AUTH_STATUS_TIMEOUT = 5001
    case AUTH_VAILD_SESSION_ID_FAIL = 5002
    case AUTH_VAILD_IP_FAIL = 5003
    case AUTH_FAIL_VAILD_BLOCK_KEY = 5004
    case AUTH_MEMBER_STATUS_UNAPPROVAL = 5005
    case AUTH_MEMBER_STATUS_TEMP = 5006
    case AUTH_MEMBER_STATUS_PERM = 5007
    case AUTH_MEMBER_STATUS_WITHDRAW = 5008
    case AUTH_FAIL = 5010
    case AUTH_CANCEL = 5011
    case AUTH_ICON_SELECT_FAIL = 5013
    case AUTH_ADD_CHANNEL_FAIL = 5015
    case AUTH_CREATE_NODE_FAIL = 5016
    case AUTH_SEND_PUSH_FAIL = 5017
    case AUTH_REQUEST_FAIL = 5018
    case AUTH_GET_CHANNEL_FAIL = 5019
    case AUTH_DATA_DECRYPT_FAIL = 5020
    case AUTH_VERIFICATION_REQUEST_FAIL = 5021
    case AUTH_VERIFICATION_FAIL = 5022
    
    case API_ERROR = 10001
}

public enum PushTarget : String {
    case PUSH_TARGET_AUTH = "1000"
    case PUSH_TARGET_KEY_IN = "1006"
    case PUSH_TARGET_CANCEL = "1001"
    case PUSH_TARGET_SUCCESS = "1002"
    case PUSH_TARGET_FAIL = "1003"
}

public enum NotipicationId : String {
    case NOTI_ID_AUTH = "GUARDIAN_AHTH"
    case NOTI_ID_SUCCESS = "GUARDIAN_SUCCESS"
    case NOTI_ID_FAIL = "GUARDIAN_FAIL"
    case NOTI_ID_CANCEL = "GUARDIAN_CANCEL"
}

public let USER_KEY = "GUARDIAN_USER_KEY"
public let FCM_TOKEN = "GUARDIAN_FCM_TOKEN"

public let AUTH_FAIL_CODE_ERROR = -2
public let AUTH_FAIL_CODE_USER_ERROR = -4
public let AUTH_FAIL_CODE_NOT_START_PROCESS = -3
public let AUTH_FAIL_CODE_USER_CANCEL = -1

public enum PushState {
    case deviceCheck,keyIn
}

// 인증 결과 전달을 위한 delegate
public protocol AuthCallBack: class {
    func onFailed(errorCode: Int,errorMsg: String)
    func onSuccess(channelKey: String)
    func onCancel()
}

// unwind 를 위한 delegate
public protocol UnwindCallBack: class {
    func onBack()
}

func setUserKey(userKey : String) {
    let ud = UserDefaults.standard
    ud.set(userKey,forKey: USER_KEY)
}

func getUserKey() -> String {
    let ud = UserDefaults.standard
    return ud.string(forKey: USER_KEY) ?? ""
}

func getLang() -> String {
    let prefferedLanguage = Locale.preferredLanguages[0] as String
    let arr = prefferedLanguage.components(separatedBy: "-")
    return arr.first!
}

func getUUid() -> String {
    let packageName = getPackageName()
    if let keyChainDeviceId =  KeychainService.loadPassword(service: packageName, account:"deviceId"){
        return keyChainDeviceId
    } else {
        let deviceId =  "\(packageName)\(UIDevice.current.identifierForVendor!.uuidString)"
        KeychainService.savePassword(service: packageName, account:"deviceId",data:deviceId)
        return deviceId
    }
}

func getPackageName() -> String {
    let packageName = Bundle.main.bundleIdentifier as? String ?? "com.fnsvalue.GuardianCCS"
    return packageName
}

func getUserToken() -> String {
    let ud = UserDefaults.standard
    return ud.string(forKey: FCM_TOKEN) ?? ""
}

func getOSVersion() -> String {
    return UIDevice.current.systemVersion
}

func getAppVersion() -> String {
    let appVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
    return appVersion!
}

public class GuardianService{
        
    public static let sharedInstance = GuardianService()
    
    private init() {
        
    }
    
    public struct Domain {
        public static var apiDomain = ""
    }
    
    private static var _channelKey : String = ""
    public var channelKey : String {
        get {
            return GuardianService._channelKey
        }
        set(value) {
            GuardianService._channelKey = value
        }
    }
    
    private static var _blockKey : String = ""
    public var blockKey : String {
        get {
            return GuardianService._blockKey
        }
        set(value) {
            GuardianService._blockKey = value
        }
    }
    
//    private static var _translationMap : [String: Any]? = ["1": 1]
//
//    private var translationMap : [String: Any]? {
//        get {
//            return GuardianService._translationMap
//        }
//        set (value) {
//            GuardianService._translationMap = value
//        }
//    }
    
    public func initDomain(domain :String) {
        print("initDomain")
        Domain.apiDomain = domain
//        getTransltion()
    }
    
    public func requestMember(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "member"
        let params = ["deviceId": getUUid(),
                      "packageName": getPackageName(),
                      "os":"IOS"]
        
        self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
                
            let rtCode = data["rtCode"] as! Int
            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue) {
                guard let member = data["data"] as? [String:Any] else {
                    onFailed(RtCode.MEMBER_NOT_REGISTER, rtMsg)
                    return
                }
                
                let userKey = member["userKey"] as! String
                setUserKey(userKey: userKey)
                
                let userTotalStatus = member["userTotalStatus"] as! Int
                if (userTotalStatus == RtCode.MEMBER_AUTH_NOMAL.rawValue){
                    onSuccess(RtCode(rawValue: userTotalStatus)!, rtMsg)
                } else if(userTotalStatus == RtCode.AUTH_PROCESSING.rawValue){
                    self.channelKey = member["channelKey"] as! String
                    self.blockKey = member["blockKey"] as! String
                    onSuccess(RtCode.AUTH_PROCESSING, rtMsg)
                } else {
                    self.onCallbackFailed(rtCode: RtCode(rawValue: userTotalStatus)!, onFailed: onFailed)
                }
            
            } else if(rtCode == RtCode.MEMBER_NOT_REGISTER.rawValue){
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            } else {
                onFailed(RtCode.API_ERROR, "\(rtCode)")
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestTokenUpdate(token : String, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "member/token/update"
        let params = ["userKey": getUserKey(),
                      "deviceId":getUUid(),
                      "token":token,
                      "packageName":getPackageName(),
                      "os":"IOS",
                      "osVersion":getOSVersion(),
                      "appVersion":getAppVersion()]
        
        self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
            
            let rtCode = data["rtCode"] as! Int
            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
            if(rtCode == RtCode.AUTH_SUCCESS.rawValue) {
                onSuccess(RtCode(rawValue: rtCode)!, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestAuthRequest(onSuccess: @escaping(RtCode, String, Int, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "auth/request"
        
        let enCodeCK = encryptAES256(value: self.channelKey, seckey: self.channelKey)
        let enCodeBK = encryptAES256(value: self.blockKey, seckey: self.channelKey)
        let enCodeDK = encryptAES256(value: getUUid(), seckey: self.channelKey)
        
        let params = [
            "lang":getLang(),
            "userKey":getUserKey(),
            "packageName":getPackageName(),
            "deviceId":getUUid(),
            "os":"IOS",
            "enCodeCK":enCodeCK,
            "enCodeBK":enCodeBK,
            "enCodeDK":enCodeDK]
        
        self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
            
            let rtCode = (data["rtCode"] as? Int) ?? 0
            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                guard let authData = data["data"] as? [String:Any] else {
                    onFailed(RtCode.API_ERROR, rtMsg)
                    return
                }
                
                let authType = authData["authType"] as! Int
                let connectIp = authData["connectIp"] as! String
                
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg, authType, connectIp)
                
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestAuthResult(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "auth/result"
        let params = ["lang":getLang(),
                      "userKey":getUserKey(),
                      "packageName":getPackageName(),
                      "os":"IOS"]
        
        self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
            
            let rtCode = data["rtCode"] as! Int
            let rtMsg = (data["rtMsg"] as? String) ?? ""
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestAuthCancel(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "auth/cancel/app"
        let params = ["lang":getLang(),
                      "userKey":getUserKey(),
                      "packageName":getPackageName(),
                      "os":"IOS"]
        
        self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
            
            let rtCode = data["rtCode"] as! Int
            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestMemberRegister(userKey: String, authType: String, iconSelect: String, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        
        print("requestMemberRegister")
        print(authType)
        print(iconSelect)
        
        let packageName = getPackageName()
        let deviceId =  "\(packageName)\(UIDevice.current.identifierForVendor!.uuidString)"
        KeychainService.updatePassword(service: packageName, account:"deviceId",data:deviceId)
        DeviceInfoService().getDeviceInfo{ (data:Dictionary<String, String>) in
            let apiUrl = "device/member/register"
            var params = data
//            params["authType"] = authType
//            params["iconSelect"] = iconSelect
            params["userKey"] = userKey
            
            self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
                setUserKey(userKey: userKey)
                let rtCode = data["rtCode"] as! Int
                let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
                
                if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                    onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
                } else {
                    self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
                }
                
            }, errorCallBack: {(errorCode, errorMsg) -> Void in
                onFailed(RtCode.API_ERROR, errorMsg)
            })
        }
    }
    
    public func requestVerifyIcon(icons: String, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "verify/icon"
        let params = ["lang":getLang(),
                      "iconSelect":icons,
                      "userKey":getUserKey(),
                      "packageName":getPackageName(),
                      "os":"IOS"]
        
        self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
            
            let rtCode = data["rtCode"] as! Int
            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })

    }
    
    public func requestFingerFail(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "verify/fingerPrint/fail"
        let params = ["lang":getLang(),
                      "userKey":getUserKey(),
                      "packageName":getPackageName(),
                      "os":"IOS"]
        
        self.postAPI(params: params, api: apiUrl, successCallBack: {(data:[String:Any]) -> Void in
            
            let rtCode = data["rtCode"] as! Int
            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    private func postAPI(params: Dictionary<String,String>,
                      api: String,
                      successCallBack : @escaping([String:Any]) -> Void,
                      errorCallBack: @escaping(Int, String) -> Void){
        
        let url = Domain.apiDomain + api
        print("postAPI")
        print(params)
        print(url)
        
        Alamofire.request(url,method: .post,parameters: params,encoding: JSONEncoding.default)
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    var statusCode : Int! = response.response?.statusCode ?? RtCode.API_ERROR.rawValue
                    var statusMessage : String
                    if let error = response.result.error as? AFError {
                        statusCode = error._code // statusCode private
                        switch error {
                        case .invalidURL(let url):
                            statusMessage = "Invalid URL: \(url) - \(error.localizedDescription)"
                        case .parameterEncodingFailed(let reason):
                            statusMessage = "Parameter encoding failed: \(error.localizedDescription)"
                            statusMessage = "Failure Reason: \(reason)"
                        case .multipartEncodingFailed(let reason):
                            statusMessage = "Multipart encoding failed: \(error.localizedDescription)"
                            statusMessage = "Failure Reason: \(reason)"
                        case .responseValidationFailed(let reason):
                            statusMessage = "Response validation failed: \(error.localizedDescription)"
                            statusMessage = "Failure Reason: \(reason)"
                            switch reason {
                            case .dataFileNil, .dataFileReadFailed:
                                statusMessage = "Downloaded file could not be read"
                            case .missingContentType(let acceptableContentTypes):
                                statusMessage = "Content Type Missing: \(acceptableContentTypes)"
                            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                                statusMessage = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                            case .unacceptableStatusCode(let code):
                                statusMessage = "Response status code was unacceptable: \(code)"
                                statusCode = code
                            }
                        case .responseSerializationFailed(let reason):
                            statusMessage = "Response serialization failed: \(error.localizedDescription)"
                            statusMessage = "Failure Reason: \(reason)"
                            // statusCode = 3840 ???? maybe..
                        }

                        statusMessage = "Underlying error: \(error.underlyingError)"
                    } else if let error = response.result.error as? URLError {
                        statusMessage = "URLError occurred: \(error)"
                    } else {
                        statusMessage = "Unknown error: \(response.result.error)"
                    }

                    errorCallBack(statusCode, statusMessage)
                    return
                }
                
                if let data = response.result.value as? [String:Any]{
                    print(data)
                    successCallBack(data)
                }
                
        }
    }
    
    private func onCallbackFailed(rtCode : RtCode, onFailed: @escaping(RtCode, String) -> Void) {
        let msg : String = LocalizationMessage.sharedInstance.getLocalization(code: rtCode.rawValue) as? String ?? ""
        onFailed(rtCode, msg)
    }
    
    public func guardianPushMsgHandle(_ notification: Notification,pushCallBack: @escaping(PushState) -> Void)-> Void{
        guard let targetString: String = notification.userInfo?["gcm.notification.target"] as? String else {return}
        
        if targetString == "1000" {
            guard let channelKey: String = notification.userInfo?["gcm.notification.channel_key"] as? String else {return}
            guard let blockKey: String = notification.userInfo?["gcm.notification.block_key"] as? String else {return}
            
            self.channelKey = channelKey
            self.blockKey = blockKey
            
            pushCallBack(PushState.deviceCheck)
        } else {
            pushCallBack(PushState.keyIn)
        }
    }
    
//    func getTransltion() {
//        let lang = getLang()
//        var translationName : String
//        switch lang {
//        case "ko":
//            translationName = "translation_ko"
//        default:
//            translationName = "translation"
//        }
//
////        let bundle = Bundle(for: GuardianService.self)
//
//        print("getTransltion")
//
//        guard let asset = NSDataAsset(name: translationName) else {
//            fatalError("Missing data asset: NamedColors")
//        }
//
//        let decoder = JSONDecoder()
//        let jj = try? decoder.decode(Translation.self, from: asset.data)
//
//        self.translationMap = jj?.error
//        
////        for (key, value) in jj?.error {
////            print("\(key):\(value)")
////        }
//
//    }
    
    class DeviceInfoService {
        var authCode: String!
        //var bthOnOff = "OFF"
        var audioMode: String!
        var phoneNum: String!
        let altimeter = CMAltimeter()
        let motionManager = CMMotionManager()
        
        var magnetic = "magnetic"
        var orientation  = "orientation"
        var gyroscope  = "gyroscope"
        var acceleration  = "acceleration"
        var light  = "altimeter"
        var checkCount = 0;
        
       
        var mGetDeviceInfoCallback :(Dictionary<String,String>) -> Void = {_ in }
        
        public init(){
            
        }
        
        public func getDeviceInfo(getDeviceInfoCallback:@escaping(Dictionary<String,String>) -> Void){
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.1
                motionManager.startDeviceMotionUpdates(to: OperationQueue.current!){ (motion,error) in
                    self.outputMotion(data: motion)
                }
            } else {
                checkCount += 1
            }
            
            //가속도 센서
            if motionManager.isAccelerometerAvailable {
                motionManager.accelerometerUpdateInterval = 0.1
                motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {accelerometerData, error in self.outputAccelerationData(data: (accelerometerData?.acceleration)!)
                })
            }  else {
                checkCount += 1
            }
            //자이로 센서
            if motionManager.isGyroAvailable {
                motionManager.gyroUpdateInterval = 0.1
                motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
                    self.outputGyroData(data: (data?.rotationRate)!)
                }
            }  else {
                checkCount += 1
            }
            
            //지자기 센서
            if motionManager.isMagnetometerAvailable {
                motionManager.magnetometerUpdateInterval = 0.1
                motionManager.startMagnetometerUpdates(to : OperationQueue.current!) { (data, error) in
                    self.outputMagneticData(data: (data?.magneticField)!)
                }
            }  else {
                checkCount += 1
            }
            
            //기압
            if CMAltimeter.isRelativeAltitudeAvailable() {
                altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
                    let a = data?.relativeAltitude.stringValue
                    let b = data?.pressure.stringValue
                    self.light = "\(a!)|\(b!)"
                    self.stopAltimeter();
                }
            }  else {
                checkCount += 1
            }
            mGetDeviceInfoCallback = getDeviceInfoCallback
        }
        
        func callCheck(){
            if (checkCount == 5) {
                NSLog("data set!")
                NSLog("data \(magnetic)")
                NSLog("data \(gyroscope)")
                NSLog("data \(acceleration)")
                NSLog("data \(orientation)")
                NSLog("data \(light)")
                
                self.setCallback()
                
            } else {
                NSLog("data not set!")
                
            }
        }
        
        func stopAltimeter(){
            checkCount += 1
            callCheck()
            altimeter.stopRelativeAltitudeUpdates()
        }
        
        func outputMotion(data: CMDeviceMotion?){
            let radians = atan2((data?.gravity.x)!, (data?.gravity.y)!) - .pi
            let degrees = radians * 180.0  / .pi
            
            orientation = String(format: "%.2f", degrees)
            checkCount += 1
            callCheck()
            motionManager.stopDeviceMotionUpdates()
        }
        
        func outputMagneticData(data : CMMagneticField){
            
            magnetic = "\(String(format: "%.2f", data.x))|\(String(format: "%.2f", data.y))|\(String(format: "%.2f", data.z))"
            checkCount += 1
            callCheck()
            motionManager.stopMagnetometerUpdates()
        }
        
        func outputGyroData(data: CMRotationRate){
            
            gyroscope = "\(String(format: "%.2f", data.x))|\(String(format: "%.2f", data.y))|\(String(format: "%.2f", data.z))"
            checkCount += 1
            callCheck()
            motionManager.stopGyroUpdates()
        }
        
        func outputAccelerationData(data: CMAcceleration){
            
            acceleration = "\(String(format: "%.2f", data.x))|\(String(format: "%.2f", data.y))|\(String(format: "%.2f", data.z))"
            checkCount += 1
            callCheck()
            motionManager.stopAccelerometerUpdates();
        }
        
        func setCallback(){
            let securityKey = "FNSVALUEfnsvalueFNSVALUEfnsvalue"
            var _proximity = "proximity \(Date().currentTimeMillis())"
            var _light = "\(light) \(Date().currentTimeMillis())"
            var _magnetic = "\(magnetic) \(Date().currentTimeMillis())"
            var _orientation = "\(orientation) \(Date().currentTimeMillis())"
            var _audioInfo = "audioInfo \(Date().currentTimeMillis())"
            var _audioMode = "\(GuardianService().getAudioMode()) \(Date().currentTimeMillis())"
            var _macAddr = "macAddr \(Date().currentTimeMillis())"
            var _bthAddr = "bthAddr \(Date().currentTimeMillis())"
            var _wifiInfo = "wifiInfo \(Date().currentTimeMillis())"
            var _accelerometer = "\(acceleration) \(Date().currentTimeMillis())"
            var _gyroscope = "\(gyroscope) \(Date().currentTimeMillis())"
            
            _proximity = GuardianService().encryptAES256(value:_proximity,seckey: securityKey)
            _light = GuardianService().encryptAES256(value:_light,seckey: securityKey)
            _magnetic = GuardianService().encryptAES256(value:_magnetic,seckey: securityKey)
            _orientation = GuardianService().encryptAES256(value:_orientation,seckey: securityKey)
            _audioInfo = GuardianService().encryptAES256(value:_audioInfo,seckey: securityKey)
            _audioMode = GuardianService().encryptAES256(value:_audioMode,seckey: securityKey)
            _macAddr = GuardianService().encryptAES256(value:_macAddr,seckey: securityKey)
            _bthAddr = GuardianService().encryptAES256(value:_bthAddr,seckey: securityKey)
            _wifiInfo = GuardianService().encryptAES256(value:_wifiInfo,seckey: securityKey)
            _accelerometer = GuardianService().encryptAES256(value:_accelerometer,seckey: securityKey)
            _gyroscope = GuardianService().encryptAES256(value:_gyroscope,seckey: securityKey)
            
            let params = [
                        "phoneNum":phoneNum ?? "",
                        "authCode":authCode ?? "",
                        "lang":getLang(),
                        "proximity":_proximity,
                        "light":_light,
                        "magnetic":_magnetic,
                        "orientation":_orientation,
                        "audioInfo":_audioInfo,
                        "audioMode":_audioMode,
                        "deviceId":getUUid(),
                        "macAddr":_macAddr,
                        "bthAddr":_bthAddr,
                        "wifiInfo":_wifiInfo,
                        "accelerometer":_accelerometer,
                        "gyroscope":_gyroscope,
                        "packageName":getPackageName(),
                        "os":"IOS",
                        "osVersion":getOSVersion(),
                        "appVersion":getAppVersion()]
          
            mGetDeviceInfoCallback(params)
        }
    }

    private func encryptAES256(value: String ,seckey: String) -> String {
        do {
            let idx1 = seckey.index(seckey.startIndex, offsetBy: 31)
            let idx2 = seckey.index(seckey.startIndex, offsetBy: 15)
            let skey = String(seckey[...idx1])
            let siv = String(seckey[...idx2])
            
            let key : [UInt8] = Array(skey.utf8)
            let iv : [UInt8] = Array(siv.utf8)
            let aes = try AES(key: key, blockMode: CBC(iv:iv), padding: .pkcs5)
            let enc = try aes.encrypt(Array(value.utf8))
            
            return enc.toBase64()!
        } catch {
            return "error"
        }
    }
    
    private func getAudioMode() -> String{
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            if (session.outputVolume <= 0 ){
                return "OFF"
            }
            else{
                return "ON"
            }
            
        } catch {
            return "Error audio"
        }
    }
    
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

