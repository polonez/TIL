//
//  Debug.swift
//  reactive
//
//  Created by Fred on 2020/06/05.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    func debug<E>(_ debugString: String) -> Observable<E> where Element == E {
        return Debug(source: self.asObservable(), debugString: debugString)
    }
}

private final class Debug<Element>: Observable<Element> {
    private let scheduler: SchedulerType

    init(source: Observable<Element>, debugString: String, scheduler: SchedulerType = CurrentThreadScheduler()) {
        self.scheduler = scheduler
        let subscriptionHandler: SubscriptionHandler = { observer in
            return scheduler.schedule(()) { (_) -> Disposable in
                let obs = Observer<Element> { event in
                    switch event {
                    case let .next(element):
                        NSLog("[debug:\(debugString)] onNext: \(element)")
                        observer.on(.next(element))
                    case let .error(error):
                        NSLog("[debug:\(debugString)] onError: \(error)")
                        observer.on(.error(error))
                    case .completed:
                        NSLog("[debug:\(debugString)] onCompleted")
                        observer.on(.completed)
                    }
                }
                return source.subscribe(obs)
            }
        }
        super.init(subscriptionHandler)
    }
}
