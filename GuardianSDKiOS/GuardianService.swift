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
import SwiftyJSON
import DeviceKit

public enum RtCode : Int {
    case AUTH_SUCCESS = 0
    case AUTH_PROCESSING = 2010
  
    case PUSH_LOGIN = 1000; // 로그인 푸시
    case PUSH_LOGIN_CANCEL = 1001; // 로그인 취소 푸시
    case PUSH_LOGIN_SUCCESS = 1002; // 로그인 성공 푸시
    case PUSH_LOGIN_FAIL = 1003; // 로그인 실패 푸시
    case PUSH_VERIFICATION_1 = 1004; // 첫번째 검증요청 푸시
    case PUSH_VERIFICATION_2 = 1005; // 두번째 검증요청 푸시
    
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
    
    case BIOMETRIC_NORMAL = 9000
    case BIOMETRIC_NOT_AVILABLE = 9001
    case BIOMETRIC_LOCK_OUT = 9002
    case BIOMETRIC_NOT_SUPPORT_HARDWARE = 9003
    case BIOMETRIC_NOT_ENROLLED_DEVICE = 9004
    case BIOMETRIC_NOT_ENROLLED_APP = 9005
    case BIOMETRIC_CHANGE_ENROLLED = 9006
    case BIOMETRIC_ENROLLED_DUPLICATION = 9007
    case BIOMETRIC_ERROR = 9008
    case BIOMETRIC_AUTH_FAILED = 9009
    case BIOMETRIC_PASSCODE = 9010
    
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

public enum AuthStatus : String {
    /**
     * 인증시작 요청 by Web
     */
    case REQUEST_AUTH = "RequestAuth"
    /**
     * 채널 생성
     */
    case CREATE_CHANNEL = "CreateChannel"
    /**
     * 검증노드 선정
     */
    case SELECT_NODES = "SelectNodes"
    /**
     * 인증시작 by App
     */
    case START_AUTH = "StartAuth"
    /**
     * 노드검증 시작
     */
    case START_VERIFICATION_OF_NODES = "StartVerificationOfNodes"
    /**
     * 노드검증 완료
     */
    case COMPLETE_VERIFICATION_OF_NODES = "CompleteVerificationOfNodes"
    /**
     * 취소 요청 by App/Web
     */
    case REQUEST_CANCEL = "RequestCancel"
    /**
     * 인증취소(완료) by App/Web
     */
    case AUTH_CANCELED = "AuthCanceled"
    /**
     * 인층실패(완료)
     */
    case AUTH_FAILED = "AuthFailed"
    /**
     * 인증성공(완료)
     */
    case AUTH_COMPLETED = "AuthCompleted"
    /**
     *  인증 시간 초과
     */
    case AUTH_TIMEOUT = "AuthTimeout"

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

func getLang() -> String {
    let prefferedLanguage = Locale.preferredLanguages[0] as String
    let arr = prefferedLanguage.components(separatedBy: "-")
    return arr.first!
}

func getUUid() -> String {
    let packageName = getPackageName()
    let deviceId =  "\(packageName)\(UIDevice.current.identifierForVendor!.uuidString)"
    let encryptDeivceId = encryptAES256(value: deviceId, seckey: packageName)
    let trimStr = encryptDeivceId.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimStr
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

public protocol AuthObserver: class {
    func onAuthentication(status : String)
}

public class GuardianService{
        
    public static let sharedInstance = GuardianService()
    
    public var _authRequestSuccess : (RtCode, String, Int, String, String, String) -> Void
    public var _authRequestProcess : (String) -> Void
    public var _authRequestFailed : (RtCode, String) -> Void
    public var _onSubscribeAuthStatus : (String) -> Void
    
    private init() {
        func initOnSuccess(rtcode: RtCode, rtMsg: String, authType: Int, connectIp: String, userKey: String, clientKey: String) -> Void{}
        func initOnProcess(status : String) -> Void{}
        func initOnFailed(rtcode: RtCode, rtMsg: String) -> Void{}
        func initOnSubscribeAuthStatus(status : String) -> Void{}
        
        self._authRequestSuccess = initOnSuccess
        self._authRequestProcess = initOnProcess
        self._authRequestFailed = initOnFailed
        self._onSubscribeAuthStatus = initOnSubscribeAuthStatus
    }
    
    var authTimeoutTimer = Timer()
    
    var observers = [AuthObserver]()
    
    public struct Domain {
        public static var baseUrl = ""
        public static var apiDomain = ""
    }
    
    public func getBaseUrl() -> String {
        return Domain.baseUrl
    }
    
    private static var _userKey : String = ""
    public var userKey : String {
        get  {
            return GuardianService._userKey
        }
        set(value) {
            GuardianService._userKey = value
        }
    }
    
    private static var _clientKey : String = ""
    public var clientKey : String {
        get  {
            return GuardianService._clientKey
        }
        set(value) {
            GuardianService._clientKey = value
        }
    }
    
    private static var _authType : Int = 0
    public var authType : Int {
        get {
            return GuardianService._authType
        }
        set(value) {
            GuardianService._authType = value
        }
    }
    
    private static var _connectIp : String = ""
    public var connectIp : String {
        get {
            return GuardianService._connectIp
        }
        set(value) {
            GuardianService._connectIp = value
        }
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
    
    public func initDomain(baseUrl :String, apiUrl : String ) {
        print("initDomain")
        Domain.baseUrl = baseUrl
        Domain.apiDomain = apiUrl
    }
    
    public func initClientKey(clientKey: String) {
        self.clientKey = clientKey
    }
    
    public func addObserver(_ observer: AuthObserver) {
        observers.append(observer)
    }
    
    public func removeObserver(_ observer: AuthObserver) {
        observers = observers.filter({ $0 !== observer })
    }
    
    public func notifyAuthStatus(status : String) {
      self._onSubscribeAuthStatus(status)
    }
  
    public func addSubscribeCallback(subscribe: @escaping(String) -> Void) {
      self._onSubscribeAuthStatus = subscribe
    }
    
    public func onFcmMessageHandle(messageDic : Dictionary<String,String>, callback: @escaping(RtCode, String) -> Void) {
      if let strTarget = messageDic["target"] {
          let target = Int(strTarget)
          switch target {
          case RtCode.PUSH_LOGIN.rawValue:
              self.channelKey = messageDic["channel_key"] ?? ""
              self.blockKey = messageDic["block_key"] ?? ""
              callback(RtCode.AUTH_SUCCESS, "")
          case RtCode.PUSH_LOGIN_SUCCESS.rawValue:
            self._authRequestSuccess(RtCode.AUTH_SUCCESS, "", self.authType, self.connectIp, self.userKey, self.clientKey)
          case RtCode.PUSH_LOGIN_FAIL.rawValue:
            self._authRequestFailed(RtCode.AUTH_FAIL, "")
//          case RtCode.PUSH_LOGIN_CANCEL.rawValue:
//              callback(RtCode.AUTH_CANCEL, LocalizationMessage.sharedInstance.getLocalization(code: RtCode.AUTH_CANCEL.rawValue) ?? "")
          default:
              print("")
          }
      }
    
    }
    
    public func requestMember(onSuccess: @escaping(RtCode, String, [String:String])-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "device/check"
        var params = getCommonParam()
        params["deviceId"] = getUUid()

        self.callHttpGet(params: params, api: apiUrl, successCallBack: {(data: JSON) -> Void in
                
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            guard let authData = data["data"] as? JSON else {
                onFailed(RtCode.API_ERROR, rtMsg)
                return
            }
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue) {
                var dic = [String:String]()
                dic["userKey"] = authData["userKey"].string ?? ""
                dic["name"] = authData["name"].string ?? ""
                dic["email"] = authData["email"].string ?? ""
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg, dic)
            } else if(rtCode == RtCode.MEMBER_NOT_REGISTER.rawValue){
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestClients(onSuccess: @escaping(RtCode, String, Array<[String:String]>)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "clients"
        var params = getCommonParam()
        params["deviceId"] = getUUid()
        
        self.callHttpGet(params: params, api: apiUrl, successCallBack: {(data: JSON) -> Void in
                
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue) {
                var returnValue = Array<[String:String]>()
                let size = data["data"].count
                for i in 0..<size {
                    let client = data["data"].arrayValue[i]
                    var dic = [String:String]()
                    dic["clientName"] = client["clientName"].string ?? ""
                    dic["clientKey"] = client["clientKey"].string ?? ""
                    returnValue.append(dic)
                }
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg, returnValue)
            } else {
                onFailed(RtCode.API_ERROR, "\(rtCode)")
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
        
    }
    
    public func requestTokenUpdate(token : String, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "me/token"
        
        var params = getCommonParam()
        params["deviceId"] = getUUid()
        params["token"] = token
        params["osVersion"] = getOSVersion()
        params["appVersion"] = getAppVersion()
        
        self.callHttpPut(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
            
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            if(rtCode == RtCode.AUTH_SUCCESS.rawValue) {
                onSuccess(RtCode(rawValue: rtCode)!, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestAuthRequest(onSuccess: @escaping(RtCode, String, Int, String, String, String)-> Void, onProcess: @escaping(String) -> Void,  onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "auth/nodes"
        
        let enCodeCK = encryptAES256(value: self.channelKey, seckey: self.channelKey)
        let enCodeBK = encryptAES256(value: self.blockKey, seckey: self.channelKey)
        let enCodeDK = encryptAES256(value: getUUid(), seckey: self.channelKey)
        
        var params = getCommonParam()
        params["deviceId"] = getUUid()
        params["enCodeCK"] = enCodeCK
        params["enCodeBK"] = enCodeBK
        params["enCodeDK"] = enCodeDK
        
        // WebSocket 연결.
        var socketDataMap = getCommonParam()
        socketDataMap["channelKey"] = self.channelKey
        socketDataMap["deviceId"] = getUUid()
        
        StompSocketService.sharedInstance.connect(dataMap: socketDataMap, connectCallback: {(isConnect: Bool) -> Void in
            if isConnect {
                print("stompwebsocket connect")
                StompSocketService.sharedInstance.subscribe(authProcessCallback: {(status : String?) -> Void in
                    print("stompwebsocket subscribe => \(status!)")
                    
//                    self.notifyAuthStatus(status: status!)
                    
                    if status == AuthStatus.COMPLETE_VERIFICATION_OF_NODES.rawValue {
                        self._authRequestSuccess(RtCode.AUTH_SUCCESS, "", self.authType, self.connectIp, self.userKey, self.clientKey)
                    }
                    
                    if status! != AuthStatus.AUTH_COMPLETED.rawValue ||
                        status! != AuthStatus.AUTH_FAILED.rawValue ||
                        status! != AuthStatus.AUTH_CANCELED.rawValue {
                        
                        self._authRequestProcess(status!) //authRequest callback.
                    }
                    
                    if status! == AuthStatus.AUTH_COMPLETED.rawValue || status! == AuthStatus.AUTH_FAILED.rawValue {
                        StompSocketService.sharedInstance.disconnect()
                        self.invalidateAuthTimeoutTimer()
                    }
                })
            } else {
                print("stompwebsocket disconnect")
            }
        })
        
        self._authRequestSuccess = onSuccess
        self._authRequestProcess = onProcess
        self._authRequestFailed = onFailed
        
        self._authRequestProcess(AuthStatus.CREATE_CHANNEL.rawValue)
        
        self.callHttpPost(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
            
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                guard let authData = data["data"] as? JSON else {
                    onFailed(RtCode.API_ERROR, rtMsg)
                    return
                }
                
                self._authRequestProcess(AuthStatus.SELECT_NODES.rawValue)
                
                self.authType = authData["authType"].intValue
                self.connectIp = authData["connectIp"].string ?? ""
                self.userKey = authData["userKey"].string ?? ""
                let authTimeRemaining = authData["authTimeRemaining"].doubleValue
                
                // Auth Timer start
                self.executeAuthTimeoutTimer(authTimeRemaining : authTimeRemaining)
                
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    private func executeAuthTimeoutTimer(authTimeRemaining : Double) {
        let authTimeout = authTimeRemaining / 1000
        self.authTimeoutTimer = Timer.scheduledTimer(withTimeInterval: authTimeout, repeats: false, block: { timer in
            self.notifyAuthStatus(status : AuthStatus.AUTH_TIMEOUT.rawValue)
        })
    }
   
    private func invalidateAuthTimeoutTimer() {
        self.authTimeoutTimer.invalidate()
    }
    
    public func requestAuthResult(onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "auth/complete"
        
        var params = getCommonParam()
        params["deviceId"] = getUUid()
        
        self.callHttpPost(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
            
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            
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
        let apiUrl = "auth"
        
        var params = getCommonParam()
        params["deviceId"] = getUUid()
        
        self.callHttpDelete(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue) {
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    public func requestMemberRegister(memberObject : Dictionary<String, Any>, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
      
        let packageName = getPackageName()
        let deviceId =  "\(packageName)\(UIDevice.current.identifierForVendor!.uuidString)"
        KeychainService.updatePassword(service: packageName, account:"deviceId",data:deviceId)
      
        DispatchQueue.main.async {
          DeviceInfoService().getDeviceInfo{ (data:Dictionary<String, Any>) in
              let apiUrl = "users"
            
              var params = data
              
              let commonParam = self.getCommonParam()
              for key in commonParam.keys {
                  params[key] = commonParam[key]
              }
              
              for key in memberObject.keys {
                params[key] = memberObject[key]
              }
              
                params["deviceId"] = getUUid()
                params["appPackage"] = getPackageName()
                params["os"] = "CMMDOS002"
                params["osVersion"] = getOSVersion()
                params["appVersion"] = getAppVersion()
                params["deiceManufacturer"] = "apple"
                params["deviceName"] = Device.current.description
              
              self.callHttpPost(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
                  let rtCode = data["rtCode"].intValue
                  let rtMsg = data["rtMsg"].string ?? ""
                  
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
    }
  
    public func requestReMemberRegister(memberObject : Dictionary<String, Any>, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
      
      let packageName = getPackageName()
      let deviceId =  "\(packageName)\(UIDevice.current.identifierForVendor!.uuidString)"
      KeychainService.updatePassword(service: packageName, account:"deviceId",data:deviceId)
    
      DispatchQueue.main.async {
        DeviceInfoService().getDeviceInfo{ (data:Dictionary<String, Any>) in
            let userKey = memberObject["userKey"] as? String ?? ""
            let apiUrl = "users/\(userKey)/device"
          
            var params = data
            
            let commonParam = self.getCommonParam()
            for key in commonParam.keys {
                params[key] = commonParam[key]
            }
            
            for key in memberObject.keys {
                params[key] = memberObject[key]
            }
            
            params["deviceId"] = getUUid()
            params["appPackage"] = getPackageName()
            params["os"] = "CMMDOS002"
            params["osVersion"] = getOSVersion()
            params["appVersion"] = getAppVersion()
            params["deiceManufacturer"] = "apple"
            params["deviceName"] = Device.current.description
            
            self.callHttpPut(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
                let rtCode = data["rtCode"].intValue
                let rtMsg = data["rtMsg"].string ?? ""
                
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
    }
  
  public func requestAuthSms(phoneNum : String, onSuccess: @escaping(RtCode, String, Int)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
      let apiUrl = "sms"
      var params = getCommonParam()
      params["phoneNum"] = phoneNum
    
      self.callHttpPost(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
          
          let rtCode = data["rtCode"].intValue
          let rtMsg = data["rtMsg"].string ?? ""
        
          guard let authData = data["data"] as? JSON else {
              onFailed(RtCode.API_ERROR, rtMsg)
              return
          }
        
          let seq = authData["seq"].intValue
          
          if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
              onSuccess(RtCode.AUTH_SUCCESS, rtMsg, seq)
          } else {
              self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
          }
          
      }, errorCallBack: {(errorCode, errorMsg) -> Void in
          onFailed(RtCode.API_ERROR, errorMsg)
      })
  }
    
    public func verifySms(phoneNum : String, authNum: String, seq: String,
                          onSuccess: @escaping(RtCode, String, Bool)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
      let apiUrl = "sms/verify"
      var params = getCommonParam()
      params["phoneNum"] = phoneNum
      params["authNum"] = authNum
      params["seq"] = seq
      
      self.callHttpPost(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
          
          let rtCode = data["rtCode"].intValue
          let rtMsg = data["rtMsg"].string ?? ""
        
          guard let verifyData = data["data"] as? JSON else {
              onFailed(RtCode.API_ERROR, rtMsg)
              return
          }
          
          let result = verifyData["result"].boolValue
          
          if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
              onSuccess(RtCode.AUTH_SUCCESS, rtMsg, result)
          } else {
              self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
          }
          
      }, errorCallBack: {(errorCode, errorMsg) -> Void in
          onFailed(RtCode.API_ERROR, errorMsg)
      })
      
    }
    
  public func requestUserCheck(userKey: String, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
      let apiUrl = "me/\(self.clientKey)/member/\(userKey)/check"
      let params = getCommonParam()
    
      self.callHttpGet(params: params, api: apiUrl, successCallBack: {(data: JSON) -> Void in
              
          let rtCode = data["rtCode"].intValue
          let rtMsg = data["rtMsg"].string ?? ""
          
          if (rtCode == RtCode.AUTH_SUCCESS.rawValue) {
              onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
          } else {
              onFailed(RtCode.API_ERROR, "\(rtCode)")
          }
          
      }, errorCallBack: {(errorCode, errorMsg) -> Void in
          onFailed(RtCode.API_ERROR, errorMsg)
      })
    }
    
    public func requestVerifyIcon(icons: String, onSuccess: @escaping(RtCode, String)-> Void, onFailed: @escaping(RtCode, String)-> Void) {
        let apiUrl = "auth/verify/icon"
        
        var params = getCommonParam()
        params["deviceId"] = getUUid()
        params["iconSelect"] = icons
        
        self.callHttpPost(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
            
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            
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
        let apiUrl = "auth/verify/finger/fail"
        
        var params = getCommonParam()
        params["deviceId"] = getUUid()
        
        self.callHttpPost(params: params, api: apiUrl, successCallBack: {(data:JSON) -> Void in
            
            let rtCode = data["rtCode"].intValue
            let rtMsg = data["rtMsg"].string ?? ""
            
            if (rtCode == RtCode.AUTH_SUCCESS.rawValue){
                onSuccess(RtCode.AUTH_SUCCESS, rtMsg)
            } else {
                self.onCallbackFailed(rtCode: RtCode(rawValue: rtCode)!, onFailed: onFailed)
            }
            
        }, errorCallBack: {(errorCode, errorMsg) -> Void in
            onFailed(RtCode.API_ERROR, errorMsg)
        })
    }
    
    private func callHttpGet(params: Dictionary<String,String>,
                            api: String,
                            successCallBack : @escaping(JSON) -> Void,
                            errorCallBack: @escaping(Int, String) -> Void) {
        
        let url = Domain.apiDomain + api
        print("callHttpGet url => \(url)")
        
        Alamofire.request(url,method: .get ,parameters: params)
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    var statusCode : Int! = response.response?.statusCode ?? RtCode.API_ERROR.rawValue
                    var statusMessage : String
                    if let error = response.result.error as? AFError {
                        statusCode = error._code // statusCode private
                        switch error {
                        case .invalidURL(let url):
                            statusMessage = "Invalid URL"
                        case .parameterEncodingFailed(let reason):
                            statusMessage = "Parameter encoding failed"
                        case .multipartEncodingFailed(let reason):
                            statusMessage = "Multipart encoding failed"
                        case .responseValidationFailed(let reason):
                            statusMessage = "Response validation failed"
                            statusMessage = "Failure Reason"
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
                            statusMessage = "Failure Reason"
                            // statusCode = 3840 ???? maybe..
                        }
//                        statusMessage = "Underlying error: \(error.underlyingError)"
                        statusMessage = "Underlying error"
                    } else if let error = response.result.error as? URLError {
//                        statusMessage = "URLError occurred: \(error)"
                        statusMessage = url
                    } else {
//                        statusMessage = "Unknown error: \(response.result.error)"
                        statusMessage = "Unknown error"
                    }

                    errorCallBack(statusCode, statusMessage)
                    return
                }
                
                if let data = response.result.value {
                    let json = JSON(data)
                    successCallBack(json)
                }
        }
    }
    
    private func callHttpPost(params: Dictionary<String,Any>,
                            api: String,
                            successCallBack : @escaping(JSON) -> Void,
                            errorCallBack: @escaping(Int, String) -> Void) {
        
        let url = Domain.apiDomain + api
        print("callHttpPost url => \(url)")
                
        Alamofire.request(url,method: .post ,parameters: params, encoding: JSONEncoding.default)
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    var statusCode : Int! = response.response?.statusCode ?? RtCode.API_ERROR.rawValue
                    var statusMessage : String
                    if let error = response.result.error as? AFError {
                        statusCode = error._code // statusCode private
                        switch error {
                        case .invalidURL(let url):
                            statusMessage = "Invalid URL"
                        case .parameterEncodingFailed(let reason):
                            statusMessage = "Parameter encoding failed"
                        case .multipartEncodingFailed(let reason):
                            statusMessage = "Multipart encoding failed"
                        case .responseValidationFailed(let reason):
                            statusMessage = "Response validation failed"
                            statusMessage = "Failure Reason"
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
                            statusMessage = "Failure Reason"
                            // statusCode = 3840 ???? maybe..
                        }
//                        statusMessage = "Underlying error: \(error.underlyingError)"
                        statusMessage = "Underlying error"
                    } else if let error = response.result.error as? URLError {
//                        statusMessage = "URLError occurred: \(error)"
                        statusMessage = "URLError occurred"
                    } else {
//                        statusMessage = "Unknown error: \(response.result.error)"
                        statusMessage = "Unknown error"
                    }

                    errorCallBack(statusCode, statusMessage)
                    return
                }
                
                if let data = response.result.value {
                    let json = JSON(data)
                    successCallBack(json)
                }
        }
        
    }
    
    private func callHttpPut(params: Dictionary<String,Any>,
                            api: String,
                            successCallBack : @escaping(JSON) -> Void,
                            errorCallBack: @escaping(Int, String) -> Void) {
        
        let url = Domain.apiDomain + api
        print("callHttpPut url => \(url)")
                        
        Alamofire.request(url,method: .put ,parameters: params, encoding: JSONEncoding.default)
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    var statusCode : Int! = response.response?.statusCode ?? RtCode.API_ERROR.rawValue
                    var statusMessage : String
                    if let error = response.result.error as? AFError {
                        statusCode = error._code // statusCode private
                        switch error {
                        case .invalidURL(let url):
                            statusMessage = "Invalid URL"
                        case .parameterEncodingFailed(let reason):
                            statusMessage = "Parameter encoding failed"
                        case .multipartEncodingFailed(let reason):
                            statusMessage = "Multipart encoding failed"
                        case .responseValidationFailed(let reason):
                            statusMessage = "Response validation failed"
                            statusMessage = "Failure Reason"
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
                            statusMessage = "Failure Reason"
                            // statusCode = 3840 ???? maybe..
                        }
//                        statusMessage = "Underlying error: \(error.underlyingError)"
                        statusMessage = "Underlying error"
                    } else if let error = response.result.error as? URLError {
//                        statusMessage = "URLError occurred: \(error)"
                        statusMessage = "URLError occurred"
                    } else {
//                        statusMessage = "Unknown error: \(response.result.error)"
                        statusMessage = "Unknown error"
                    }

                    errorCallBack(statusCode, statusMessage)
                    return
                }
                
                if let data = response.result.value {
                    let json = JSON(data)
                    successCallBack(json)
                }
        }
    }
    
    private func callHttpDelete(params: Dictionary<String,String>,
                            api: String,
                            successCallBack : @escaping(JSON) -> Void,
                            errorCallBack: @escaping(Int, String) -> Void) {
        
        let url = Domain.apiDomain + api
        print("callHttpDelete url => \(url)")
                                
        Alamofire.request(url,method: .delete ,parameters: params, encoding: JSONEncoding.default)
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    var statusCode : Int! = response.response?.statusCode ?? RtCode.API_ERROR.rawValue
                    var statusMessage : String
                    if let error = response.result.error as? AFError {
                        statusCode = error._code // statusCode private
                        switch error {
                        case .invalidURL(let url):
                            statusMessage = "Invalid URL"
                        case .parameterEncodingFailed(let reason):
                            statusMessage = "Parameter encoding failed"
                        case .multipartEncodingFailed(let reason):
                            statusMessage = "Multipart encoding failed"
                        case .responseValidationFailed(let reason):
                            statusMessage = "Response validation failed"
                            statusMessage = "Failure Reason"
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
                            statusMessage = "Failure Reason"
                            // statusCode = 3840 ???? maybe..
                        }
//                        statusMessage = "Underlying error: \(error.underlyingError)"
                        statusMessage = "Underlying error"
                    } else if let error = response.result.error as? URLError {
//                        statusMessage = "URLError occurred: \(error)"
                        statusMessage = "URLError occurred"
                    } else {
//                        statusMessage = "Unknown error: \(response.result.error)"
                        statusMessage = "Unknown error"
                    }

                    errorCallBack(statusCode, statusMessage)
                    return
                }
                
                if let data = response.result.value {
                    let json = JSON(data)
                    successCallBack(json)
                }
        }
    }
    
    private func onCallbackFailed(rtCode : RtCode, onFailed: @escaping(RtCode, String) -> Void) {
        let msg : String = LocalizationMessage.sharedInstance.getLocalization(code: rtCode.rawValue) as? String ?? ""
        onFailed(rtCode, msg)
    }
    
    private func getCommonParam() -> Dictionary<String,String> {
        var params = Dictionary<String,String>()
        params["lang"] = getLang()
        if !self.clientKey.isEmpty {
            params["clientKey"] = self.clientKey
        } else {
            params["appPackage"] = getPackageName()
            params["os"] = "IOS"
        }
        return params
    }
    
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
        
        public func getDeviceInfo(getDeviceInfoCallback:@escaping(Dictionary<String,Any>) -> Void){
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
            var _gpsLat = "gpsLat \(Date().currentTimeMillis())"
            var _gpsLng = "gpsLng \(Date().currentTimeMillis())"
        
            
            _proximity = encryptAES256(value:_proximity,seckey: securityKey)
            _light = encryptAES256(value:_light,seckey: securityKey)
            _magnetic = encryptAES256(value:_magnetic,seckey: securityKey)
            _orientation = encryptAES256(value:_orientation,seckey: securityKey)
            _audioInfo = encryptAES256(value:_audioInfo,seckey: securityKey)
            _audioMode = encryptAES256(value:_audioMode,seckey: securityKey)
            _macAddr = encryptAES256(value:_macAddr,seckey: securityKey)
            _bthAddr = encryptAES256(value:_bthAddr,seckey: securityKey)
            _wifiInfo = encryptAES256(value:_wifiInfo,seckey: securityKey)
            _accelerometer = encryptAES256(value:_accelerometer,seckey: securityKey)
            _gyroscope = encryptAES256(value:_gyroscope,seckey: securityKey)
            _gpsLat = encryptAES256(value:_gpsLat,seckey: securityKey)
            _gpsLng = encryptAES256(value:_gpsLng,seckey: securityKey)
            
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
                        "macAddr":_macAddr,
                        "bthAddr":_bthAddr,
                        "wifiInfo":_wifiInfo,
                        "accelerometer":_accelerometer,
                        "gyroscope":_gyroscope,
                        "gpsLat": _gpsLat,
                        "gpsLng": _gpsLng]
          
            mGetDeviceInfoCallback(params)
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

public func encryptAES256(value: String ,seckey: String) -> String {
    do {
        let seckeyCustom : String
        if seckey.count >= 31 {
            seckeyCustom = seckey
        } else {
            seckeyCustom = seckey + "FNSVALUEfnsvalueFNSVALUEfnsvalue"
        }
        
        let idx1 = seckeyCustom.index(seckeyCustom.startIndex, offsetBy: 31)
        let idx2 = seckeyCustom.index(seckeyCustom.startIndex, offsetBy: 15)
        
        let skey = String(seckeyCustom[...idx1])
        let siv = String(seckeyCustom[...idx2])
        
        let key : [UInt8] = Array(skey.utf8)
        let iv : [UInt8] = Array(siv.utf8)
        let aes = try AES(key: key, blockMode: CBC(iv:iv), padding: .pkcs5)
        let enc = try aes.encrypt(Array(value.utf8))
        
        return enc.toBase64()!
    } catch {
        return "error"
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

