//
//  ZLUserInfoModelForView.swift
//  AFNetworking
//
//  Created by 朱猛 on 2021/12/4.
//

import Foundation

// MARK: ----- ZLGithubOrgInfoModelForView -----
@objcMembers open class ZLGithubOrgInfoModelForView: ZLBaseObject {
    open var organizationInfo: ZLGithubOrgModel?
    
    open var viewerIsAMember: Bool = false                       // 是否为当前org的成员
    open var pinnedRepos: [ZLGithubRepositoryBriefModel] = []    // 固定的repo
}

// MARK: ----- ZLUserInfoModelForView -----
@objcMembers open class ZLGithubUserInfoModelForView: ZLBaseObject{
    open var userInfo: ZLGithubUserModel?
    
    open var isViewer: Bool = false                                     // 是否为当前仓库所有者
    open var contributionData: [ZLGithubUserContributionData] = []
    open var totalContributions: Int = 0
    open var pinnedRepos: [ZLGithubRepositoryBriefModel] = []
}
