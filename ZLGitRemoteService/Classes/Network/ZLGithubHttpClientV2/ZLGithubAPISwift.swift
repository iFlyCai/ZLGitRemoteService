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
    
    /// 当前用户的Repo 包括private
    case currentUserRepoUrl(page: Int, perPage: Int)
    /// 当前用户的Star列表
    case currentUserStarreds(page: Int, perPage: Int)
    ///  当前用户的Gist列表
    case currentUserGists(page: Int, perPage: Int)
    /// 用户信息
    case userInfo(login: String)
    ///  获取follow用户状态
    case getFollowUserStatus(login: String)
    ///  follow 用户
    case followUser(login: String)
    ///  取消follow用户
    case unfollowUser(login: String)
    ///  获取block的用户列表
    case getBlockedUsers
    ///  获取block 用户状态
    case getBlockUserStatus(login: String)
    ///  block用户
    case blockUser(login: String)
    ///  取消block用户
    case unblockUser(login: String)
    ///  获取某个用户的公共仓库列表
    case getRepositoriesForUser(login: String, page: Int, perPage: Int)
    ///  获取某个用户的粉丝列表
    case getFollowersForUser(login: String, page: Int, perPage: Int)
    ///  获取某个用户的关注列表
    case getFollowingsForUser(login: String, page: Int, perPage: Int)
    ///  获取某个用户的star仓库列表
    case getStarredForUser(login: String, page: Int, perPage: Int)
    ///  获取某个用户的Gist列表
    case getGistsForUser(login: String, page: Int, perPage: Int)
}

extension String {
    var urlPathEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
}

extension ZLGithubAPISwift {
    
    static let GitHubAPIURL =  "https://api.github.com"
    
    var url: String {
        switch self {
        case .currentUserRepoUrl:
            return ZLGithubAPISwift.GitHubAPIURL + "/user/repos"
        case .userInfo(let login):
            return ZLGithubAPISwift.GitHubAPIURL + "/users/" + login.urlPathEncoding
        case .getFollowUserStatus(login: let login),
                .followUser(login: let login),
                .unfollowUser(login: let login):
            return ZLGithubAPISwift.GitHubAPIURL + "/user/following/" + login.urlPathEncoding
        case .getBlockedUsers:
            return ZLGithubAPISwift.GitHubAPIURL + "/user/blocks"
        case .getBlockUserStatus(login: let login),
                .blockUser(login: let login),
                .unblockUser(login: let login):
            return ZLGithubAPISwift.GitHubAPIURL + "/user/blocks/" + login.urlPathEncoding
        case .getRepositoriesForUser(let login, _, _):
            return ZLGithubAPISwift.GitHubAPIURL + "/users/" + login.urlPathEncoding + "/repos"
        case .getFollowersForUser(let login, _ , _):
            return ZLGithubAPISwift.GitHubAPIURL + "/users/" + login.urlPathEncoding + "/followers"
        case .getFollowingsForUser(let login, _, _):
            return ZLGithubAPISwift.GitHubAPIURL + "/users/" + login.urlPathEncoding + "/following"
        case .currentUserStarreds:
            return ZLGithubAPISwift.GitHubAPIURL + "/user/starred"
        case .currentUserGists:
            return ZLGithubAPISwift.GitHubAPIURL + "/gists"
        case .getStarredForUser(let login, _, _ ):
            return ZLGithubAPISwift.GitHubAPIURL + "/users/" + login.urlPathEncoding + "/starred"
        case .getGistsForUser(let login, _, _):
            return ZLGithubAPISwift.GitHubAPIURL + "/users/" + login.urlPathEncoding + "/gists"
        }
    }
}

extension ZLGithubAPISwift {
 
    var method: HTTPMethod {
        switch self {
        case .unfollowUser,
                .unblockUser:
            return .delete
        case .followUser,
                .blockUser:
            return .put
        default:
            return .get
        }
    }
}

extension ZLGithubAPISwift {
    var paramsEncoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
}

extension ZLGithubAPISwift {
    
    var params: [String: Any] {
        switch self {
        case .currentUserRepoUrl(let page, let perPage),
                .getRepositoriesForUser(_, let page, let  perPage),
                .getFollowersForUser(_, let page, let  perPage),
                .getFollowingsForUser(_, let page, let  perPage),
                .currentUserStarreds(let page, let perPage),
                .currentUserGists(let page, let perPage),
                .getStarredForUser(_, let page, let  perPage),
                .getGistsForUser(_, let page, let  perPage):
            
            return ["page": page,
                    "per_page": perPage]
        default:
            return [:]
        }
    }
}

extension ZLGithubAPISwift {
    
    var headers: [String: String] {
        switch self {
        case .blockUser,
                .unblockUser,
                .getBlockedUsers,
                .getBlockUserStatus:
            return ["Accept":"application/vnd.github.giant-sentry-fist-preview+json"]
        default:
            return [:]
        }
    }
}

extension ZLGithubAPISwift {
    
    static let commonStatusCodes = Set(200...299)
    var successStatusCodes: Set<Int> {
        switch self {
        case .getFollowUserStatus,
                .getBlockUserStatus:
            var codes = ZLGithubAPISwift.commonStatusCodes
            codes.insert(404)
            return codes
        default:
            return ZLGithubAPISwift.commonStatusCodes
        }
    }
}


protocol ZLGithubAPIResultParseProtocol {
    func parseData(api:ZLGithubAPISwift,response: HTTPURLResponse, data: Data) -> Any?
}

extension ZLGithubAPISwift {
    
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
    
    struct ZLGithubAPIResultCustomParseWrapper: ZLGithubAPIResultParseProtocol {
       
        var block: ((ZLGithubAPISwift,HTTPURLResponse, Data) -> Any?)?
        
        func parseData(api:ZLGithubAPISwift, response: HTTPURLResponse, data: Data) -> Any? {
            return block?(api,response,data)
        }
    }
    
    
    enum ZLGithubAPIResultType {
        case data
        case jsonObject
        case commonStr
        case object(parseWrapper: ZLGithubAPIResultParseProtocol)
        case custom(parseWrapper: ZLGithubAPIResultParseProtocol)
    }
    
    
    var resultType: ZLGithubAPIResultType {
        switch self {
        case .currentUserRepoUrl,
                .getRepositoriesForUser,
                .currentUserStarreds,
                .getStarredForUser:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubRepositoryModel>(isArray: true))
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
        case .getBlockedUsers,
                .getFollowersForUser,
                .getFollowingsForUser:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubUserModel>(isArray: true))
        case .currentUserGists,
                .getGistsForUser:
            return .object(parseWrapper: ZLGithubAPIObjectTypeWrapper<ZLGithubGistModel>(isArray: true))
        default:
            return .data

        }
    }
}


