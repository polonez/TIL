//
//  Prefix.swift
//  reactive
//
//  Created by Fred on 2020/06/06.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    func prefix<E>(_ count: Int) -> Observable<E> where Element == E {
        return Prefix(source: self.asObservable(), count: count)
    }
}

private final class Prefix<Element>: Observable<Element> {
    init(source: Observable<Element>, count maximum: Int) {
        var count = 0
        let subscriptionHandler: SubscriptionHandler = { observer in
            let obs = Observer<Element> { event in
                switch event {
                case let .next(element):
                    count += 1
                    if count > maximum {
                        observer.onCompleted()
                    } else {
                        observer.onNext(element)
                    }
                case let .error(error):
                    observer.onError(error)
                case .completed:
                    observer.onCompleted()
                }
            }
            return source.subscribe(obs)
        }
        super.init(subscriptionHandler)
    }
}
