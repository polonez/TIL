//
//  Suffix.swift
//  reactive
//
//  Created by Fred on 2020/06/06.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    func suffix<E>(_ count: Int) -> Observable<E> where Element == E {
        return Suffix(source: self.asObservable(), count: count)
    }
}

private final class Suffix<Element>: Observable<Element> {
    init(source: Observable<Element>, count maximum: Int) {
        var lastElements = [Element]()
        let subscriptionHandler: SubscriptionHandler = { observer in
            let obs = Observer<Element> { event in
                switch event {
                case let .next(element):
                    lastElements.append(element)
                    if lastElements.count > maximum {
                        lastElements = Array(lastElements.dropFirst())
                    }
                case let .error(error):
                    observer.onError(error)
                case .completed:
                    lastElements.forEach { observer.onNext($0) }
                    observer.onCompleted()
                }
            }
            return source.subscribe(obs)
        }
        super.init(subscriptionHandler)
    }
}
