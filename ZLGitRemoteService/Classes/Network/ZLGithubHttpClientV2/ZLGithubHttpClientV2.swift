//
//  ZLGithubHttpClientV2.swift
//  ZLGitRemoteService
//
//  Created by 朱猛 on 2023/4/6.
//

import Foundation
import Alamofire

typealias ZLGithubHttpClientBlock = (Bool, Any?,  ZLGithubRequestErrorModel?) -> Void

@objc public class ZLGithubHttpClientV2: NSObject {
    
    @objc public static let defaultClient: ZLGithubHttpClientV2 = {
        let client = ZLGithubHttpClientV2()
        return client
    }()
    
    let sessionConfiguration: URLSessionConfiguration
    
    let session: Session
    
    let completionQueue: DispatchQueue
    
    var token: String = ""
    
    override init() {
        
        sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 30
        
        session = Session(configuration: sessionConfiguration,
                          startRequestsImmediately: false)
        
        completionQueue = ZLBaseServiceModel.serviceOperationQueue()
        
        super.init()
        
        token = ZLSharedDataManager.sharedInstance().githubAccessToken ?? ""
    }
}
