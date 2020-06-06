//
//  Delay.swift
//  reactive
//
//  Created by Fred on 2020/06/05.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    func delay(_ timeInterval: DispatchTimeInterval, on scheduler: SchedulerType = CurrentThreadScheduler()) -> Observable<Element> {
        return Delay(source: self.asObservable(), timeInterval: timeInterval, on: scheduler)
    }
}

private final class Delay<Element>: Observable<Element> {
    private let scheduler: SchedulerType

    init(source: Observable<Element>, timeInterval: DispatchTimeInterval, on scheduler: SchedulerType) {
        self.scheduler = scheduler
        let subscriptionHandler: SubscriptionHandler = { observer in
            return scheduler.schedule((), after: timeInterval) { (_) -> Disposable in
                let obs = Observer<Element> { event in
                    switch event {
                    case let .next(element):
                        observer.on(.next(element))
                    case let .error(error):
                        observer.on(.error(error))
                    case .completed:
                        observer.on(.completed)
                    }
                }
                return source.subscribe(obs)
            }
        }
        super.init(subscriptionHandler)
    }
}
