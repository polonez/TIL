//
//  Observable.swift
//  reactive
//
//  Created by Fred on 2020/06/02.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

protocol ObservableType {
    associatedtype Element
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element
    func asObservable() -> Observable<Element>
}

extension ObservableType {
    static func create(_ subscription: @escaping (Observer<Element>) -> Disposable) -> Observable<Element> {
        return Observable(subscription)
    }

    func subscribe(_ on: @escaping (Event<Element>) -> Void) -> Disposable {
        let observer = Observer<Element> { (event) in
            return on(event)
        }
        return self.subscribe(observer)
    }

    func subscribe(onNext: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil) -> Disposable {

        let obs = Observer<Element> { (event) in // Event<Observer<Element>.Element>
            switch event {
            case .next(let element):
                onNext?(element)
            case .error(let error):
                onError?(error)
                onCompleted?()
            case .completed:
                onCompleted?()
            }
        }

        return subscribe(obs)
    }

    func asObservable() -> Observable<Element> {
        return Observable.create { o in
            return self.subscribe(o)
        }
    }
}

class Observable<E>: ObservableType {
    typealias Element = E
    typealias SubscriptionHandler = ((Observer<Element>) -> Disposable)

    private let subscriptionHandler: SubscriptionHandler

    init(_ subscriptionHandler: @escaping SubscriptionHandler) {
        self.subscriptionHandler = subscriptionHandler
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == Element {
        return subscriptionHandler(Observer(observer))
    }
}

extension Observable {
    func asObservable() -> Observable<E> {
        return self
    }
}

