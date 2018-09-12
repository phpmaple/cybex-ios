//
//  TestFakes.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import ReSwift

struct TestAppState: StateType {
    var testValue: Int?

    init() {
        testValue = nil
    }
}

struct TestStringAppState: StateType {
    var testValue: String

    init() {
        testValue = "Initial"
    }
}

extension TestStringAppState: Equatable {
    static func == (lhs: TestStringAppState, rhs: TestStringAppState) -> Bool {
        return lhs.testValue == rhs.testValue
    }
}

struct TestNonEquatable: StateType {
    var testValue: NonEquatable

    init() {
        testValue = NonEquatable()
    }
}

struct NonEquatable {
    var testValue: String

    init() {
        testValue = "Initial"
    }
}

struct TestCustomAppState: StateType {
    var substate: TestCustomSubstate

    init(substate: TestCustomSubstate) {
        self.substate = substate
    }

    init(substateValue value: Int = 0) {
        substate = TestCustomSubstate(value: value)
    }

    struct TestCustomSubstate {
        var value: Int
    }
}

struct SetValueAction: StandardActionConvertible {
    let value: Int?
    static let type = "SetValueAction"

    init(_ value: Int?) {
        self.value = value
    }

    init(_ standardAction: StandardAction) {
        value = standardAction.payload!["value"] as! Int?
    }

    func toStandardAction() -> StandardAction {
        return StandardAction(type: SetValueAction.type, payload: ["value": value as AnyObject],
                              isTypedAction: true)
    }
}

struct SetValueStringAction: StandardActionConvertible {
    var value: String
    static let type = "SetValueStringAction"

    init(_ value: String) {
        self.value = value
    }

    init(_ standardAction: StandardAction) {
        value = standardAction.payload!["value"] as! String
    }

    func toStandardAction() -> StandardAction {
        return StandardAction(type: SetValueStringAction.type,
                              payload: ["value": value as AnyObject],
                              isTypedAction: true)
    }
}

struct SetCustomSubstateAction: StandardActionConvertible {
    var value: Int
    static let type = "SetCustomSubstateAction"

    init(_ value: Int) {
        self.value = value
    }

    init(_ standardAction: StandardAction) {
        value = standardAction.payload!["value"] as! Int
    }

    func toStandardAction() -> StandardAction {
        return StandardAction(type: SetValueStringAction.type,
                              payload: ["value": value as AnyObject],
                              isTypedAction: true)
    }
}

struct SetNonEquatableAction: Action {
    var value: NonEquatable
    static let type = "SetNonEquatableAction"

    init(_ value: NonEquatable) {
        self.value = value
    }
}

struct TestReducer {
    func handleAction(action: Action, state: TestAppState?) -> TestAppState {
        var state = state ?? TestAppState()

        switch action {
        case let action as SetValueAction:
            state.testValue = action.value
            return state
        default:
            return state
        }
    }
}

struct TestValueStringReducer {
    func handleAction(action: Action, state: TestStringAppState?) -> TestStringAppState {
        var state = state ?? TestStringAppState()

        switch action {
        case let action as SetValueStringAction:
            state.testValue = action.value
            return state
        default:
            return state
        }
    }
}

struct TestCustomAppStateReducer {
    func handleAction(action: Action, state: TestCustomAppState?) -> TestCustomAppState {
        var state = state ?? TestCustomAppState()

        switch action {
        case let action as SetCustomSubstateAction:
            state.substate.value = action.value
            return state
        default:
            return state
        }
    }
}

struct TestNonEquatableReducer {
    func handleAction(action: Action, state: TestNonEquatable?) ->
        TestNonEquatable {
        var state = state ?? TestNonEquatable()

        switch action {
        case let action as SetNonEquatableAction:
            state.testValue = action.value
            return state
        default:
            return state
        }
    }
}

class TestStoreSubscriber<T>: StoreSubscriber {
    var receivedStates: [T] = []

    func newState(state: T) {
        receivedStates.append(state)
    }
}

class DispatchingSubscriber: StoreSubscriber {
    var store: Store<TestAppState>

    init(store: Store<TestAppState>) {
        self.store = store
    }

    func newState(state: TestAppState) {
        // Test if we've already dispatched this action to
        // avoid endless recursion
        if state.testValue != 5 {
            store.dispatch(SetValueAction(5))
        }
    }
}

class CallbackStoreSubscriber<T>: StoreSubscriber {
    let handler: (T) -> Void

    init(handler: @escaping (T) -> Void) {
        self.handler = handler
    }

    func newState(state: T) {
        handler(state)
    }
}
