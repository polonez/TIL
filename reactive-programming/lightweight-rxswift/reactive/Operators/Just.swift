//
//  Just .swift
//  reactive
//
//  Created by Fred on 2020/06/03.
//  Copyright © 2020 etude. All rights reserved.
//

extension Observable {
    static func just(_ item: Element) -> Observable<Element> {
        return Just(item: item)
    }
}

private final class Just<ResultType>: Observable<ResultType> {
    typealias Element = ResultType

    init(item: Element) {
        let subscriptionHandler: SubscriptionHandler = { observer in
            observer.onNext(item)
            observer.onCompleted()
            return Disposables.create()
        }
        super.init(subscriptionHandler)
    }
}
