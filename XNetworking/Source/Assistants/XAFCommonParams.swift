//
//  XAFCommonParams.swift
//  XNetworking-Swift
//
//  Created by wangxi1-ps on 2017/9/12.
//  Copyright © 2017年 x. All rights reserved.
//

import Foundation
import UIKit

struct XAFAppContext {
    let channelID = "App Store"
    let appName:String = {
        let infoDictionary = Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary["CFBundleDisplayName"] //程序名称
        if appDisplayName == nil {
            return ""
        }
        else {
            return appDisplayName as! String
        }
    }()
    let modelName = UIDevice.current.modelName
    let systemName = UIDevice.current.systemName
    let systemVersion = UIDevice.current.systemVersion
    let appVersion:String = { () -> String in
        let infoDictionary = Bundle.main.infoDictionary!
        let tempVersion = infoDictionary["CFBundleShortVersionString"]
        return tempVersion as! String
    }()
    let frome = "ios"
}

open class XAFCommonParams {
    public class func commonParamsDictionary() -> [String: String] {
        let appContext = XAFAppContext()
        return ["channel":appContext.channelID,
                "appName":appContext.appName,
                "modelName":appContext.modelName,
                "systemName":appContext.systemName,
                "systemVersion":appContext.systemVersion,
                "appVersion":appContext.appVersion,
                "frome":appContext.frome]
    }
}

