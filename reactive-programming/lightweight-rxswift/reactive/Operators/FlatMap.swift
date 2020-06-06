//
//  FlatMap.swift
//  reactive
//
//  Created by Fred on 2020/06/04.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

extension ObservableType {
    func flatMap<O: ObservableType>(_ source: O) -> Observable<Element> where O.Element == Element {
        return FlatMap(source: source.asObservable())
    }
}

private final class FlatMap<Element>: Observable<Element> {
    init(source: Observable<Element>) {
        let subscriptionHandler: SubscriptionHandler = { observer in
            return source.subscribe(onNext: { (element) in
                observer.onNext(element)
            }, onError: { (error) in
                observer.onError(error)
            }, onCompleted: {
                observer.onCompleted()
            })
        }
        super.init(subscriptionHandler)
    }
}
