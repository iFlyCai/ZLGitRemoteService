//
//  ZLGithubRepositoryModel_Graphql.swift
//  ZLGitRemoteService
//
//  Created by 朱猛 on 2021/12/5.
//

import Foundation

extension ZLGithubRepositoryModel{
    
    convenience init(queryData: RepoInfoQuery.Data){
        self.init()
        node_id = queryData.repository?.nodeId
        repo_id = queryData.repository?.repoId == nil ? nil :String(queryData.repository!.repoId!)
        
        name = queryData.repository?.name
        full_name = queryData.repository?.fullName
        html_url = queryData.repository?.htmlUrl
        desc_Repo = queryData.repository?.descRepo
        homepage_url = queryData.repository?.homepageUrl
        isPriva = queryData.repository?.isPrivate ?? false
        language = queryData.repository?.primaryLanguage?.name
        default_branch = queryData.repository?.defaultBranchRef?.name
        open_issues_count = queryData.repository?.issues.totalCount ?? 0
        stargazers_count = queryData.repository?.stargazerCount ?? 0
        subscribers_count = queryData.repository?.watchers.totalCount ?? 0
        forks_count = queryData.repository?.forkCount ?? 0
        sourceRepoFullName = queryData.repository?.parent?.nameWithOwner
        
        let ownerModel = ZLGithubUserBriefModel()
        ownerModel.node_id = queryData.repository?.owner.nodeId
        ownerModel.loginName = queryData.repository?.owner.login
        ownerModel.html_url = queryData.repository?.owner.htmlUrl
        ownerModel.avatar_url = queryData.repository?.owner.avatarUrl
        ownerModel.type = queryData.repository?.isInOrganization ?? false ? .organization : .user
        owner = ownerModel
        
        let licenseModel = ZLGithubLicenseModel()
        licenseModel.node_id = queryData.repository?.licenseInfo?.nodeId
        licenseModel.name = queryData.repository?.licenseInfo?.name
        licenseModel.spdxId = queryData.repository?.licenseInfo?.spdxId
        licenseModel.key = queryData.repository?.licenseInfo?.key
        license = licenseModel
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        created_at = dateFormatter.date(from: queryData.repository?.createdAt ?? "")
        updated_at = dateFormatter.date(from: queryData.repository?.updatedAt ?? "")
        pushed_at = dateFormatter.date(from: queryData.repository?.pushedAt ?? "")
    }
}

extension ZLGithubRepositoryBriefModel{
    
    convenience init(UserInfoQuery queryData: UserOrOrgInfoQuery.Data.User.PinnedItem.Node.AsRepository){
        self.init()
        name = queryData.name
        full_name = queryData.nameWithOwner
        desc_Repo = queryData.description
        language = queryData.primaryLanguage?.name
        languageColor = queryData.primaryLanguage?.color
        stargazers_count = queryData.stargazerCount
        html_url = queryData.url
        isPriva = queryData.isPrivate
        
        let userModel = ZLGithubUserBriefModel()
        owner = userModel
        userModel.loginName = queryData.owner.login
        userModel.avatar_url = queryData.owner.avatarUrl
        userModel.html_url = queryData.owner.url
    }
    
    convenience init(OrgInfoQuery queryData: UserOrOrgInfoQuery.Data.Organization.PinnedItem.Node.AsRepository){
        self.init()
        name = queryData.name
        full_name = queryData.nameWithOwner
        desc_Repo = queryData.description
        language = queryData.primaryLanguage?.name
        languageColor = queryData.primaryLanguage?.color
        stargazers_count = queryData.stargazerCount
        html_url = queryData.url
        isPriva = queryData.isPrivate
        
        let userModel = ZLGithubUserBriefModel()
        owner = userModel
        userModel.loginName = queryData.owner.login
        userModel.avatar_url = queryData.owner.avatarUrl
        userModel.html_url = queryData.owner.url
    }
    
    convenience init(UserPinnedItemQuery queryData: UserPinnedItemQuery.Data.User.PinnedItem.Node.AsRepository){
        self.init()
        name = queryData.name
        full_name = queryData.nameWithOwner
        desc_Repo = queryData.description
        language = queryData.primaryLanguage?.name
        languageColor = queryData.primaryLanguage?.color
        stargazers_count = queryData.stargazerCount
        forks_count = queryData.forkCount
        html_url = queryData.url
        isPriva = queryData.isPrivate
        
        let userModel = ZLGithubUserBriefModel()
        owner = userModel
        userModel.loginName = queryData.owner.login
        userModel.avatar_url = queryData.owner.avatarUrl
        userModel.html_url = queryData.owner.url
    }
    
    convenience init(OrgPinnedItemQuery queryData: OrgPinnedItemQuery.Data.Organization.PinnedItem.Node.AsRepository){
        self.init()
        name = queryData.name
        full_name = queryData.nameWithOwner
        desc_Repo = queryData.description
        language = queryData.primaryLanguage?.name
        languageColor = queryData.primaryLanguage?.color
        stargazers_count = queryData.stargazerCount
        forks_count = queryData.forkCount
        html_url = queryData.url
        isPriva = queryData.isPrivate
        
        let userModel = ZLGithubUserBriefModel()
        owner = userModel
        userModel.loginName = queryData.owner.login
        userModel.avatar_url = queryData.owner.avatarUrl
        userModel.html_url = queryData.owner.url
    }
    
    
    static func getRepositoryBriefModelArray(UserPinnedItemQuery queryData: UserPinnedItemQuery.Data) -> [ZLGithubRepositoryBriefModel] {
        var array = [ZLGithubRepositoryBriefModel]()
        if let nodes = queryData.user?.pinnedItems.nodes {
            for node in nodes{
                if let node = node as? UserPinnedItemQuery.Data.User.PinnedItem.Node,
                   let repoQueryData = node.asRepository {
                    array.append(ZLGithubRepositoryBriefModel(UserPinnedItemQuery: repoQueryData))
                }
            }
        }
        return array
    }
    
    static func getRepositoryBriefModelArray(OrgPinnedItemQuery queryData: OrgPinnedItemQuery.Data) -> [ZLGithubRepositoryBriefModel] {
        var array = [ZLGithubRepositoryBriefModel]()
        if let nodes = queryData.organization?.pinnedItems.nodes {
            for node in nodes{
                if let node = node as? OrgPinnedItemQuery.Data.Organization.PinnedItem.Node,
                   let repoQueryData = node.asRepository{
                    array.append(ZLGithubRepositoryBriefModel(OrgPinnedItemQuery: repoQueryData))
                }
            }
        }
        return array
    }
}
