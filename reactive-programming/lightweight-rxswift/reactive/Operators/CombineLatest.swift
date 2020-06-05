//
//  CombineLatest.swift
//  reactive
//
//  Created by Fred on 2020/06/04.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    static func combineLatest<O1: ObservableType, O2: ObservableType>(_ source1: O1, _ source2: O2,
                                                                      resultSelector: @escaping (O1.Element, O2.Element) throws -> Element) -> Observable<Element> {
        return CombineLatest(source1: source1.asObservable(), source2: source2.asObservable(), resultSelector: resultSelector)
    }

    static func combineLatest<O1: ObservableType, O2: ObservableType>(_ source1: O1, _ source2: O2) -> Observable<(O1.Element, O2.Element)> {
        return CombineLatest(source1: source1.asObservable(), source2: source2.asObservable(), resultSelector: { ($0, $1) })
    }
}

private final class CombineLatest<E1, E2, ResultType>: Observable<ResultType> {
//    private let scheduler: SchedulerType
    typealias ResultSelector = (E1, E2) throws -> ResultType

    init(source1: Observable<E1>, source2: Observable<E2>, resultSelector: @escaping ResultSelector) {
        var latestElement1: E1? = nil
        var latestElement2: E2? = nil

        var completed1: Bool = false
        var completed2: Bool = false

        let subscriptionHandler: SubscriptionHandler = { observer in
            let subscription1 = SingleDisposable()
            let subscription2 = SingleDisposable()

            let obs1 = Observer<E1> { (event) in
                switch event {
                case let .next(e1):
                    latestElement1 = e1
                    if let e2 = latestElement2 {
                        do {
                            let result = try resultSelector(e1, e2)
                            observer.onNext(result)
                        } catch {
//                            observer.onError(<#T##error: Error##Error#>)
                        }
                    }
                case let .error(error):
                    observer.onError(error)
                case .completed:
                    if completed2 {
                        observer.onCompleted()
                    } else {
                        completed1 = true
                    }
                }
            }
            let obs2 = Observer<E2> { (event) in
                switch event {
                case let .next(e2):
                    latestElement2 = e2
                    if let e1 = latestElement1 {
                        do {
                            let result = try resultSelector(e1, e2)
                            observer.onNext(result)
                        } catch {
//                            observer.onError(<#T##error: Error##Error#>)
                        }
                    }
                case let .error(error):
                    observer.onError(error)
                case .completed:
                    if completed1 {
                        observer.onCompleted()
                    } else {
                        completed2 = true
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
