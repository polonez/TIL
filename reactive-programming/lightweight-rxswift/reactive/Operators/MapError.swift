//
//  MapError.swift
//  reactive
//
//  Created by Fred on 2020/06/04.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    func mapError<E>(mapping: @escaping ((Swift.Error) throws -> E)) -> Observable<E> where Element == E {
        return MapError(source: self.asObservable(), mappingError: mapping)
    }
}

private final class MapError<Element>: Observable<Element> {
    typealias MappingError = (Swift.Error) throws -> Element

    init(source: Observable<Element>, mappingError: @escaping MappingError) {
        let subscriptionHandler: SubscriptionHandler = { observer in
            let obs = Observer<Element> { event in
                switch event {
                case let .next(element):
                    observer.on(.next(element))
                case let .error(error):
                    do {
                        try observer.on(.next(mappingError(error)))
                    } catch let e {
                        observer.onError(e)
                    }
                case .completed:
                    observer.on(.completed)
                }
            }
            return source.subscribe(obs)
        }
        super.init(subscriptionHandler)
    }
}
