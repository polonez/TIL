//
//  Map.swift
//  reactive
//
//  Created by Fred on 2020/06/02.
//  Copyright © 2020 etude. All rights reserved.
//

extension ObservableType {
    func map<R>(mapping: @escaping ((Element) -> R)) -> Observable<R> {
        return Map(source: self.asObservable(), mapping: mapping)
    }
}

private final class Map<SourceType, ResultType>: Observable<ResultType> {
    typealias Element = SourceType
    typealias Mapping = (SourceType) -> ResultType

    private let scheduler: SchedulerType

    init(source: Observable<SourceType>, mapping: @escaping Mapping, scheduler: SchedulerType = CurrentThreadScheduler()) {
        self.scheduler = scheduler
        let subscriptionHandler: SubscriptionHandler = { observer in
            return scheduler.schedule(()) { (_) -> Disposable in
                let obs = Observer<Element> { event in
                    switch event {
                    case let .next(element):
                        observer.on(.next(mapping(element)))
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
