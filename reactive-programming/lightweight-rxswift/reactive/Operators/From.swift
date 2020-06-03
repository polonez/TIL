//
//  From.swift
//  reactive
//
//  Created by Fred on 2020/06/03.
//  Copyright © 2020 etude. All rights reserved.
//

extension Observable {
    static func from<Elements: Sequence>(_ items: Elements) -> Observable<Element> where Elements.Element == Element {
        return From(items: items)
    }
}

private final class From<Elements: Sequence>: Observable<Elements.Element> {
    typealias Element = Elements.Element

    init(items: Elements) {
        let subscriptionHandler: SubscriptionHandler = { observer in
            for item in items {
                observer.onNext(item)
            }
            observer.onCompleted()
            return Disposables.create()
        }
        super.init(subscriptionHandler)
    }
}
