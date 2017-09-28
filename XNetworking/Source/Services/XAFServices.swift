//
//  XAFServices.swift
//  XNetworking
//
//  Created by wangxi1-ps on 2017/9/21.
//  Copyright © 2017年 x. All rights reserved.
//

import Foundation

protocol XAFServicesProtocol: class {
    var isOnline:Bool {get}
    var offlineApiBaseUrl:String {get}
    var onlineApiBaseUrl:String {get}
    var isSecurity:Bool {get}
    // 可选协议
    //参数做签名
    func signGetWithSigParams(allParams:Dictionary<String, Any>) -> String?
    //是否要修改参数
    func paramsModifyWithOldParams(oldParams:Dictionary<String, Any>) -> Dictionary<String, Any>
    //参数是否要加密
    func paramsEncryptionWithPaeams(params:Dictionary<String, Any>) -> Dictionary<String, String>?
}
extension XAFServicesProtocol {
    func signGetWithSigParams(allParams:Dictionary<String, Any>) -> String? {
        print("mplemented in extension")
        return nil
    }
    func paramsModifyWithOldParams(oldParams:Dictionary<String, Any>) -> Dictionary<String, Any> {
        print("mplemented in extension")
        return oldParams
    }
    func paramsEncryptionWithPaeams(params:Dictionary<String, Any>) -> Dictionary<String, String>? {
        print("mplemented in extension")
        return params as? Dictionary<String, String>
    }
}

class XAFServices {
    //为了强制让子类实现 XAFServicesProtocol 协议
    weak var child: XAFServicesProtocol?     //XAFServicesProtocol 必须声明只能有class实现才可以用weak
    var apiBaseUrl:String {
        get {
            if let tempChild = self.child {
                return (tempChild.isOnline ? tempChild.onlineApiBaseUrl:tempChild.offlineApiBaseUrl)
            }
            else {
                return ""
            }
        }
    }
   required init() {
        if self is XAFServicesProtocol {
            self.child = self as? XAFServicesProtocol
        }
    }
}
class XAFServiceFactory {
    static let shardInstance = XAFServiceFactory()
    private init(){}
    //缓存service
    var serviceStorage:Dictionary = [String:XAFServices]()
    
    func serviceWithIdentifier(identifier:String) -> XAFServices? {
        guard (self.serviceStorage[identifier] != nil) else {
            self.serviceStorage[identifier] = self.newServiceWithIdentifier(identifier: identifier)
            return self.serviceStorage[identifier]
        }
        return self.serviceStorage[identifier]

    }
    fileprivate func newServiceWithIdentifier(identifier:String) -> XAFServices {
        let aclass = NSObject.fromClassName(className: identifier) as! XAFServices.Type
        return aclass.init()
    }
}

extension NSObject {
    // create a static method to get a swift class for a string name
    class func fromClassName(className : String) -> AnyClass! {
        let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + className
        return NSClassFromString(className)
    }
}
