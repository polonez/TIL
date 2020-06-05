//
//  Scheduler.swift
//  reactive
//
//  Created by Fred on 2020/06/04.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

protocol SchedulerType {
    var queue: DispatchQueue { get }
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable
    func schedule<StateType>(_ state: StateType, after delay: DispatchTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable
}

extension SchedulerType {
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let disposable = SingleDisposable()
        self.queue.async {
            if disposable.isDisposed {
                return
            }
            disposable.setDisposable(action(state))
        }
        return disposable
    }

    func schedule<StateType>(_ state: StateType, after delay: DispatchTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        let disposable = SingleDisposable()
        self.queue.asyncAfter(deadline: .now() + delay) {
            if disposable.isDisposed {
                return
            }
            disposable.setDisposable(action(state))
        }
        return disposable
    }
}

class CurrentThreadScheduler: SchedulerType {
    var queue: DispatchQueue {
        OperationQueue.current!.underlyingQueue!
    }
}

class Scheduler: SchedulerType {
    let queue: DispatchQueue

    init(queue: DispatchQueue) {
        self.queue = queue
    }
}

//protocol ScheduledItemType {
//    func invoke()
//}
//
//struct ScheduledItem<T>: ScheduledItemType, Disposable {
//    typealias Action = (T) -> Disposable
//
//    private let action: Action
//    private let state: T
//
//    private let disposable = SingleDisposable()
//
//    var isDisposed: Bool {
//        return self.disposable.isDisposed
//    }
//
//    init(action: @escaping Action, state: T) {
//        self.action = action
//        self.state = state
//    }
//
//    func invoke() {
//        self.disposable.setDisposable(self.action(self.state))
//    }
//
//    func dispose() {
//        self.disposable.dispose()
//    }
//}

final class SingleDisposable: Disposable {
    private var disposable: Disposable?
    var isDisposed = false

    func setDisposable(_ disposable: Disposable) {
        self.disposable = disposable
    }

    func dispose() {
        guard let disposable = self.disposable else { fatalError("disposable has not been set") }
        disposable.dispose()
        self.disposable = nil
    }
}
