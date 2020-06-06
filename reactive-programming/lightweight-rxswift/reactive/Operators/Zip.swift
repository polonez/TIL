//
//  Zip.swift
//  reactive
//
//  Created by Fred on 2020/06/04.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    static func zip<O1: ObservableType, O2: ObservableType>(_ source1: O1, _ source2: O2) -> Observable<(O1.Element, O2.Element)> {
        return Zip(source1: source1.asObservable(), source2: source2.asObservable())
    }
}

private final class Zip<E1, E2>: Observable<(E1, E2)> {
//    private let scheduler: SchedulerType

    init(source1: Observable<E1>, source2: Observable<E2>) {
        var latestElements1 = [E1]()
        var latestElements2 = [E2]()

        var done = [Bool](repeating: false, count: 2)

        let subscriptionHandler: SubscriptionHandler = { observer in
            let subscription1 = SingleDisposable()
            let subscription2 = SingleDisposable()

            let obs1 = Observer<E1> { (event) in
                switch event {
                case let .next(e1):
                    if let e2 = latestElements2.first {
                        _ = latestElements2.removeFirst()
                        observer.onNext((e1, e2))
                    } else {
                        latestElements1.append(e1)
                    }
                case let .error(error):
                    observer.onError(error)
                case .completed:
                    done[0] = true
                    if done.allSatisfy({ $0 }) {
                        observer.onCompleted()
                    }
                }
            }

            let obs2 = Observer<E2> { (event) in
                switch event {
                case let .next(e2):
                    if let e1 = latestElements1.first {
                        _ = latestElements1.removeFirst()
                        observer.onNext((e1, e2))
                    } else {
                        latestElements2.append(e2)
                    }
                case let .error(error):
                    observer.onError(error)
                case .completed:
                    done[1] = true
                    if done.allSatisfy({ $0 }) {
                        observer.onCompleted()
                    }
                }
            }

            subscription1.setDisposable(source1.subscribe(obs1))
            subscription2.setDisposable(source2.subscribe(obs2))

            return Disposables.create(subscription1, subscription2)
        }

        super.init(subscriptionHandler)
    }
}
