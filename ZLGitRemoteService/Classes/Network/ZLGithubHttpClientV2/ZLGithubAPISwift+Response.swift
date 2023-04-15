//
//  ZLGithubAPISwift+Response.swift
//  ZLGitRemoteService
//
//  Created by 朱猛 on 2023/4/13.
//

import Foundation
import MJExtension
import Alamofire


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
                .getStargazersForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubUserModel>(isArray: true))
        case .currentUserGists,
                .getGistsForUser:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubGistModel>(isArray: true))
        case .getRepoReadMeInfo(_, _, let isHTMLContent):
            return isHTMLContent ? .string : .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubContentModel>())
        case .getPRsForRepo:
             return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubPullRequestModel>(isArray: true))
        case .getCommitsForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubCommitModel>(isArray: true))
        case .getBranchsForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubRepositoryBranchModel>(isArray: true))
        case .getContributorsForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubUserModel>(isArray: true))
        case .getIssuesForRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubIssueModel>(isArray: true))
        case .forkRepo:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubRepositoryModel>())
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
        case .getLanguagesInfoForRepo:
            return .jsonObject
        default:
            return .data

        }
    }
}
