//
//  ETO.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON
import DifferenceKit
import RxSwift

struct ETOBannerModel:HandyJSON {
    var id:String = ""
    var adds_banner_mobile:String = ""
    var adds_banner_mobile__lang_en:String = ""
}

struct ETOUserAuditModel:HandyJSON {
    var kyc_result: String = "" //not_start, ok
    var status: String = "" //unstart: 没有预约 waiting,ok,reject
}

struct ETOShortProjectStatusModel:HandyJSON {
    var current_percent:Int = 0
    var status:ProjectState? //finish pre ok
    var finish_at:Date!
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.finish_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }
}

struct ETOUserModel:HandyJSON {
    var current_base_token_count:Double = 0
}

enum ETOTradeHistoryStatus:String, HandyJSONEnum {
    case ok = ""
    
    case projectNotExist = "1"
    case userNotInWhiteList = "2"
    case userFallShort = "3"
    case notInCrowding = "4"
    case projectControlClosed = "5"
    case currencyError = "6"
    case crowdLimit = "7"
    case userCrowdLimit = "8"
    case notMatchUserCrowdMinimum = "9"
    case projectLimitLessThanUserMinimum = "10"
    case userResidualLessThanUserMinimum = "11"
    case portionMoreThanProjectTotalLimit = "12"
    case portionMoreThanUserLimit = "13"
    case moreThanAccuracy = "14"
    case transferWithLockup = "15"
    case fail = "101"
    
    func showTitle() -> String {
        if let reason = self.rawValue.int {
            switch reason {
            case 1...11, 15:
                return R.string.localizable.eto_invalid_sub.key.localized()
            case 12...14:
                return R.string.localizable.eto_invalid_partly_sub.key.localized()
            case 16:
                return R.string.localizable.eto_refund.key.localized()
            default:
                return R.string.localizable.eto_receive_success.key.localized()
            }
        }
        else {
            return R.string.localizable.eto_receive_success.key.localized()
        }
    }
}

enum ETOIEOType:String, HandyJSONEnum {
    case receive
    case send
    
    func showTitle() -> String {
        switch self {
        case .receive:
            return R.string.localizable.eto_record_receive.key.localized()
        case .send:
            return R.string.localizable.eto_record_send.key.localized()
        }
    }
}

struct ETOTradeHistoryModel: HandyJSON, Differentiable, Equatable, Hashable {
    var project_id:Int = 0
    var project_name: String = ""
    var ieo_type: ETOIEOType = .receive //receive: 参与ETO send: 到账成功
    var reason:ETOTradeHistoryStatus = .ok
    var created_at:Date!
    var token_count:String = ""
    var token:String = ""
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.created_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }
    
    static func == (lhs: ETOTradeHistoryModel, rhs: ETOTradeHistoryModel) -> Bool {
        return lhs.project_id == rhs.project_id && lhs.project_name == rhs.project_name && lhs.ieo_type == rhs.ieo_type && lhs.reason == rhs.reason && lhs.created_at == rhs.created_at && lhs.token_count == rhs.token_count && lhs.token == rhs.token
    }
    
    var hashValue: Int {
        return project_id
    }
}

struct ETOProjectModel:HandyJSON {
    var id: Int = 0
    var adds_logo_mobile: String = ""
    var adds_logo_mobile__lang_en: String = ""
    var adds_keyword: String = ""
    var adds_keyword__lang_en: String = ""
    var adds_advantage: String = ""
    var adds_advantage__lang_en: String = ""
    var adds_website: String = ""
    var adds_website__lang_en: String = ""
    var adds_detail: String = ""
    var adds_detail__lang_en: String = ""
    var adds_share_mobil: String = ""
    var adds_share_mobil__lang_en: String = ""
    var adds_buy_desc: String = ""
    var adds_buy_desc__lang_en: String = ""
    var adds_whitelist: String = ""
    var adds_whitelist__lang_en: String = ""
    var adds_whitepaper: String = ""
    var adds_whitepaper__lang_en: String = ""

    var status: ProjectState? // finish pre ok
    var name: String = ""
    var receive_address: String = ""
    var current_percent:Double = 0
    
    var start_at:Date?
    var end_at:Date?
    var finish_at:Date?
    var offer_at:Date?
    var lock_at:Date?
    var create_at:Date?
    
    var token_name: String = ""
    var base_token_name: String = ""
    var rate:Int = 0 //1 base
    
    var base_max_quota: Double = 0
    var base_accuracy: Int = 0
    var base_min_quota: Double = 0
    
    var project: String = ""
    
    var is_user_in:String = "0" // 0不准预约 1可以预约
    
    var t_total_time: String = ""
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.start_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.end_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.finish_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.offer_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.lock_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.create_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }
}

enum ProjectState : String ,HandyJSONEnum{
    case finish = "finish"
    case pre = "pre"
    case ok = "ok"
    
    func description() -> String {
        switch self {
        case .finish:
            return R.string.localizable.eto_project_finish.key.localized()
        case .pre:
            return R.string.localizable.eto_project_comming.key.localized()
        case .ok:
            return R.string.localizable.eto_project_progress.key.localized()
        default:
            return ""
        }
    }
}


struct ETOProjectViewModel {
    var icon: String = ""
    var icon_en: String = ""
    var name: String = ""
    var key_words: String = ""
    var key_words_en: String = ""
    var status: String = ""
    var current_percent: String = ""
    var progress: Double = 0
    var projectModel: ETOProjectModel?
    var timeState: String {
        if let data = self.projectModel, let state = data.status {
            if state == .finish {
                return R.string.localizable.eto_project_time_finish.key.localized()
            }
            else if state == .pre {
                return R.string.localizable.eto_project_time_pre.key.localized()
            }
            else {
                return R.string.localizable.eto_project_time_comming.key.localized()
            }
        }
        return ""
    }
    
    var time: String {
        if let data = self.projectModel, let state = data.status {
            if state == .finish {
                if data.t_total_time == "" {
                    return transferTimeType(Int(data.end_at!.timeIntervalSince1970 - data.start_at!.timeIntervalSince1970))
                }
                return transferTimeType(Int(data.t_total_time)!,type: true)
            }
            else if state == .pre {
                return transferTimeType(Int(data.start_at!.timeIntervalSince1970 - Date().timeIntervalSince1970),type: true)
            }
            else {
                return transferTimeType(Int(Date().timeIntervalSince1970 - data.start_at!.timeIntervalSince1970),type: true)
            }
        }
        return ""
    }
    
    var etoDetail: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_name.key.localized() + data.name + "\n"
            result += R.string.localizable.eto_token_name.key.localized() + data.token_name + "\n"
            result += R.string.localizable.eto_start_time.key.localized() + data.start_at!.iso8601 + "\n"
            result += R.string.localizable.eto_end_time.key.localized() + data.end_at!.iso8601 + "\n"
            result += R.string.localizable.eto_start_at.key.localized() + data.lock_at!.iso8601 + "\n"
            if data.offer_at == nil {
                result += R.string.localizable.eto_token_releasing_time.key.localized() + R.string.localizable.eto_project_immediate.key.localized() + "\n"
            }
            else {
                  result += R.string.localizable.eto_token_releasing_time.key.localized() + data.offer_at!.iso8601 + "\n"
            }
            result += R.string.localizable.eto_exchange_ratio.key.localized() + "1" + data.base_token_name + "=" + "\(data.rate)" + data.token_name
        }
        return result
    }

    var project_website: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_online.key.localized() + data.adds_website + "\n"
            result += R.string.localizable.eto_project_white_Paper.key.localized() + data.adds_whitepaper + "\n"
            result += R.string.localizable.eto_project_detail.key.localized() + data.adds_detail
        }
        return result
    }
    
    var project_website_en: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_online.key.localized() + data.adds_website__lang_en + "\n"
            result += R.string.localizable.eto_project_white_Paper.key.localized() + data.adds_whitepaper__lang_en + "\n"
            result += R.string.localizable.eto_project_detail.key.localized() + data.adds_detail__lang_en
        }
        return result
    }
    
    init(_ projectModel : ETOProjectModel) {
        self.projectModel = projectModel
        self.name = projectModel.name
        self.key_words = projectModel.adds_keyword
        self.key_words_en = projectModel.adds_keyword__lang_en
        self.status = projectModel.status!.description()
        self.current_percent = (projectModel.current_percent * 100).string(digits:0, roundingMode: .down) + "%"
        self.progress = projectModel.current_percent
        self.icon = projectModel.adds_logo_mobile
        self.icon_en = projectModel.adds_logo_mobile__lang_en
    }
}



