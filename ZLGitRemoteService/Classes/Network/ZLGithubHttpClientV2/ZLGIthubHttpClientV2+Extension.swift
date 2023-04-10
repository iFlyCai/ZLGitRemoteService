//
//  ZLGIthubHttpClientV2+Repository.swift
//  ZLGitRemoteService
//
//  Created by 朱猛 on 2023/4/10.
//

import Foundation
import Alamofire
import MJExtension

typealias ZLGithubHttpClientSuccessBlock = (ZLGithubAPISwift, HTTPURLResponse, Data) -> Void

public extension ZLGithubHttpClientV2 {
    
    internal func requestGithubAPI(api: ZLGithubAPISwift,
                                   serialNumber: String,
                                   responseBlock: @escaping GithubResponseSwift) {
        
        let successResponse: ZLGithubHttpClientSuccessBlock = { api, response, data in
            
            switch api.resultType {
            case .data:
                responseBlock(true, data, serialNumber)
            case .commonStr:
                let str = String(data: data, encoding: .utf8)
                responseBlock(true, str, serialNumber)
            case .jsonObject:
                if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
                    responseBlock(true, jsonObject, serialNumber)
                } else {
                    responseBlock(true, data, serialNumber)
                }
            case .custom(let wrapper):
                let resultData = wrapper.parseData(api: api,response: response, data: data)
                responseBlock(true, resultData, serialNumber)
            case .object(let wrapper):
                let resultData = wrapper.parseData(api: api,response: response, data: data)
                responseBlock(true, resultData, serialNumber)
            }
            
        }
        
        
        let commonHeaders: [String: String] = ["Authorization": "Bearer \(token)",
                                               "Accept": "application/vnd.github.v3+json"]
        
        var httpHeaders = HTTPHeaders(commonHeaders)
        for header in api.headers {
            httpHeaders.update(name: header.key, value: header.value)
        }
        
        let request = session.request(api.url,
                                      method:api.method,
                                      parameters: api.params,
                                      encoding: api.paramsEncoding,
                                      headers: httpHeaders)
        
        request.responseData(queue: completionQueue,
                             completionHandler: { (dataResponse : AFDataResponse<Data>) in
            
            switch dataResponse.result {
            case .success(let data):
                if  let response = dataResponse.response,
                    let statusCode = dataResponse.response?.statusCode {
                    
                    if api.successStatusCodes.contains(statusCode) {
                        
                        successResponse(api, response, data)
                        
                    } else {
                        
                        var message: String = ""
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String:Any?] {
                            message = jsonObject["message"] as? String ?? ""
                        }
                        let errorModel = ZLGithubRequestErrorModel()
                        errorModel.statusCode = statusCode
                        errorModel.message = message
                        responseBlock(false,errorModel,serialNumber)
                        
                    }
                    
                } else {
                    let errorModel = ZLGithubRequestErrorModel()
                    errorModel.statusCode = 0
                    errorModel.message = "No Status Code"
                    responseBlock(false,errorModel,serialNumber)
                }
                
            case .failure(let error):
                let errorModel = ZLGithubRequestErrorModel()
                errorModel.statusCode = dataResponse.response?.statusCode ?? 0
                errorModel.message = error.errorDescription ?? ""
                responseBlock(false, errorModel, serialNumber)
            }
            
        })
        
        request.resume()
    }
    
    
    /// 获取当前用户的仓库
    @objc func getRepositoriesForCurrentUser(page: Int,
                                             perPage: Int,
                                             serialNumber: String,
                                             response: @escaping GithubResponseSwift) {
        
        let api = ZLGithubAPISwift.currentUserRepoUrl(page: page, perPage: perPage)
        
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    /// 获取用户信息
    @objc func getUserInfo(login: String,
                           serialNumber: String,
                           response: @escaping GithubResponseSwift) {
        
        let api = ZLGithubAPISwift.userInfo(login: login)
        
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取用户的follow状态
    @objc func getFollowStatusFor(login: String,
                                  serialNumber: String,
                                  response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getFollowUserStatus(login: login)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// follow用户
    @objc func followUser(login: String,
                          serialNumber: String,
                          response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.followUser(login: login)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    /// 取消follow用户
    @objc func unfollowUser(login: String,
                            serialNumber: String,
                            response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.unfollowUser(login: login)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    /// 获取用户的Block状态
    @objc func getBlockUsers(serialNumber: String,
                             response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getBlockedUsers
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取用户的Block状态
    @objc func getBlockStatusFor(login: String,
                                 serialNumber: String,
                                 response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getBlockUserStatus(login: login)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// block用户
    @objc func blockUser(login: String,
                         serialNumber: String,
                         response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.blockUser(login: login)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    /// 取消block用户
    @objc func unblockUser(login: String,
                           serialNumber: String,
                           response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.unblockUser(login: login)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    /// 获取指定用户的仓库
    @objc func getRepositoriesForUser(login: String,
                                      page: Int,
                                      perPage: Int,
                                      serialNumber: String,
                                      response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getRepositoriesForUser(login: login,
                                                          page: page,
                                                          perPage: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取指定用户的followers
    @objc func getFollowersForUser(login: String,
                                   page: Int,
                                   perPage: Int,
                                   serialNumber: String,
                                   response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getFollowersForUser(login: login,
                                                       page: page,
                                                       perPage: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取指定用户的followings
    @objc func getFollowingsForUser(login: String,
                                    page: Int,
                                    perPage: Int,
                                    serialNumber: String,
                                    response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getFollowingsForUser(login: login,
                                                        page: page,
                                                        perPage: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    /// 获取指定用户的star的仓库
    @objc func getStarredsForUser(login: String,
                                  page: Int,
                                  perPage: Int,
                                  serialNumber: String,
                                  response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getStarredForUser(login: login, page: page, perPage: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前的star的仓库
    @objc func getStarredsForCurrentUser(page: Int,
                                         perPage: Int,
                                         serialNumber: String,
                                         response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.currentUserStarreds(page: page, perPage: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前的star的仓库
    @objc func getGistsForCurrentUser(page: Int,
                                         perPage: Int,
                                         serialNumber: String,
                                         response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.currentUserGists(page: page, perPage: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前的star的仓库
    @objc func getGistsForUser(login: String,
                               page: Int,
                               perPage: Int,
                               serialNumber: String,
                               response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getGistsForUser(login: login, page: page, perPage: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    
}
