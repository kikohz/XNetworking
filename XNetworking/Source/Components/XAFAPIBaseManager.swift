//
//  XAFAPIBaseManager.swift
//  XNetworking
//
//  Created by wangxi1-ps on 2017/9/25.
//  Copyright © 2017年 x. All rights reserved.
//

import Foundation
import Alamofire
//参数
protocol XAFAPIManagerParamSourceDelegate:class {
    func paramsForApi(magager:XAFAPIBaseManager) -> Dictionary<String, String>
}
//解析用到
protocol XAFAPIManagerCallbackDataReformer {
    func reformData(_ manager:XAFAPIBaseManager, _ dictData:Dictionary<String, Any>) ->Any
}

protocol XAFAPIManager: class {
    func methodName() -> String
    func serviceID() ->String
    func requestType() ->String
}

typealias xafSuccess = (_ manager:DataResponse<Any>) ->Void;
class XAFAPIBaseManager {
    weak var paramSource: XAFAPIManagerParamSourceDelegate?
    weak var child: XAFAPIManager?
    var fetchedRawData = [String:Any]()
    var successBlock:xafSuccess?
    var currentRequestId = 0
    var isConnection = false
    init() {
        self.child = self as? XAFAPIManager
        self.startReachable()
    }
    deinit {
        self.cancel()
        self.successBlock = nil
    }
    
    func startReachable() {
        let manager = NetworkReachabilityManager(host: "www.apple.com.cn")
        manager?.listener = { status in
            print("Network Status Changed: \(status)")
        }
        manager?.startListening()
    }
    
    func fetchData(reformer:XAFAPIManagerCallbackDataReformer) ->Any {
       let requestData = reformer.reformData(self, fetchedRawData)
       return requestData
    }
    
    func startWithCompletionBlock(success:@escaping(_ manager:DataResponse<Any>) ->Void) {
        self.successBlock = success
        let params:Dictionary = (self.paramSource?.paramsForApi(magager: self))!
        self.currentRequestId = self.loadData(params: params)
    }
    
    //call api
    func loadData(params:Dictionary<String,String>) -> NSInteger {
        var requestID:Int = 0
        guard self.child != nil else {
            return requestID
        }
        let urlrequest = XAFApiProxy.shardInstance.generateRequest(serviceIdentifier: (self.child?.serviceID())!, requestParams: params, method: (self.child?.methodName())!, httpMethod: (self.child?.requestType())!)
        requestID = XAFApiProxy.shardInstance.request(urlRequest: urlrequest!, successBlock: { (dataResponse:DataResponse ) in
            self.successedOnCallingApi(response: dataResponse)
        })
        return requestID
    }
    
    func successedOnCallingApi(response:DataResponse<Any>) ->Void {
        if response.error == nil {   //请求成功
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                let jsonDict = json as! Dictionary<String,Any>
                self.fetchedRawData = jsonDict
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
        self.successBlock!(response)
        self.successBlock = nil      //防止循环引用
    }
    //MARK: operating
    func cancel() -> Void {
        XAFApiProxy.shardInstance.cancellTask(requestID: self.currentRequestId)
    }
    
    open class func cancelAllReques()-> Void {
        XAFApiProxy.shardInstance.cancellAllTask()
    }
    
}
