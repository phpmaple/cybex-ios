//
//  OpenedOrdersActions.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct OpenedOrdersState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    
    var data: BehaviorRelay<[LimitOrderStatus]?> = BehaviorRelay(value: nil)
}

struct FetchOpenedOrderAction: Action {
    var data: [LimitOrderStatus]
    var all: Bool = false
}
