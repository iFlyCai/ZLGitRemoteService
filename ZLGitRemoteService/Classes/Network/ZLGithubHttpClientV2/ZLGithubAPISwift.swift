//
//  ZLGithubAPISwift.swift
//  ZLGitRemoteService
//
//  Created by 朱猛 on 2023/4/10.
//

import Foundation
import MJExtension
import Alamofire

enum ZLGithubAPISwift {
    
    // MARK: User
    
    /// 当前用户的Repo 包括private
    ///  - Parameters
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case currentUserRepoUrl(page: Int,
                            per_Page: Int)
    /// 当前用户的Star列表
    ///  - Parameters
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case currentUserStarreds(page: Int,
                             per_page: Int)
    ///  当前用户的Gist列表
    ///  - Parameters
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case currentUserGists(page: Int,
                          per_page: Int)
    /// 用户信息
    ///  - Parameters
    ///    - login: 用户标识
    case userInfo(login: String)
    ///  获取follow用户状态
    ///  - Parameters
    ///    - login: 用户标识
    case getFollowUserStatus(login: String)
    ///  follow 用户
    ///  - Parameters
    ///    - login: 用户标识
    case followUser(login: String)
    ///  取消follow用户
    ///  - Parameters
    ///    - login: 用户标识
    case unfollowUser(login: String)
    ///  获取block的用户列表
    case getBlockedUsers
    ///  获取block 用户状态
    ///  - Parameters
    ///    - login: 用户标识
    case getBlockUserStatus(login: String)
    ///  block用户
    ///  - Parameters
    ///    - login: 用户标识
    case blockUser(login: String)
    ///  取消block用户
    ///  - Parameters
    ///    - login: 用户标识
    case unblockUser(login: String)
    ///  获取某个用户的公共仓库列表
    ///  - Parameters
    ///    - login: 用户标识
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getRepositoriesForUser(login: String,
                                page: Int,
                                per_page: Int)
    ///  获取某个用户的粉丝列表
    ///  - Parameters
    ///    - login: 用户标识
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getFollowersForUser(login: String,
                             page: Int,
                             per_page: Int)
    ///  获取某个用户的关注列表
    ///  - Parameters
    ///    - login: 用户标识
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getFollowingsForUser(login: String,
                              page: Int,
                              per_page: Int)
    ///  获取某个用户的star仓库列表
    ///  - Parameters
    ///    - login: 用户标识
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getStarredForUser(login: String,
                           page: Int,
                           per_page: Int)
    ///  获取某个用户的Gist列表
    ///  - Parameters
    ///    - login: 用户标识
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getGistsForUser(login: String,
                         page: Int,
                         per_page: Int)
    
    // MARK: Repo
    ///  获取readme
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - ref: 分支
    ///    - mediaType:  返回的数据类型
    case getRepoReadMeInfo(fullName: String,
                           ref: String?,
                           mediaType: ZLGithubMediaType)
    ///  获取仓库的PR列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - state: 状态  open/closed
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getPRsForRepo(fullName: String,
                       state: String,
                       page: Int,
                       per_page: Int)
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
    case getCommitsForRepo(fullName: String,
                           page: Int = 1,
                           per_page: Int = 30,
                           sha: String? = nil,
                           path: String? = nil,
                           author: String? = nil,
                           committer: String? = nil,
                           since: Date? = nil,
                           until: Date? = nil)
    ///  获取仓库的分支列表
    ///  - Parameters
    ///    - fullName : 仓库名 existorlive/githubclient
    case getBranchsForRepo(fullName: String)
    ///  获取仓库的贡献者列表
    ///  - Parameters
    ///    - fullName : 仓库名 existorlive/githubclient
    case getContributorsForRepo(fullName: String)
    ///  获取仓库的issue列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - state: 状态  open/closed
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getIssuesForRepo(fullName: String,
                          state: String,
                          page: Int,
                          per_page: Int)
    ///  获取watch仓库的状态
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    case getWatchRepoStatus(fullName: String)
    ///  watch仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    case watchRepo(fullName: String)
    ///  取消watch仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    case unwatchRepo(fullName: String)
    ///  获取仓库的watchers列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getWatchersForRepo(fullName: String,
                            page: Int,
                            per_page: Int)
    ///  获取star仓库的状态
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    case getStarRepoStatus(fullName: String)
    ///  star仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    case starRepo(fullName: String)
    ///  取消star仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    case unstarRepo(fullName: String)
    ///  获取仓库的stargazers列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getStargazersForRepo(fullName: String,
                              page: Int,
                              per_page: Int)
    ///  fork 仓库
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - organization: 组织名：  fork 仓库到组织下
    ///    - name: fork 后的仓库名
    ///    - default_branch_only: 是否只fork 默认分支
    case forkRepo(fullName: String,
                  organization: String?,
                  name: String?,
                  default_branch_only: Bool = false)
    ///  获取仓库的fork列表
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getForksForRepo(fullName: String,
                         page: Int,
                         per_page: Int)
    ///  获取仓库的开发语言信息
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    case getLanguagesInfoForRepo(fullName: String)
    ///  获取仓库的workflow
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getWorkflowsForRepo(fullName: String,
                             page: Int,
                             per_page: Int)
    ///  获取仓库的workflow的执行记录
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowId:  workflowId
    ///    - page: 页号 从 1 开始
    ///    - per_page: pageSize
    case getWorkflowRunsForRepo(fullName: String,
                                workflowId: String,
                                page: Int,
                                per_page: Int)
    /// 从新执行仓库的workflow的某次执行
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowRunId:  workflowRunId
    case rerunWorkflowRunForRepo(fullName: String,
                                 workflowRunId: String)
    /// 取消仓库的workflow的某次执行
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowRunId:  workflowRunId
    case cancelWorkflowRunForRepo(fullName: String,
                                  workflowRunId: String)
    ///  获取仓库的workflow的某次执行的日志
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - workflowRunId:  workflowRunId
    case getWorkflowRunLogForRepo(fullName: String,
                                  workflowRunId: String)
    ///  获取仓库的指定目录内容
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - path:  目录的路径
    ///    - ref: 分支，传空使用默认分支
    case getDirContentForRepo(fullName: String,
                              path: String,
                              ref: String?)
    ///  获取仓库的指定文件内容
    ///  - Parameters
    ///    - fullName: 仓库名 existorlive/githubclient
    ///    - path:  仓库的路径
    ///    - ref: 分支，传空使用默认分支
    ///    - mediaType: 文件内容返回的类型 （text，html 或 raw）
    case getFileContentForRepo(fullName: String,
                               path: String,
                               ref: String?,
                               mediaType: ZLGithubMediaType)
    
    // MARK: other
    ///  获取Github支持的开发语言列表
    case getDevelopLanguageList
    ///  将代码渲染为markdown
    case renderCodeToMarkdown(code: String)
    
    
    // MARK: 非Github API
    case getAPPCommonConfig
}











