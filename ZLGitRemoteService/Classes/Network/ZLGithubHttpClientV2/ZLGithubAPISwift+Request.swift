//
//  ZLGithubAPISwift+Parameter.swift
//  ZLGitRemoteService
//
//  Created by 朱猛 on 2023/4/13.
//

import Foundation
import Alamofire

extension ZLGithubAPISwift {
 
    var method: HTTPMethod {
        switch self {
        case .unfollowUser,
                .unblockUser,
                .unwatchRepo,
                .unstarRepo:
            return .delete
        case .followUser,
                .blockUser,
                .watchRepo,
                .starRepo:
            return .put
        case .forkRepo,
                .cancelWorkflowRunForRepo,
                .rerunWorkflowRunForRepo:
            return .post
        default:
            return .get
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
        case .getRepoReadMeInfo(_, _, let isHTMLContent):
            return isHTMLContent ? ["Accept": "application/vnd.github.v3.html+json"] : [:]
        default:
            return [:]
        }
    }
}


extension ZLGithubAPISwift {
    var paramsEncoding: ParameterEncoding {
        switch self {
        case .forkRepo,
                .cancelWorkflowRunForRepo,
                .rerunWorkflowRunForRepo:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
}

extension Dictionary where Key == String, Value == Any? {
    func toParameters() -> [String: Any] {
        self.compactMapValues { value in
            return value
        }
    }
}

extension ZLGithubAPISwift {
    
    var params: [String: Any] {
        var params: [String: Any?] = [:]
        switch self {
        case .currentUserRepoUrl(let page, let per_page),
                .getRepositoriesForUser(_, let page, let  per_page),
                .getFollowersForUser(_, let page, let  per_page),
                .getFollowingsForUser(_, let page, let  per_page),
                .currentUserStarreds(let page, let per_page),
                .currentUserGists(let page, let per_page),
                .getStarredForUser(_, let page, let  per_page),
                .getGistsForUser(_, let page, let  per_page),
                .getWatchersForRepo(_ , let page, let per_page),
                .getStargazersForRepo(_, let page, let per_page),
                .getForksForRepo(_, let page, let per_page),
                .getWorkflowsForRepo(_ , let page, let per_page),
                .getWorkflowRunsForRepo(_, _, let page, let per_page):
            params = ["page": page,
                      "per_page": per_page]
        case .getRepoReadMeInfo(_,let ref,_):
            params = ["ref": ref].toParameters()
        case .getPRsForRepo(_, let state, let page, let perPage):
            params = ["state": state,
                      "page": page,
                      "per_page": perPage]
        case .getCommitsForRepo(_,
                                let page,
                                let per_page,
                                let sha,
                                let path,
                                let author,
                                let committer,
                                let since,
                                let until):
            params = ["page":page,
                      "per_page":per_page,
                      "sha":sha,
                      "path":path,
                      "author":author,
                      "committer":committer,
                      "since":(since as NSDate?)?.dateStrForYYYYMMDDTHHMMSSZForTimeZone0,
                      "until":(until as NSDate?)?.dateStrForYYYYMMDDTHHMMSSZForTimeZone0]
        case .getIssuesForRepo(_, let state, let page, let per_page):
            params = ["state": state,
                      "page": page,
                      "per_page": per_page]
        case .forkRepo(_, let organization, let name, let default_branch_only):
            params = ["organization": organization,
                      "name": name,
                      "default_branch_only": default_branch_only]
        default:
            params = [:]
        }
        return params.toParameters()
    }
}
