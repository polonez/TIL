//
//  Observer.swift
//  reactive
//
//  Created by Fred on 2020/06/02.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

protocol ObserverType {
    associatedtype Element

    func on(_ event: Event<Element>)
}

extension ObserverType {
    func onNext(_ element: Element) {
        on(.next(element))
    }

    func onError(_ error: Swift.Error) {
        on(.error(error))
    }

    func onCompleted() {
        on(.completed)
    }
}

class Observer<E>: ObserverType {
    typealias Element = E
    typealias EventHandler = ((Event<Element>) -> Void)

    private let eventHandler: EventHandler

    init(_ eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
    }

    init<O: ObserverType>(_ observer: O) where O.Element == Element {
        self.eventHandler = observer.on
    }

    func on(_ event: Event<Element>) {
        eventHandler(event)
    }
}
