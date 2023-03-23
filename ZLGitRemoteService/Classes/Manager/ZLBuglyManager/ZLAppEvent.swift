//
//  ZLAppEvent.swift
//  ZLServiceFramework
//
//  Created by 朱猛 on 2021/4/2.
//  Copyright © 2021 ZM. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import Umbrella

public let analytics : Umbrella.Analytics<ZLAppEvent> = {
    let tmpAnalytics =  Umbrella.Analytics<ZLAppEvent>()
    tmpAnalytics.register(provider:ZLFirebaseProvider())
    return tmpAnalytics
}()


final class BuglyProvider: ProviderType {
  func log(_ eventName: String, parameters: [String: Any]?) {
    ZLBuglyManager.shared().log(eventName, parameters: parameters)
  }
}

final class ZLFirebaseProvider : ProviderType {
    func log(_ eventName: String, parameters: [String : Any]?) {
        FirebaseAnalytics.Analytics.logEvent(eventName, parameters: parameters)
    }
}


@objcMembers public class ZLAppEventForOC : NSObject {
            
    public class func urlUse(url : String){
        analytics.log(.URLUse(url: url))
    }
    
    public class func urlFailed(url : String, error: String?){
        analytics.log(.URLFailed(url: url , error: error ?? ""))
    }
    
    public class func dbActionFailed(sql:String,error:String?){
        analytics.log(.DBActionFailed(sql: sql, error: error ?? ""))
    }
}




public enum ZLAppEvent {
    case githubOAuth(result:Bool,step:Int,msg:String,duration:TimeInterval)
    case viewItem(name:String)
    case URLUse(url:String)
    case URLFailed(url:String,error:String)
    case ScreenView(screenName:String,screenClass:String)
    case SearchItem(key:String)
    case DBActionFailed(sql:String,error:String)
    case AD(success:Bool)
}

extension ZLAppEvent : EventType {
    public func name(for provider: ProviderType) -> String? {
        switch self {
        case .githubOAuth:
            return "githubOAuth"
        case .viewItem:
            return AnalyticsEventViewItem
        case .URLUse:
            return "URLUse"
        case .URLFailed:
            return "URLFailed"
        case .ScreenView:
            return AnalyticsEventScreenView
        case .SearchItem:
            return AnalyticsEventSearch
        case .DBActionFailed:
            return "DBActionFailed"
        case .AD:
            return "Advertisement"
        }
        
        

    }
    public func parameters(for provider: ProviderType) -> [String: Any]? {
        switch self {
        case .githubOAuth(let result,let step,let msg,let duration):
            return ["result": result,
                    "step": step,
                    "msg": msg,
                    "duration": duration]
        case .viewItem(let name):
            return ["itemName":name]
        case .URLUse(let url):
            return ["url":url]
        case .URLFailed(let url, let error):
            return ["url":url,"error":error]
        case .ScreenView(let screenName, let screenClass):
            return [AnalyticsParameterScreenName:screenName,AnalyticsParameterScreenClass:screenClass]
        case .SearchItem(let key):
            return ["key":key]
        case .DBActionFailed(let sql, let error):
            return ["sql":sql,"error":error]
        case .AD(let success):
            return ["success":success]
        }
    }
}
