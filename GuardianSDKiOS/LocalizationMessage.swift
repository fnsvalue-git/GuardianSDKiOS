//
//  LocalizationMessage.swift
//  GuardianSDKiOS
//
//  Created by Jayhy on 16/07/2020.
//  Copyright © 2020 fns_mac_pro. All rights reserved.
//

import Foundation

public class LocalizationMessage {
    
    public static let sharedInstance = LocalizationMessage()
    
    private var localDictionary : [String : String] = ["1": "1"]
    private var isLang : String = "en"
    
    private init() {
        
    }
    
    private let LocalDictionary : [String : String] = [
        "2000": "[2000] Unknown client.",
        "2001": "[2001] Server error.",
        "2002": "[2002] Invalid parameters.",
        "2003": "[2003] Session error",
        "2004": "[2004] Unknown channel",
        "2005": "[2005] License is expired",
        "2006": "[2006] License is expired",
        "2007": "[2007] Unknown member.",
        "2008": "[2008] Unknown device.",
        "2009": "[2009] Duplicate UserID.",
        "2010": "[2010] Authentication is already in progress.",
        "2011": "[2011] Duplicate UserID.",
        "2012": "[2012] Server in maintenance.",
        "2013": "[2013] Invalid license.",
        "2014": "[2014] Unknown license.",
        "2015": "[2015] Duplicate client.",
        "2016": "[2016] Duplicate license.",
        "2017": "[2017] Duplicate license.",
        "2018": "[2018] Forbidden.",
        "2100": "[2100] Token is expired.",
        "2101": "[2101] Token's signature is invalid.",
        "2102": "[2102] Can't access with this token.",
        "2103": "[2103] Unexpected token error.",
        "3000": "[3000] Unknown authentication level.",
        "3001": "[3001] Unknown authentication icons.",
        "3002": "[3002] Need for agreenment [Personal Information Collection]",
        "3003": "[3003] Need for agreenment [Device Information Collection]",
        "3004": "[3004] Ready for authentication.",
        "3005": "[3005] OTP code does not match.",
        "3006": "[3006] User infomation does not match.",
        "3007": "[3007] Device information does not match.",
        "3008": "[3008] Can't access to admin page.",
        "3009": "[3009] Unknown push token.",
        "3010": "[3010] Unknown user status.",
        "5000": "[5000] Authentication failed.",
        "5001": "[5001] Authentication failed.",
        "5002": "[5002] Authentication failed.",
        "5003": "[5003] Authentication failed.",
        "5004": "[5004] Authentication failed.",
        "5005": "[5005] Authentication failed.",
        "5006": "[5006] Authentication failed.",
        "5007": "[5007] Authentication failed.",
        "5008": "[5008] Authentication failed.",
        "5010": "[5010] Authentication failed.",
        "5011": "[5011] Authentication canceled.",
        "5013": "[5013] Icons does not match.",
        "5015": "[5015] Channel addition failed.",
        "5016": "[5016] Node creation failed.",
        "5017": "[5017] Notification failed.",
        "5018": "[5018] Authentication request failed.",
        "5019": "[5019] Unknown channel.",
        "5020": "[5020] Data decryption failed.",
        "5021": "[5021] Verification request failed.",
        "5022": "[5022] Authentication verification failed.",
        "6000": "[6000] Can't generate key.",
        "7000": "[7000] Can't verify key.",
        "9000": "[9000] Biometric normal",
        "9001": "[9001] Biometric Not Available",
        "9002": "[9002] This iOS device Face ID/Touch ID is locked.",
        "9003": "[9003] This iOS device does not support hardware.",
        "9004": "[9004] This iOS device does not registered Biometric.",
        "9005": "[9005] This Application does not registered Biometric.",
        "9006": "[9006] Biometrics information has been changed.",
        "9007": "[9007] This device is registered biometrics information.",
        "9008": "[9008] Biometrics error.",
        "9009": "[9009] Biometrics error."
    ]
    
    private let LocalDictionary_ko : [String : String] = [
        "2000": "[2000] 등록되지 않은 클라이언트입니다",
        "2001": "[2001] 서버에서 오류가 발생하였습니다",
        "2002": "[2002] 파라메터 불일치 오류",
        "2003": "[2003] 세션정보 확인 오류",
        "2004": "[2004] 채널정보 확인 오류",
        "2005": "[2005] 라이센스가 만료되었습니다",
        "2006": "[2006] 라이센스가 만료되었습니다",
        "2007": "[2007] 등록되지 않은 유저입니다",
        "2008": "[2008] 등록되지 않은 기기입니다",
        "2009": "[2009] 아이디 중복",
        "2010": "[2010] 이미 처리중 입니다",
        "2011": "[2011] 아이디 중복",
        "2012": "[2012] 서버점검중",
        "2013": "[2013] 라이센스 오류",
        "2014": "[2014] 알수없는 라이센스 정보",
        "2015": "[2015] 중복 클라이언트",
        "2016": "[2016] 라이센스 오류",
        "2017": "[2017] 라이센스 오류",
        "2018": "[2018] 권한이 없습니다",
        "2100": "[2100] 만료된 토큰입니다",
        "2101": "[2101] 잘못된 서명입니다",
        "2102": "[2102] 접근 권한이 없습니다",
        "2103": "[2103] 토큰 오류",
        "3000": "[3000] 인증방식 등록정보 오류",
        "3001": "[3001] 아이콘인증 등록정보 오류",
        "3002": "[3002] 개인정보 수집 및 이용에 대한 동의 필요",
        "3003": "[3003] 기기정보 수집 및 이용에 대한 동의 필요",
        "3004": "[3004] 인증 초기화 상태",
        "3005": "[3005] 인증문자가 일치하지 않습니다",
        "3006": "[3006] 고객정보가 일치하지 않습니다",
        "3007": "[3007] 기기정보가 일치하지 않습니다",
        "3008": "[3008] 관리자기능에 접근할 수 없습니다",
        "3009": "[3009] 푸쉬정보가 올바르지 않습니다",
        "3010": "[3010] 상태정보가 올바르지 않습니다",
        "5000": "[5000] 인증에 실패하였습니다",
        "5001": "[5001] 인증에 실패하였습니다",
        "5002": "[5002] 인증에 실패하였습니다",
        "5003": "[5003] 인증에 실패하였습니다",
        "5004": "[5004] 인증에 실패하였습니다",
        "5005": "[5005] 인증에 실패하였습니다",
        "5006": "[5006] 인증에 실패하였습니다",
        "5007": "[5007] 인증에 실패하였습니다",
        "5008": "[5008] 인증에 실패하였습니다",
        "5010": "[5010] 인증에 실패하였습니다",
        "5011": "[5011] 인증이 취소되었습니다",
        "5013": "[5013] 아이콘이 인증에 실패하였습니다",
        "5015": "[5015] 채널 생성에 실패하였습니다",
        "5016": "[5016] 노드 생성에 실패하였습니다",
        "5017": "[5017] 인증요청 전송에 실패하였습니다",
        "5018": "[5018] 인증요청에 실패하였습니다",
        "5019": "[5019] 등록되지 않은 채널입니다",
        "5020": "[5020] 데이터 복호화에 실패하였습니다",
        "5021": "[5021] 검증요청에 실패하였습니다",
        "5022": "[5022] 검증에 실패하였습니다",
        "6000": "[6000] 인증키를 생성할 수 없습니다",
        "7000": "[7000] 인증키를 검증할 수 없습니다",
        "9000": "[9000] 생체인증 정상",
        "9001": "[9001] 생채인증을 사용할 수 없습니다",
        "9002": "[9002] 생체인증이 잠김 상태 입니다",
        "9003": "[9003] 생체인증을 지원하지 않는 기기입니다",
        "9004": "[9004] 생체인증 정보를 등록하지 않은 기기 입니다",
        "9005": "[9005] 앱에 등록 된 생체인증 정보가 존재하지 않습니다",
        "9006": "[9006] 생체인증 정보가 변경 되었습니다",
        "9007": "[9007] 등록되어 있는 생체인증 정보가 존재합니다",
        "9008": "[9008] 생체인증 오류",
        "9009": "[9009] 생체인증 오류"
    ]
    
    public func getLocalization(code : Int) -> String? {
        let rtCode : Int = code as? Int ?? 0
        if isLang == isLang, !isLang.isEmpty {
            let lang = getLang()
            switch lang {
            case "ko":
                localDictionary = LocalDictionary_ko
            default:
                localDictionary = LocalDictionary
            }
            return localDictionary["\(rtCode)"]
        } else {
            return localDictionary["\(rtCode)"]
        }
    }
    
}
