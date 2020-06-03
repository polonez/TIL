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

// TODO: maperror, flatmap, combinelatest, zip, Subject

private final class Map<SourceType, ResultType>: Observable<ResultType> {
    typealias Element = SourceType
    typealias Mapping = (SourceType) -> ResultType

    init(source: Observable<SourceType>, mapping: @escaping Mapping) {
        let subscriptionHandler: SubscriptionHandler = { observer in
            let obs = Observer<Element> { event in
                switch event {
                case let .next(element):
                    observer.on(.next(mapping(element)))
                case let .error(error):
                    observer.on(.error(error))
                    observer.on(.completed)
                case .completed:
                    observer.on(.completed)
                }
            }
            return source.subscribe(obs)
        }
        super.init(subscriptionHandler)
    }
}
