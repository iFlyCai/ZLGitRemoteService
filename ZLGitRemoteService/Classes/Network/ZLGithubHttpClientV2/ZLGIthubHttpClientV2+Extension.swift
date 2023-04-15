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
            case .string:
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
        
        let api = ZLGithubAPISwift.currentUserRepoUrl(page: page, per_Page: perPage)
        
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
                                                          per_page: perPage)
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
                                                       per_page: perPage)
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
                                                        per_page: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    /// 获取指定用户的star的仓库
    @objc func getStarredsForUser(login: String,
                                  page: Int,
                                  perPage: Int,
                                  serialNumber: String,
                                  response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getStarredForUser(login: login, page: page, per_page: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前的star的仓库
    @objc func getStarredsForCurrentUser(page: Int,
                                         perPage: Int,
                                         serialNumber: String,
                                         response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.currentUserStarreds(page: page, per_page: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前的star的仓库
    @objc func getGistsForCurrentUser(page: Int,
                                      perPage: Int,
                                      serialNumber: String,
                                      response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.currentUserGists(page: page, per_page: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前的star的仓库
    @objc func getGistsForUser(login: String,
                               page: Int,
                               perPage: Int,
                               serialNumber: String,
                               response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getGistsForUser(login: login, page: page, per_page: perPage)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前仓库的readme
    @objc func getRepoReadMeInfo(fullName: String,
                                 ref: String?,
                                 isHTMLContent: Bool,
                                 serialNumber: String,
                                 response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getRepoReadMeInfo(fullName: fullName, ref: ref, isHTMLContent: isHTMLContent)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 获取当前仓库的pr列表
    @objc func getPRsForRepo(fullName: String,
                             state: String,
                             page: Int,
                             per_page: Int,
                             serialNumber: String,
                             response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getPRsForRepo(fullName: fullName, state: state, page: page, per_page: per_page)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的commit列表
    ///  - Parameters
    ///    - fullName : 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    ///    - sha:  SHA or branch 默认： 默认分支
    ///    - path: 文件路径 过滤包含该文件的commit
    ///    - author: 作者
    ///    - committer: 提交者
    ///    - since: 过滤时间之后 YYYY-MM-DDTHH:MM:SSZ
    ///    - until: 过滤时间之前
    @objc func getCommitsForRepo(fullName: String,
                                 page: Int = 1,
                                 per_page: Int = 30,
                                 sha: String? = nil,
                                 path: String? = nil,
                                 author: String? = nil,
                                 committer: String? = nil,
                                 since: Date? = nil,
                                 until: Date? = nil,
                                 serialNumber: String,
                                 response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getCommitsForRepo(fullName: fullName,
                                                     page: page,
                                                     per_page: per_page,
                                                     sha:sha,
                                                     path: path,
                                                     author: author,
                                                     committer: committer,
                                                     since:since,
                                                     until: until)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的分支列表
    ///  - Parameters
    ///    - fullName : 仓库名 existorlive/githubclient
    @objc dynamic func getBranchsForRepo(fullName: String,
                                         serialNumber: String,
                                         response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getBranchsForRepo(fullName: fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的分支列表
    ///  - Parameters
    ///    - fullName : 仓库名 existorlive/githubclient
    @objc dynamic func getContributorsForRepo(fullName: String,
                                              serialNumber: String,
                                              response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getContributorsForRepo(fullName: fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    ///  获取仓库的issue列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - state: 状态  open/closed
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    @objc dynamic func getIssuesForRepo(fullName: String,
                                        state: String,
                                        page: Int,
                                        per_page: Int,
                                        serialNumber: String,
                                        response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getIssuesForRepo(fullName: fullName,
                                                    state: state,
                                                    page: page,
                                                    per_page: per_page)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    ///  获取watch仓库的状态
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    @objc func getWatchRepoStatus(fullName: String,
                                  serialNumber: String,
                                  response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getWatchRepoStatus(fullName: fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  watch仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    @objc func watchRepo(fullName: String,
                         serialNumber: String,
                         response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.watchRepo(fullName: fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    ///  取消watch仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    @objc func unwatchRepo(fullName: String,
                           serialNumber: String,
                           response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.unwatchRepo(fullName: fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的watchers列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    @objc func getWatchersForRepo(fullName: String,
                                  page: Int,
                                  per_page: Int,
                                  serialNumber: String,
                                  response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getWatchersForRepo(fullName:fullName , page: page, per_page: per_page)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取star仓库的状态
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    @objc func getStarRepoStatus(fullName: String,
                                 serialNumber: String,
                                 response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getStarRepoStatus(fullName:fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  star仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    @objc func starRepo(fullName: String,
                        serialNumber: String,
                        response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.starRepo(fullName:fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  取消star仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    @objc func unstarRepo(fullName: String,
                          serialNumber: String,
                          response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.unstarRepo(fullName:fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    
    ///  获取仓库的stargazers列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    @objc func getStargazersForRepo(fullName: String,
                                    page: Int,
                                    per_page: Int,
                                    serialNumber: String,
                                    response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getStargazersForRepo(fullName:fullName, page: page, per_page: per_page)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  fork 仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - organization: 组织名：  fork 仓库到组织下
    ///    - name: fork 后的仓库名
    ///    - default_branch_only: 是否只fork 默认分支
    @objc func forkRepo(fullName: String,
                        organization: String?,
                        name: String?,
                        default_branch_only: Bool,
                        serialNumber: String,
                        response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.forkRepo(fullName: fullName,
                                            organization: organization,
                                            name: name,
                                            default_branch_only: default_branch_only)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的fork列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    @objc func getForksForRepo(fullName: String,
                               page: Int,
                               per_page: Int,
                               serialNumber: String,
                               response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getForksForRepo(fullName: fullName,
                                                   page: page,
                                                   per_page: per_page)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }

    ///  获取仓库的开发语言信息
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    @objc func getLanguagesInfoForRepo(fullName: String,
                                       serialNumber: String,
                                       response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getLanguagesInfoForRepo(fullName: fullName)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的workflow
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    @objc func getWorkflowsForRepo(fullName: String,
                                   page: Int,
                                   per_page: Int,
                                       serialNumber: String,
                                       response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getWorkflowsForRepo(fullName: fullName,
                                                       page: page,
                                                       per_page: per_page)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的workflow的执行记录
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowId:  workflowId
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    @objc func getWorkflowRunsForRepo(fullName: String,
                                      workflowId: String,
                                      page: Int,
                                      per_page: Int,
                                      serialNumber: String,
                                      response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getWorkflowRunsForRepo(fullName: fullName,
                                                          workflowId: workflowId,
                                                          page: page,
                                                          per_page: per_page)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 从新执行仓库的workflow的某次执行
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowRunId:  workflowRunId
    @objc func rerunWorkflowRunForRepo(fullName: String,
                                       workflowRunId: String,
                                       serialNumber: String,
                                       response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.rerunWorkflowRunForRepo(fullName: fullName,
                                                           workflowRunId: workflowRunId)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    /// 取消仓库的workflow的某次执行
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowRunId:  workflowRunId
    @objc func cancelWorkflowRunForRepo(fullName: String,
                                        workflowRunId: String,
                                        serialNumber: String,
                                        response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.cancelWorkflowRunForRepo(fullName: fullName,
                                                            workflowRunId: workflowRunId)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
    
    ///  获取仓库的workflow的某次执行的日志
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowRunId:  workflowRunId
    @objc func getWorkflowRunLogForRepo(fullName: String,
                                        workflowRunId: String,
                                        serialNumber: String,
                                        response: @escaping GithubResponseSwift) {
        let api = ZLGithubAPISwift.getWorkflowRunLogForRepo(fullName: fullName,
                                                            workflowRunId: workflowRunId)
        self.requestGithubAPI(api: api, serialNumber: serialNumber, responseBlock: response)
    }
}
