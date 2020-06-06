//
//  Interval.swift
//  reactive
//
//  Created by Fred on 2020/06/06.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType where Element: FixedWidthInteger {
    static func interval(_ period: DispatchTimeInterval, on scheduler: SchedulerType = CurrentThreadScheduler()) -> Observable<Element> {
        return Interval(period: period, on: scheduler)
    }
}

private final class Interval<Element>: Observable<Element> {
    init(period: DispatchTimeInterval, on scheduler: SchedulerType) {
        let subscriptionHandler: SubscriptionHandler = { observer in
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

            return Disposables.create()
        }
        super.init(subscriptionHandler)
    }
}
