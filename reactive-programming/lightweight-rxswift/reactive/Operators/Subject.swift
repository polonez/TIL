//
//  Subject.swift
//  reactive
//
//  Created by Fred on 2020/06/04.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation


/// Represents an object that is both an observable sequence as well as an observer.
///
/// Each notification is broadcasted to all subscribed observers.
final class PublishSubject<Element>: Observable<Element>, ObserverType {
    private var observers = [Observer<Element>]()
    init() {
        let subscriptionHandler: SubscriptionHandler = { observer in
            let obs = Observer<Element> { event in
                switch event {
                case let .next(element):
                    self.observers.forEach { (o) in
                        o.onNext(element)
                    }
                case let .error(error):
                    self.observers.forEach { (o) in
                        o.onError(error)
                    }
                case .completed:
                    self.observers.forEach { (o) in
                        o.onCompleted()
                    }
                }
            }

            return Disposables.create()
        }
        super.init(subscriptionHandler)
    }

    func on(_ event: Event<Element>) {
        <#code#>
    }

    override func subscribe<O: ObserverType>(_ observer: O) -> Disposable where Element == O.Element {
        self.observers.append(observer)
        return Disposables.create()
    }
}
