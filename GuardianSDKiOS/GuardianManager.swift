//
//  GuardianManager.swift
//  GuardianFramework
//
//  Created by fns_mac_pro on 19/09/2019.
//  Copyright © 2019 fns_mac_pro. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift
import CoreMotion
import AVFoundation





//public let API_ERROR = 10001
//let USER_STATUS_MEMBER_NOT_REGISTER = 2007
//let USER_STATUS_MEMBER_DEVICE_NOT_REGISTER = 2008
//let USER_STATUS_MEMBER_AUTH_PROCESSING = 2010
//
//let USER_STATUS_MEMBER_FIND_AUTH_TYPE_FAIL = 3000
//let USER_STATUS_MEMBER_FIND_ICON_SELECT_FAIL = 3001
//let USER_STATUS_MEMBER_FIND_PERSONAL_INFO_AGREE_FAIL = 3002
//let USER_STATUS_MEMBER_FIND_UUID_INFO_AGREE_FAIL = 3003
//let USER_STATUS_MEMBER_FIND_FCM_TOKEN_FAIL = 3009
//let USER_STATUS_MEMBER_AUTH_NORMAL = 3004
//let USER_STATUS_MEMBER_STATUS_UNAPPROVAL = 5005
//let USER_STATUS_MEMBER_STATUS_TEMP = 5006
//let USER_STATUS_MEMBER_STATUS_PERM = 5007
//let USER_STATUS_MEMBER_STATUS_WITHDRAW = 5008

open class GuardianManager{
    
    let domain = "https://appbsa.tabgdc.com"
//    let domain = "https://labtest.fnsvalue.co.kr"
    //let domain = "https://lab.fnsvalue.co.kr:9200"
    let apiDomain : String
    
    public init(){
        self.apiDomain = "\(self.domain)/api/v2/"
    }
    
//    open func testAlamofire()-> Void {
//        print("testAlamofire")
//        let url = "https://lab.fnsvalue.co.kr/api/app/version"
//        let parsms = ["lang":"ko"]
//        
//        Alamofire.request(url,method: .post,parameters: parsms,encoding: JSONEncoding.default)
//            .responseJSON{ response in
//                guard response.result.isSuccess else {
//                    NSLog("Error")
//                    return
//                }
//                
//                if let data = response.result.value as? [String:Any]{
//                    print(data)
//                }
//        }
//        
//    }
    
//    open func updateToken(userKey: String, token: String, updateTokenCallBack: @escaping(UpdateTokenState,Int)-> Void ){
//        if(userKey == ""){
//            updateTokenCallBack(UpdateTokenState.error,USER_STATUS_MEMBER_NOT_REGISTER)
//            return
//        }
//
//        if (token == ""){
//            updateTokenCallBack(UpdateTokenState.tokenNull,USER_STATUS_MEMBER_FIND_FCM_TOKEN_FAIL)
//        } else {
//            var params = ["userKey":userKey,
//                          "deviceId":getUUid(),
//                          "token":token,
//                          "packageName":getPackageName(),
//                          "os":"IOS",
//                          "osVersion":getOSVersion(),
//                          "appVersion":getAppVersion()
//            ]
//            let api = "member/token/update"
//            postAPI(params: params, api: api, errorCallBack: { () -> Void in
//
//            }, successCallBack: {(data:[String:Any]) -> Void in
//                print(data)
//                let errorCode = data["rtCode"] as! Int
//                let errorMsg = (data["rtMsg"] as? String) ?? "정상적인 데이터가 아닙니다.".localized
//                if (errorCode == 0){
//                    updateTokenCallBack(UpdateTokenState.success,0)
//                } else {
//                    updateTokenCallBack(UpdateTokenState.error,errorCode)
//                }
//            })
//        }
//
//
//    }
    
//    open func getMember(userKey:String , memberCallBack: @escaping(MemberState,String)-> Void){
//        let params = ["deviceId":getUUid(),
//                        "packageName":getPackageName(),
//                        "userKey":userKey,
//                        "os":"IOS"]
//        let api = "member"
//
//        postAPI(params: params, api: api, errorCallBack: { () -> Void in
//            memberCallBack(MemberState.error,"Error")
//        }, successCallBack: {(data:[String:Any]) -> Void in
//            print(data)
//            let rtCode = data["rtCode"] as! Int
//            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
//
//            if (rtCode == 0){
//                guard let member = data["data"] as? [String:Any] else {
//                    memberCallBack(MemberState.notExist, rtMsg)
//                    return
//                }
//
//                let userKey = member["userKey"]
//                let ud = UserDefaults.standard
//                ud.set(userKey,forKey: USER_KEY)
//
//                let userTotalStatus = member["userTotalStatus"] as! Int
//                if (userTotalStatus ==  USER_STATUS_MEMBER_AUTH_NORMAL){
//                    memberCallBack(MemberState.normal, rtMsg)
//                } else if(userTotalStatus ==  USER_STATUS_MEMBER_AUTH_PROCESSING){
//                    AuthData.channelKey = member["channelKey"] as! String
//                    AuthData.blockKey = member["blockKey"] as! String
//                    memberCallBack(MemberState.authProcessing, rtMsg)
//                } else if(userTotalStatus ==  USER_STATUS_MEMBER_DEVICE_NOT_REGISTER){
//                    memberCallBack(MemberState.notExistDeviceInfo, rtMsg)
//                } else if(userTotalStatus == USER_STATUS_MEMBER_FIND_AUTH_TYPE_FAIL
//                    || userTotalStatus == USER_STATUS_MEMBER_FIND_ICON_SELECT_FAIL
//                    || userTotalStatus == USER_STATUS_MEMBER_FIND_UUID_INFO_AGREE_FAIL
//                    || userTotalStatus == USER_STATUS_MEMBER_FIND_PERSONAL_INFO_AGREE_FAIL){
//                    memberCallBack(MemberState.additionalInfoReg, rtMsg)
//                } else if(userTotalStatus == USER_STATUS_MEMBER_STATUS_UNAPPROVAL
//                    || userTotalStatus == USER_STATUS_MEMBER_STATUS_PERM
//                    || userTotalStatus == USER_STATUS_MEMBER_STATUS_TEMP
//                    || userTotalStatus == USER_STATUS_MEMBER_STATUS_WITHDRAW){
//                    memberCallBack(MemberState.unavailable, rtMsg)
//                } else if(userTotalStatus == USER_STATUS_MEMBER_FIND_FCM_TOKEN_FAIL){
//                    memberCallBack(MemberState.notExistFcmToken, rtMsg)
//                }
//            } else if(rtCode == USER_STATUS_MEMBER_NOT_REGISTER){
//                memberCallBack(MemberState.notExist, rtMsg)
//            } else {
//                memberCallBack(MemberState.error, "\(rtCode)")
//            }
//
//        })
//    }
    
//    open func getMember(memberCallBack: @escaping(MemberState,String)-> Void){
//        let params = ["deviceId":getUUid(),
//                        "packageName":getPackageName(),
//                        "os":"IOS"]
//        let api = "member"
//
//
//        postAPI(params: params, api: api, errorCallBack: { () -> Void in
//            memberCallBack(MemberState.error,"Error")
//        }, successCallBack: {(data:[String:Any]) -> Void in
//            print(data)
//            let rtCode = data["rtCode"] as! Int
//            let rtMsg = (data["rtMsg"] as? String) ?? "rtMsg"
//
//            if (rtCode == 0){
//                guard let member = data["data"] as? [String:Any] else {
//                    memberCallBack(MemberState.notExist, rtMsg)
//                    return
//                }
//
//                let userTotalStatus = member["userTotalStatus"] as! Int
//
//                let userKey = member["userKey"]
//                let ud = UserDefaults.standard
//                ud.set(userKey,forKey: USER_KEY)
//
//
//                if (userTotalStatus ==  USER_STATUS_MEMBER_AUTH_NORMAL){
//                    memberCallBack(MemberState.normal, rtMsg)
//                }else if(userTotalStatus ==  USER_STATUS_MEMBER_AUTH_PROCESSING){
//                    AuthData.channelKey = member["channelKey"] as! String
//                    AuthData.blockKey = member["blockKey"] as! String
//                    memberCallBack(MemberState.authProcessing, rtMsg)
//                } else if(userTotalStatus ==  USER_STATUS_MEMBER_DEVICE_NOT_REGISTER){
//                    memberCallBack(MemberState.notExistDeviceInfo, rtMsg)
//                } else if(userTotalStatus == USER_STATUS_MEMBER_FIND_AUTH_TYPE_FAIL
//                    || userTotalStatus == USER_STATUS_MEMBER_FIND_ICON_SELECT_FAIL
//                    || userTotalStatus == USER_STATUS_MEMBER_FIND_UUID_INFO_AGREE_FAIL
//                    || userTotalStatus == USER_STATUS_MEMBER_FIND_PERSONAL_INFO_AGREE_FAIL){
//                    memberCallBack(MemberState.additionalInfoReg, rtMsg)
//                } else if(userTotalStatus == USER_STATUS_MEMBER_STATUS_UNAPPROVAL
//                    || userTotalStatus == USER_STATUS_MEMBER_STATUS_PERM
//                    || userTotalStatus == USER_STATUS_MEMBER_STATUS_TEMP
//                    || userTotalStatus == USER_STATUS_MEMBER_STATUS_WITHDRAW){
//                    memberCallBack(MemberState.unavailable, rtMsg)
//                } else if(userTotalStatus == USER_STATUS_MEMBER_FIND_FCM_TOKEN_FAIL){
//                    memberCallBack(MemberState.notExistFcmToken, rtMsg)
//                }
//            } else if(rtCode == USER_STATUS_MEMBER_NOT_REGISTER){
//                memberCallBack(MemberState.notExist, rtMsg)
//            } else {
//                memberCallBack(MemberState.error, "\(rtCode)")
//            }
//        })
//    }
    
//    open func registerDevice(userKey:String,authType:String,iconSelect:String ,joinMemberCallback:@escaping(Int) -> Void){
//        
//        let packageName = Bundle.main.bundleIdentifier as? String ?? ""
//        let deviceId =  "\(packageName)\(UIDevice.current.identifierForVendor!.uuidString)"
//        KeychainService.updatePassword(service: packageName, account:"deviceId",data:deviceId)
//        
//        let deviceInfo = DeviceInfo()
//        deviceInfo.getDeviceInfo(userKey: userKey) { (data:Dictionary<String, String>) in
//            let api = "device/member/register"
//            var params = data
//            params["authType"] = authType
//            params["iconSelect"] = iconSelect
//            
//            self.postAPI(params: params, api: api, errorCallBack: { () -> Void in
//               joinMemberCallback(API_ERROR)
//            }, successCallBack: {(data:[String:Any]) -> Void in
//                print(data)
//                let rtCode = data["rtCode"] as! Int
//                let rtMsg = (data["rtMsg"] as? String) ?? "정상적인 데이터가 아닙니다.".localized
//                
//                if(rtCode == 0){
//                    joinMemberCallback(0)
//                    let ud = UserDefaults.standard
//                    ud.set(userKey,forKey: USER_KEY)
//                } else {
//                    joinMemberCallback(rtCode)
//                }
//                
//            })
//
//        }
//    }
    
//    open func registerDevice(userKey:String, joinMemberCallback:@escaping(Int) -> Void){
//
//        let deviceInfo = DeviceInfo()
//        deviceInfo.getDeviceInfo(userKey: userKey) { (data:Dictionary<String, String>) in
//            let api = "device/member/register"
//
//            self.postAPI(params: data, api: api, errorCallBack: { () -> Void in
//               joinMemberCallback(API_ERROR)
//            }, successCallBack: {(data:[String:Any]) -> Void in
//                print(data)
//                let rtCode = data["rtCode"] as! Int
//                let rtMsg = (data["rtMsg"] as? String) ?? "정상적인 데이터가 아닙니다.".localized
//
//
//                if(rtCode == 0){
//                    joinMemberCallback(0)
//                    let ud = UserDefaults.standard
//                    ud.set(userKey,forKey: USER_KEY)
//
//                } else {
//                    joinMemberCallback(rtCode)
//                }
//
//            })
//
//        }
//    }
    
//    open func requestAuth(userKey:String, authRequestAccessType:String, requestAuthCallBack: @escaping(Int) -> Void){
//        var params = ["lang":getLang(),
//                      "userKey":userKey,
//                      "packageName":getPackageName(),
//                      "deviceId":getUUid(),
//                      "os":"IOS",
//                      "accessType":AUTH_REQUEST_ACCESS_TYPE_HYBRID]
//
//        let api = "auth/request/app"
//
//        postAPI(params: params, api: api, errorCallBack: {
//            requestAuthCallBack(API_ERROR)
//        }) { (data:[String : Any]) in
//            let rtCode = data["rtCode"] as! Int
//            let rtMsg = (data["rtMsg"] as? String) ?? "정상적인 데이터가 아닙니다."
//
//            if (rtCode == 0){
//                guard let member = data["data"] as? [String:Any] else {
//                    requestAuthCallBack(API_ERROR)
//                    return
//                }
//                let userKey = member["userKey"]
//                let ud = UserDefaults.standard
//                ud.set(userKey,forKey: USER_KEY)
//
//                AuthData.channelKey = member["channelKey"] as! String
//                AuthData.blockKey = member["blockKey"] as! String
//                requestAuthCallBack(0)
//
//            } else {
//                requestAuthCallBack(rtCode)
//            }
//        }
//    }
    
//    open func postAPI(params: Dictionary<String,String>, api: String, errorCallBack: @escaping() -> Void,successCallBack : @escaping([String:Any]) -> Void){
//        
//        let url = "\(apiDomain)\(api)"
//        print(params)
//        print(url)
//        
//        Alamofire.request(url,method: .post,parameters: params,encoding: JSONEncoding.default)
//            .responseJSON{ response in
//                guard response.result.isSuccess else {
//                    errorCallBack()
//                    return
//                }
//                
//                if let data = response.result.value as? [String:Any]{
//                    successCallBack(data)
//                }
//        }
//    }
    
    
    
    

    
    
//    class DeviceInfo {
//        var userKey = ""
//        var authCode: String!
//        //var bthOnOff = "OFF"
//        var audioMode: String!
//        var phoneNum: String!
//        let altimeter = CMAltimeter()
//        let motionManager = CMMotionManager()
//
//        var magnetic = "magnetic"
//        var orientation  = "orientation"
//        var gyroscope  = "gyroscope"
//        var acceleration  = "acceleration"
//        var light  = "altimeter"
//        var checkCount = 0;
//
//
//        var mGetDeviceInfoCallback :(Dictionary<String,String>) -> Void = {_ in }
//
//        public init(){
//            userKey = getUserKey()
//        }
//
//        public func getDeviceInfo(userKey:String ,getDeviceInfoCallback:@escaping(Dictionary<String,String>) -> Void){
//            self.userKey = userKey
//            if motionManager.isDeviceMotionAvailable {
//                motionManager.deviceMotionUpdateInterval = 0.1
//                motionManager.startDeviceMotionUpdates(to: OperationQueue.current!){ (motion,error) in
//                    self.outputMotion(data: motion)
//                }
//            } else {
//                checkCount += 1
//            }
//
//            //가속도 센서
//            if motionManager.isAccelerometerAvailable {
//                motionManager.accelerometerUpdateInterval = 0.1
//                motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {accelerometerData, error in self.outputAccelerationData(data: (accelerometerData?.acceleration)!)
//                })
//            }  else {
//                checkCount += 1
//            }
//            //자이로 센서
//            if motionManager.isGyroAvailable {
//                motionManager.gyroUpdateInterval = 0.1
//                motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
//                    self.outputGyroData(data: (data?.rotationRate)!)
//                }
//            }  else {
//                checkCount += 1
//            }
//
//            //지자기 센서
//            if motionManager.isMagnetometerAvailable {
//                motionManager.magnetometerUpdateInterval = 0.1
//                motionManager.startMagnetometerUpdates(to : OperationQueue.current!) { (data, error) in
//                    self.outputMagneticData(data: (data?.magneticField)!)
//                }
//            }  else {
//                checkCount += 1
//            }
//
//            //기압
//            if CMAltimeter.isRelativeAltitudeAvailable() {
//                altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
//                    var a = data?.relativeAltitude.stringValue
//                    var b = data?.pressure.stringValue
//                    self.light = "\(a!)|\(b!)"
//                    self.stopAltimeter();
//                }
//            }  else {
//                checkCount += 1
//            }
//            mGetDeviceInfoCallback = getDeviceInfoCallback
//        }
//
//        func callCheck(){
//            if (checkCount == 5) {
//                NSLog("data set!")
//                NSLog("data \(magnetic)")
//                NSLog("data \(gyroscope)")
//                NSLog("data \(acceleration)")
//                NSLog("data \(orientation)")
//                NSLog("data \(light)")
//
//                self.setCallback()
//
//            } else {
//                NSLog("data not set!")
//
//            }
//        }
//
//        func stopAltimeter(){
//            checkCount += 1
//            callCheck()
//            altimeter.stopRelativeAltitudeUpdates()
//        }
//
//        func outputMotion(data: CMDeviceMotion?){
//            let radians = atan2((data?.gravity.x)!, (data?.gravity.y)!) - .pi
//            let degrees = radians * 180.0  / .pi
//
//            orientation = String(format: "%.2f", degrees)
//            checkCount += 1
//            callCheck()
//            motionManager.stopDeviceMotionUpdates()
//        }
//
//        func outputMagneticData(data : CMMagneticField){
//
//            magnetic = "\(String(format: "%.2f", data.x))|\(String(format: "%.2f", data.y))|\(String(format: "%.2f", data.z))"
//            checkCount += 1
//            callCheck()
//            motionManager.stopMagnetometerUpdates()
//        }
//
//        func outputGyroData(data: CMRotationRate){
//
//            gyroscope = "\(String(format: "%.2f", data.x))|\(String(format: "%.2f", data.y))|\(String(format: "%.2f", data.z))"
//            checkCount += 1
//            callCheck()
//            motionManager.stopGyroUpdates()
//        }
//
//        func outputAccelerationData(data: CMAcceleration){
//
//            acceleration = "\(String(format: "%.2f", data.x))|\(String(format: "%.2f", data.y))|\(String(format: "%.2f", data.z))"
//            checkCount += 1
//            callCheck()
//            motionManager.stopAccelerometerUpdates();
//        }
//
//        func setCallback(){
//            let securityKey = "FNSVALUEfnsvalueFNSVALUEfnsvalue"
//
//
//            var _proximity = "proximity \(Date().currentTimeMillis())"
//            var _light = "\(light) \(Date().currentTimeMillis())"
//            var _magnetic = "\(magnetic) \(Date().currentTimeMillis())"
//            var _orientation = "\(orientation) \(Date().currentTimeMillis())"
//            var _audioInfo = "audioInfo \(Date().currentTimeMillis())"
//            var _audioMode = "\(getAudioMode()) \(Date().currentTimeMillis())"
//            var _macAddr = "macAddr \(Date().currentTimeMillis())"
//            var _bthAddr = "bthAddr \(Date().currentTimeMillis())"
//            var _wifiInfo = "wifiInfo \(Date().currentTimeMillis())"
//            var _accelerometer = "\(acceleration) \(Date().currentTimeMillis())"
//            var _gyroscope = "\(gyroscope) \(Date().currentTimeMillis())"
//
//            _proximity = encryptAES256(value:_proximity,seckey: securityKey)
//            _light = encryptAES256(value:_light,seckey: securityKey)
//            _magnetic = encryptAES256(value:_magnetic,seckey: securityKey)
//            _orientation = encryptAES256(value:_orientation,seckey: securityKey)
//            _audioInfo = encryptAES256(value:_audioInfo,seckey: securityKey)
//            _audioMode = encryptAES256(value:_audioMode,seckey: securityKey)
//            _macAddr = encryptAES256(value:_macAddr,seckey: securityKey)
//            _bthAddr = encryptAES256(value:_bthAddr,seckey: securityKey)
//            _wifiInfo = encryptAES256(value:_wifiInfo,seckey: securityKey)
//            _accelerometer = encryptAES256(value:_accelerometer,seckey: securityKey)
//            _gyroscope = encryptAES256(value:_gyroscope,seckey: securityKey)
//
//            var params = [
//                        "userKey":userKey,
//                        "phoneNum":phoneNum ?? "",
//                        "authCode":authCode ?? "",
//                        "lang":getLang(),
//                        "proximity":_proximity,
//                        "light":_light,
//                        "magnetic":_magnetic,
//                        "orientation":_orientation,
//                        "audioInfo":_audioInfo,
//                        "audioMode":_audioMode,
//                        "deviceId":getUUid(),
//                        "macAddr":_macAddr,
//                        "bthAddr":_bthAddr,
//                        "wifiInfo":_wifiInfo,
//                        "accelerometer":_accelerometer,
//                        "gyroscope":_gyroscope,
//                        "packageName":getPackageName(),
//                        "os":"IOS",
//                        "osVersion":getOSVersion(),
//                        "appVersion":getAppVersion()]
//
//            if (self.authCode == ""){
//                NSLog("authCode\(self.authCode)")
//                params["authCode"] = nil
//            }
//
//            if(params["authCode"] == ""){
//                NSLog("authCode\(params["authCode"])")
//                params["authCode"] = nil
//            }
//
//
//
//            //print(params)
//
//            mGetDeviceInfoCallback(params)
//        }
//
//    }

    
}



