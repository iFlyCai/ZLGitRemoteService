//
//  ZLGithubAPISwift+Response.swift
//  ZLGitRemoteService
//
//  Created by 朱猛 on 2023/4/13.
//

import Foundation
import MJExtension
import Alamofire
import Kanna


// MARK: - ZLGithubAPIResultParseProtocol 处理协议
protocol ZLGithubAPIResultParseProtocol {
    func parseData(api:ZLGithubAPISwift,response: HTTPURLResponse, data: Data) -> Any?
}

// MARK: - ZLGithubAPIObjectTypeWrapper 转Object
struct ZLGithubAPIObjectTypeWrapper<T : NSObject>: ZLGithubAPIResultParseProtocol {
   
    var isArray: Bool = false
    
    func parseData(api:ZLGithubAPISwift,response: HTTPURLResponse, data: Data) -> Any? {
        if isArray {
            return T.mj_objectArray(withKeyValuesArray: data)
        } else {
            return T.mj_object(withKeyValues: data)
        }
    }
}

// MARK: - ZLGithubAPIResultCustomParseWrapper 自定义返回处理
struct ZLGithubAPIResultCustomParseWrapper: ZLGithubAPIResultParseProtocol {
   
    var block: ((ZLGithubAPISwift,HTTPURLResponse, Data) -> Any?)?
    
    func parseData(api:ZLGithubAPISwift, response: HTTPURLResponse, data: Data) -> Any? {
        return block?(api,response,data)
    }
}


// MARK: - ZLGithubAPIResultType
enum ZLGithubAPIResultType {
    case data           // 返回 Data
    case jsonObject     // 返回 Dictionary
    case string         // 返回 String
    case object(parseWrapper: ZLGithubAPIResultParseProtocol) // 返回 Object
    case custom(parseWrapper: ZLGithubAPIResultParseProtocol) // 自定义返回
}

// MARK: - ZLGithubAPISwift+SuccessStatusCodes
extension ZLGithubAPISwift {
    
    static let commonStatusCodes = Set(200...299)
    var successStatusCodes: Set<Int> {
        switch self {
        case .getFollowUserStatus,
                .getBlockUserStatus,
                .getStarRepoStatus,
                .getWatchRepoStatus:
            var codes = ZLGithubAPISwift.commonStatusCodes
            codes.insert(404)
            return codes
        default:
            return ZLGithubAPISwift.commonStatusCodes
        }
    }
}

// MARK: - ZLGithubAPISwift+ResultType
extension ZLGithubAPISwift {
    
    var resultType: ZLGithubAPIResultType {
        switch self {
        case .currentUserRepoUrl,
                .getRepositoriesForUser,
                .currentUserStarreds,
                .getStarredForUser,
                .getForksForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubRepositoryModel>(isArray: true))
        case .getBlockedUsers,
                .getFollowersForUser,
                .getFollowingsForUser,
                .getWatchersForRepo,
                .getStargazersForRepo,
                .getContributorsForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubUserModel>(isArray: true))
        case .currentUserGists,
                .getGistsForUser:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubGistModel>(isArray: true))
        case .getRepoReadMeInfo(_, _, let mediaType):
            switch mediaType {
            case .json,.json_text,.json_full:
                return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubContentModel>())
            case .json_raw,.json_html:
                return .string
            }
        case .getPRsForRepo:
             return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubPullRequestModel>(isArray: true))
        case .getCommitsForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubCommitModel>(isArray: true))
        case .getBranchsForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubRepositoryBranchModel>(isArray: true))
        case .getIssuesForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubIssueModel>(isArray: true))
        case .forkRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubRepositoryModel>())
        case .getDirContentForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubContentModel>(isArray: true))
        case .getEventsForUser,
                .getReceivedEventsForUser:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubEventModel>(isArray: true))
        case .notification:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubNotificationModel>(isArray: true))
        case .updateCurrentUserInfo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubUserModel>())
        case .getFileContentForRepo(_, _, _ , let mediaType):
            switch mediaType {
            case .json,.json_text,.json_full:
                return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubContentModel>())
            case .json_raw,.json_html:
                return .string
            }
        case .getWorkflowsForRepo:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, _, data in
                if let jsonObject = (data as NSObject).mj_JSONObject() as? [String: Any?],
                   let workflows = jsonObject["workflows"] {
                    return ZLGithubRepoWorkflowModel.mj_objectArray(withKeyValuesArray: workflows)
                }
                return nil
            }))
        case .getWorkflowRunsForRepo:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, _, data in
                if let jsonObject = (data as NSObject).mj_JSONObject() as? [String: Any?],
                   let workflows = jsonObject["workflow_runs"] {
                    return ZLGithubRepoWorkflowRunModel.mj_objectArray(withKeyValuesArray: workflows)
                }
                return nil
            }))
        case .userInfo(let login):
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, _, data in
                if let jsonObject = (data as NSObject).mj_JSONObject() as? [String: Any?],
                   let type = jsonObject["type"] as? String {
                    if type == "Organization" {
                        return ZLGithubOrgModel.mj_object(withKeyValues: data)
                    } else {
                        return ZLGithubUserModel.mj_object(withKeyValues: data)
                    }
                }
                return nil
            }))
        case .getAPPCommonConfig:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, _, data in
                let appVersion = ZLDeviceInfo.getAppVersion()
                if let jsonObject = (data as NSObject).mj_JSONObject() as? [String: Any?],
                   let config = jsonObject[appVersion] as? [String: Any?] {
                    return ZLGithubConfigModel.mj_object(withKeyValues: config)
                }
                return nil
            }))
        case .getDevelopLanguageList:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, _, data in
                if let jsonObject = (data as NSObject).mj_JSONObject() as? [[String: Any?]] {
                    return jsonObject.compactMap { item in
                        item["name"] as? String
                    }
                }
                return nil
            }))
        case .getFollowUserStatus:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, _ in
                if response.statusCode == 404 {
                    return ["isFollow":false]
                } else {
                    return ["isFollow":true]
                }
            }))
        case .getBlockUserStatus:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, _ in
                if response.statusCode == 404 {
                    return ["isBlock":false]
                } else {
                    return ["isBlock":true]
                }
            }))
        case .getWatchRepoStatus:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, _ in
                if response.statusCode == 404 {
                    return ["isWatch":false]
                } else {
                    return ["isWatch":true]
                }
            }))
        case .getStarRepoStatus:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, _ in
                if response.statusCode == 404 {
                    return ["isStar":false]
                } else {
                    return ["isStar":true]
                }
            }))
        case .getTrendingDevelopers:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, data in
                return ZLGithubAPISwift.parseDataForTrendingDevelopers(api: api,
                                                                       response: response,
                                                                       data: data)
            }))
        case .getTrendingRepos:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, data in
                return ZLGithubAPISwift.parseDataForTrendingRepo(api: api,
                                                                 response: response,
                                                                 data: data)
            }))
        case .searchUser:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, data in
                return ZLGithubAPISwift.parseDataForSearchUsers(api: api,
                                                                response: response,
                                                                data: data)
            }))
        case .searchRepo:
            return .custom(parseWrapper: ZLGithubAPIResultCustomParseWrapper(block: { api, response, data in
                return ZLGithubAPISwift.parseDataForSearchRepos(api: api,
                                                                response: response,
                                                                data: data)
            }))
        case .getLanguagesInfoForRepo:
            return .jsonObject
        case .renderCodeToMarkdown:
            return .string
        default:
            return .data

        }
    }
}

// MARK: - ZLGithubAPISwift + deal with response
extension ZLGithubAPISwift {
    
    static func parseDataForTrendingRepo(api: ZLGithubAPISwift,
                                         response: HTTPURLResponse,
                                         data: Data) -> Any? {
       
        var repos = [ZLGithubRepositoryModel]()
        do {
            let htmlDoc = try HTML(html:data, encoding: .utf8 )
    
            for article in htmlDoc.xpath("//article") {
                
                let h2 = article.xpath("//h2").first
                let p = article.xpath("//p").first
                let a = h2?.xpath("//a").first
                
                guard var fullName = a?["href"] else { continue }
                fullName = String(fullName.suffix(from: fullName.index(after: fullName.startIndex)))
                
                let repoModel = ZLGithubRepositoryModel()
                repoModel.full_name = fullName
                repoModel.name = String(fullName.split(separator: "/").last ?? "")
                
                let owner = ZLGithubUserBriefModel()
                let loginName = String(fullName.split(separator: "/").first ?? "")
                owner.loginName = loginName
                owner.avatar_url = "https://avatars.githubusercontent.com/\(loginName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
                repoModel.owner = owner
                
                let set = NSCharacterSet(charactersIn: " \n") as CharacterSet
                if let desc = p?.content?.trimmingCharacters(in: set){
                    repoModel.desc_Repo = desc
                }
                
                for span in article.xpath("//span") {
                    if let itemprop = span["itemprop"],
                       itemprop == "programmingLanguage" {
                        repoModel.language = span.content
                        break
                    }
                }
                
                for svg in article.xpath("//svg") {
                    let ariaLabel = svg["aria-label"]
                    if "star" == ariaLabel,
                       let content = svg.parent?.content {
                        var str =  content.trimmingCharacters(in: set)
                        str = (str as NSString).replacingOccurrences(of: ",", with: "")
                        if let num = Int(str) {
                            repoModel.stargazers_count = num
                        }
                    }
                    if "fork" == ariaLabel,
                       let content = svg.parent?.content {
                        var str =  content.trimmingCharacters(in: set)
                        str = (str as NSString).replacingOccurrences(of: ",", with: "")
                        if let num = Int(str) {
                            repoModel.forks_count = num
                        }
                    }
                }
                repos.append(repoModel)
            }
        } catch {
            
        }
        
        return repos
    }
    
    
    static func parseDataForTrendingDevelopers(api: ZLGithubAPISwift,
                                               response: HTTPURLResponse,
                                               data: Data) -> Any? {
        var users = [ZLGithubUserModel]()
        do {
            let htmlDoc = try HTML(html:data, encoding: .utf8 )
            
            for article in htmlDoc.xpath("//article") {
                
                guard let id = article["id"],
                      id.hasPrefix("pa-") else {
                    continue
                }
                let user = ZLGithubUserModel()
                let login = String(id.split(separator: "-").last ?? "")
                user.loginName = login
                user.avatar_url = "https://avatars.githubusercontent.com/\(login.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
                
                if let a = article.xpath("//h1[@class=\"h3 lh-condensed\"]/a").first {
                    let set = NSCharacterSet(charactersIn: " \n") as CharacterSet
                    user.name = a.innerHTML?.trimmingCharacters(in: set)
                }
                users.append(user)
            }
        
        } catch {
           
        }
        return users
    }
    
    
    static func parseDataForSearchUsers(api: ZLGithubAPISwift,
                                        response: HTTPURLResponse,
                                        data: Data) -> Any? {
        var searchModel = ZLSearchResultModel()
        if let jsonObject = (data as NSObject).mj_JSONObject() as? [String: Any?] {
            searchModel.incomplete_results = jsonObject["incomplete_results"] as? Bool ?? false
            searchModel.totalNumber = jsonObject["totalNumber"] as? UInt ?? 0
            searchModel.data = ZLGithubUserModel.mj_objectArray(withKeyValuesArray: jsonObject["items"]) as? [Any] ?? []
        }
        return searchModel
    }
    
    static func parseDataForSearchRepos(api: ZLGithubAPISwift,
                                        response: HTTPURLResponse,
                                        data: Data) -> Any? {
        var searchModel = ZLSearchResultModel()
        if let jsonObject = (data as NSObject).mj_JSONObject() as? [String: Any?] {
            searchModel.incomplete_results = jsonObject["incomplete_results"] as? Bool ?? false
            searchModel.totalNumber = jsonObject["totalNumber"] as? UInt ?? 0
            searchModel.data = ZLGithubRepositoryModel.mj_objectArray(withKeyValuesArray: jsonObject["items"]) as? [Any] ?? []
        }
        return searchModel
    }
}
