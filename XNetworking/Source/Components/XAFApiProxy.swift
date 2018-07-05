//
//  XAFApiProxy.swift
//  XNetworking
//
//  Created by wangxi1-ps on 2017/9/19.
//  Copyright © 2017年 x. All rights reserved.
//

import Foundation
import Alamofire
class XAFApiProxy {
    static let shardInstance = XAFApiProxy()
    private init(){
    }
    
//    let serverTrustPolicy:ServerTrustPolicyManager = {
//        let tempTrust = ServerTrustPolicyManager(policies:shardInstance.serverTrustPolicies)
//        return tempTrust
//    }()
    
    let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "apple.com": .pinCertificates(
            certificates: ServerTrustPolicy.certificates(),     //这里会自动查找main Bundle内部的证书文件
            validateCertificateChain: true,
            validateHost: true
        )//,
//        "insecure.expired-apis.com": .disableEvaluation       //多个域名校验
    ]
    var sessionManager:SessionManager! = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        return Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate())
        
    }()
    var dispatchTable = [Int:DataRequest]()
    var recordedRequestId = 1
    //生成请求id
    func generateRequestId() -> Int {
        if self.recordedRequestId == Int.max {
            self.recordedRequestId = 1
        }
        else {
            self.recordedRequestId += 1
        }
        return self.recordedRequestId
    }
    
    public func request(urlRequest:URLRequest,successBlock:@escaping(DataResponse<Any>)  -> Void) -> Int {
        let requestID = self.generateRequestId()
        //
        let request = self.sessionManager.request(urlRequest).responseJSON { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Response: \(response.result)")
            successBlock(response)
            self.dispatchTable.removeValue(forKey: requestID)   //从请求记录删除已经请求完成的
        }
        debugPrint(request)
        self.dispatchTable[requestID] = request
        return requestID
    }
   
    func generateRequest(serviceIdentifier:String, requestParams:Dictionary<String, String>,method:String ,httpMethod:String) -> URLRequest? {
        //生成service
        let service = XAFServiceFactory.shardInstance.serviceWithIdentifier(identifier: serviceIdentifier)
        if service == nil {
            return nil
        }
        //公共参数
        var allParams = XAFCommonParams.commonParamsDictionary()
        allParams += requestParams
        //询问参数是否需要修改
        if service?.child != nil {
            allParams = service?.child?.paramsModifyWithOldParams(oldParams: allParams) as! [String : String]
        }
        //签名
        var signature:String?
        if service?.child != nil {
            signature = (service?.child?.signGetWithSigParams(allParams: allParams))!
        }
        if signature != nil {
            allParams["sign"] = signature
        }
        //是否需要加密
        if service?.child != nil {
            allParams = (service?.child?.paramsEncryptionWithPaeams(params: allParams))!
        }
        let urlString = (service?.apiBaseUrl)! + "/" + method
        
        //生成url
        var originalRequest: URLRequest?
        do {
            originalRequest = try URLRequest(url: urlString, method: HTTPMethod(rawValue: httpMethod)!)
            originalRequest = try URLEncoding.default.encode(originalRequest!, with: allParams)
        } catch {
            originalRequest = try? URLRequest.init(url: urlString, method: HTTPMethod(rawValue: httpMethod)!)
        }
        return originalRequest
    }
    
    func cancellAllTask() ->Void {
        let allTask = Array(self.dispatchTable.values)
        for request in allTask {
            request.cancel()
        }
        self.dispatchTable.removeAll()
    }
    
    func cancellTask(requestID:Int) ->Void {
        if self.dispatchTable.count <= requestID {
            return
        }
        //如果能取出来说明还在队列中
        if let request:DataRequest = self.dispatchTable[requestID] {
            request.cancel()
            self.dispatchTable.removeValue(forKey: requestID)
        }
    }
}


