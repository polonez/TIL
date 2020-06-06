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

    func subscribe(onNext: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil) -> Disposable {
        let disposable: Disposable
        if let disposed = onDisposed {
            disposable = Disposables.create(with: disposed)
        }
        else {
            disposable = Disposables.create()
        }

        let obs = Observer<Element> { (event) in // Event<Observer<Element>.Element>
            switch event {
            case .next(let element):
                onNext?(element)
            case .error(let error):
                onError?(error)
                disposable.dispose()
            case .completed:
                onCompleted?()
                disposable.dispose()
            }
        }

        return Disposables.create(self.subscribe(obs), disposable)
    }

    func asObservable() -> Observable<Element> {
        return Observable.create { o in
            return self.subscribe(o)
        }
    }
}

class Observable<Element>: ObservableType {
    typealias SubscriptionHandler = ((Observer<Element>) -> Disposable)

    fileprivate let subscriptionHandler: SubscriptionHandler
    fileprivate let scheduler: SchedulerType

    init(_ subscriptionHandler: @escaping SubscriptionHandler, scheduler: SchedulerType = CurrentThreadScheduler()) {
        self.subscriptionHandler = subscriptionHandler
//        self.scheduler = Scheduler(queue: DispatchQueue.init(label: "random", qos: .background, autoreleaseFrequency: .workItem))
        self.scheduler = scheduler
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == Element {
        return scheduler.schedule(()) { (_) -> Disposable in
            return self.subscriptionHandler(Observer(observer))
        }
    }
}

extension Observable {
    func asObservable() -> Observable<Element> {
        return self
    }
}
