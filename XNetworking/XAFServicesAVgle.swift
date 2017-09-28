//
//  XAFServicesAVgle.swift
//  XNetworking
//
//  Created by wangxi1-ps on 2017/9/28.
//  Copyright © 2017年 x. All rights reserved.
//

import UIKit

class XAFServicesAVgle: XAFServices,XAFServicesProtocol {
    var isOnline: Bool {
        return false
    }
    
    var offlineApiBaseUrl: String = "https://api.avgle.com"
    
    var onlineApiBaseUrl: String = "https://api.avgle.com"
    
    var isSecurity: Bool {
        return false
    }
    
    required init() {
        super.init()
        
    }
    
    //MARK: 操作
    func signGetWithSigParams(allParams: Dictionary<String, Any>) -> String? {
        return "s"
//        var tempStr = allParams.urlParamsStringSignature(isForSignature: true)
//        tempStr += "xxxxxxxxxxxxxxxxxxxxxxx"
//        tempStr = tempStr.md5!
//        if tempStr.characters.count == 32 {
//            let left = tempStr[0,15]
//            let right = tempStr[15,31]
//            tempStr = "\(left)_xxxxxxxxxx_\(right)"
//            tempStr = tempStr.md5!
//        }
//        return tempStr
    }
}
