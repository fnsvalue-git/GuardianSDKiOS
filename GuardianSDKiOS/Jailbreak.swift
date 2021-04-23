//
//  JailbreakCheck.swift
//  GuardianSDKiOS
//
//  Created by elite on 2021/04/22.
//  Copyright © 2021 fns_mac_pro. All rights reserved.
//

import Foundation
import UIKit

open class Jailbreak {
    
    public static let sharedInstance = Jailbreak()
    public init() {
    }
    
    public func isJailBroken() -> Bool {
        return UIDevice.current.isJailBroken
    }
    
    public func isSimulator() -> Bool {
        return UIDevice.current.isSimulator
    }
}


