//
//  OrderBookCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftyJSON
import Reachability

protocol OrderBookCoordinatorProtocol {
    
    func openDecimalNumberVC(_ sender: UIView, maxDecimal: Int, selectedDecimal: Int, senderVC: OrderBookViewController)
}

protocol OrderBookStateManagerProtocol {
    var state: OrderBookState { get }

    func subscribe(_ pair: Pair, depth: Int, count: Int)
    func unSubscribe(_ pair: Pair ,depth: Int ,count: Int)
    func resetData(_ pair: Pair)

    func updateMarketListHeight(_ height: CGFloat)
    
    func orderbookServerConnect()
}

class OrderBookCoordinator: NavCoordinator {
    var store = Store<OrderBookState>(
        reducer: orderBookReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    let service = MDPWebSocketService("", quoteName: "")

}

extension OrderBookCoordinator: OrderBookCoordinatorProtocol {
    func openDecimalNumberVC(_ sender: UIView, maxDecimal: Int, selectedDecimal: Int, senderVC: OrderBookViewController) {        
        let count = (maxDecimal + 1) / 4 != 0 ? 4 : (maxDecimal + 1) % 4
        
        guard let vc = R.storyboard.comprehensive.recordChooseViewController() else { return }
        vc.preferredContentSize = CGSize(width: 82, height: 35 * count)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.popoverBackgroundViewClass = CybexPopoverBackgroundView.self
        vc.popoverPresentationController?.sourceView = sender
        vc.popoverPresentationController?.sourceRect = CGRect(x: 35, y: 0, width: sender.width, height: sender.height)
        vc.popoverPresentationController?.delegate = senderVC
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        vc.popoverPresentationController?.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.white.hexString(true)]
        vc.typeIndex = .orderbook
        vc.delegate = senderVC
        vc.maxCount = maxDecimal
        vc.count = count
        vc.selectedIndex = selectedDecimal - (maxDecimal + 1 - count)
        vc.coordinator = RecordChooseCoordinator(rootVC: self.rootVC)
        senderVC.present(vc, animated: true) {
            vc.view.superview?.cornerRadius = 1
        }
    }
}

extension OrderBookCoordinator: OrderBookStateManagerProtocol {
    var state: OrderBookState {
        return store.state
    }

    func subscribe(_ pair: Pair, depth: Int, count: Int) {
        guard let baseInfo = appData.assetInfo[pair.base],
            let quoteInfo = appData.assetInfo[pair.quote] else { return }
        if !service.checkNetworConnected() {
            service.baseName = baseInfo.symbol
            service.quoteName = quoteInfo.symbol
            service.mdpServiceDidConnected.delegate(on: self) { (self, _) in
                self.subscribe(pair, depth: depth, count: count)
                self.monitorService()
            }
            service.tickerDataDidReceived.delegate(on: self) { (self, price) in
                print("----ticker: \(price)")
                self.store.dispatch(FetchLastPriceAction(price: price))
            }
            
            service.orderbookDataDidReceived.delegate(on: self) { (self, orderbook) in
                print("----order book: pair.base: \(pair.base) pair.quote: \(pair.quote)   \(orderbook)")
                self.store.dispatch(FetchedOrderBookData(data: orderbook, pair: pair))
            }
            service.reconnect()
        }
        else {
            self.service.subscribeOrderBook(depth, count: count)
            self.store.dispatch(ChangeDepthAndCountAction(depth: depth, count: count))
            self.service.subscribeTicker()
        }
    }
    
    func unSubscribe(_ pair: Pair ,depth: Int ,count: Int) {
        if service.checkNetworConnected() {
            self.service.unSubscribeOrderBook(depth, count: count)
            self.service.unSubscribeTicker()
        }
    }

    func monitorService() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }
            switch reachability.connection {
            case .wifi, .cellular:
                if self.rootVC.topViewController is OrderBookViewController {
                    self.service.reconnect()
                }
            case .none:
                self.service.disconnect()
                break
            }
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            if self.rootVC.topViewController is OrderBookViewController {
                self.service.reconnect()
            }
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (note) in
            self.service.disconnect()
        }
    }

    func disconnect() {
        service.disconnect()
    }

    func resetData(_ pair: Pair) {
        self.store.dispatch(FetchedOrderBookData(data: nil, pair: pair))
    }

    func updateMarketListHeight(_ height: CGFloat) {
        if let vc = self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] as? MarketViewController {
            vc.pageContentViewHeight.constant = height + 50
        }
    }
    
    func orderbookServerConnect() {
        service.connect()
    }
}
