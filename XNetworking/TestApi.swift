//
//  TestApi.swift
//  XNetworking
//
//  Created by wangxi1-ps on 2017/9/27.
//  Copyright © 2017年 x. All rights reserved.
//

import UIKit

class TestApi: XAFAPIBaseManager, XAFAPIManager,XAFAPIManagerParamSourceDelegate{
    override init() {
        super.init()
        self.paramSource = self
    }
    //MARK: XAFAPIManager
    func methodName() -> String {
        return "v1/categories"
    }
    
    func serviceID() -> String {
        return "XAFServicesAVgle"
    }
    
    func requestType() -> String {
        return "GET"
    }
    
    //MARK: XAFAPIManagerParamSourceDelegate
    func paramsForApi(magager: XAFAPIBaseManager) -> Dictionary<String, String> {
        return ["xx":"xx"]
    }
}
