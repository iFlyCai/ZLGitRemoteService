//
//  ZLGithubRepositoryModel.swift
//  ZLServiceFramework
//
//  Created by 朱猛 on 2021/4/8.
//  Copyright © 2021 ZM. All rights reserved.
//

import UIKit
import MJExtension

@objcMembers open class ZLGithubLicenseModel: ZLBaseObject{
    open var node_id: String?
    open var name: String?                         // Apache License 2.0
    open var spdxId: String?                       // Apache-2.0
    open var key: String?                          // apache-2.0
}


@objcMembers open class ZLGithubRepositoryBriefModel: ZLBaseObject {
   
    open var name: String?
    open var full_name: String?
    open var html_url: String?
    open var desc_Repo: String?
    open var language: String?                          // 主要语言
    open var languageColor: String?                     // 语言color
    open var stargazers_count: Int = 0                  // star数
    open var forks_count: Int = 0                       // fork数
    open var isPriva: Bool = false
    
    open var owner: ZLGithubUserBriefModel?              // owener
}


@objcMembers open class ZLGithubRepositoryModel: ZLBaseObject {
    
    open var repo_id: String?
    open var node_id: String?
    
    open var name: String?
    open var full_name: String?
    open var desc_Repo: String?
    open var html_url: String?
    open var isPriva: Bool = false
    open var homepage_url: String?
    open var language: String?                          // 主要语言
    open var default_branch: String?                    // 默认分支
    open var sourceRepoFullName: String?                // parent repo
    
    open var open_issues_count: Int = 0                 // open issue数
    open var stargazers_count: Int = 0                  // star数
    open var subscribers_count: Int = 0                 // watch数
    open var forks_count: Int = 0                       // fork数
    
    open var updated_at: Date?
    open var created_at: Date?
    open var pushed_at: Date?
    
    open var owner: ZLGithubUserBriefModel?              // owener
    open var license: ZLGithubLicenseModel?              // license信息
    
    open override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["repo_id":"id",
                "desc_Repo":"description",
                "isPriva":"private",
                "sourceRepoFullName":"source.full_name",
                "homepage_url":"homepage"]
    }
    
    open override func mj_newValue(fromOldValue oldValue: Any!, property: MJProperty!) -> Any! {
        if "created_at" == property.name ||
            "updated_at" == property.name ||
            "pushed_at" == property.name {
            if let str: String = oldValue as? String{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                return dateFormatter.date(from: str)
            }
            return nil
        }
        return oldValue
    }
    

    class func supportsSecureCoding() -> Bool {
        return true
    }
}
