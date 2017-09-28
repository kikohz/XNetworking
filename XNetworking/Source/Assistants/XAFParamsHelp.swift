//
//  XAFParamsHelp.swift
//  XNetworking
//
//  Created by wangxi1-ps on 2017/9/13.
//  Copyright © 2017年 x. All rights reserved.
//

import Foundation
public extension String {
    var md5:String? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    var sha1: String? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    public func jsonToDict() ->[String:String]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                let dict =  try JSONSerialization.jsonObject(with: data, options: []) as? [String : String]
                print(dict!)
                return dict
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    //通过下标 截取字符串
    subscript (start:Int,end:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy:start)
            let endIndex = self.index(self.startIndex, offsetBy:end)
            return String(self[startIndex...endIndex])    //这种方式 swift 4中才有   参考: https://developer.apple.com/documentation/swift/substring
        }
    }
}

public extension Array {
    public func paramsString() -> String {
        var paramStr = ""
        for (_,item) in (self.enumerated()) {
            let itemStr = String(describing: item)
            if paramStr.isEmpty {
                paramStr = paramStr.appendingFormat("%@", itemStr)
            }
            else {
                paramStr = paramStr.appendingFormat("&%@", itemStr)
            }
        }
        return paramStr
    }
    
    public func jsonString() throws -> String {
        var strJson = ""
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            strJson = String.init(data: jsonData, encoding: .utf8)!
        }
        return strJson
    }
}

public extension Dictionary {
    public func transformedUrlParamsArraySignature(isForSignature:Bool) -> Array<String>? {
        if self.isEmpty{
            return nil
        }
        var result = [""]
        for (_,item) in self.enumerated() {
            var obj = String(describing: item.value)
            if !isForSignature {
                obj = obj.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            }
            result.append(String(format: "%@=%@", String(describing: item.key),obj))
        }
        result = result.sorted()
     return result
    }
    
    public func jsonString() throws -> String {
        var strJson = ""
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            strJson = String.init(data: jsonData, encoding: .utf8)!
        }
        return strJson
    }
    public func urlParamsStringSignature(isForSignature:Bool) -> String {
        let sortedArray = self.transformedUrlParamsArraySignature(isForSignature: isForSignature)
        if (sortedArray?.isEmpty)! {
            return ""
        }
        return (sortedArray?.paramsString())!
    }
}
 func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}
