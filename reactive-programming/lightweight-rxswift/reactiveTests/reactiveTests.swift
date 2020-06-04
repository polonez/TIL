//
//  reactiveTests.swift
//  reactiveTests
//
//  Created by Fred on 2020/06/02.
//  Copyright © 2020 etude. All rights reserved.
//

import XCTest
@testable import reactive

class reactiveTests: XCTestCase {
    var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
    }

    func testObservable() throws {
        let items = [1, 2, 3]
        var result = [Int]()
        let disposable = Observable<Int>
            .create { (observer) -> Disposable in
                for item in items {
                    observer.onNext(item)
                    Thread.sleep(forTimeInterval: 1)
                    print("sleep 1")
                }
                return Disposables.create()
            }
            .subscribe(onNext: { (value) in
                result.append(value)
            })

        print("outside")
        disposable.disposed(by: disposeBag)

        XCTAssertEqual(result, items)
//        XCTAssertEqual(disposable.isDisposed, false)
//        disposeBag = DisposeBag()
//        XCTAssertEqual(disposable.isDisposed, true)
    }

    func testDisposed() throws {
        let values = [3, 2, 1]
        var result = [Int]()
        let disposable = Observable.from(values)
            .subscribe(onNext: { (value) in
                result.append(value)
            })

        disposable.disposed(by: disposeBag)

        XCTAssertEqual(result, values)

//        XCTAssertEqual(disposable.isDisposed, true)
//        disposeBag = DisposeBag()
//        XCTAssertEqual(disposable.isDisposed, true)
    }
}

class reactiveOperatorsTests: XCTestCase {
    var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
    }

    func testJust() throws {
        var result = [Int]()
        let items = [1, 3, 5]
        let disposable = Observable.just(items)
            .subscribe(onNext: { (value) in
                result.append(contentsOf: value)
            })

        disposable
            .disposed(by: disposeBag)

        XCTAssertEqual(disposable.isDisposed, true)

        XCTAssertEqual(result, items)
    }

    func testFrom() throws {
        let items = [2, 4, 6]
        var result = [Int]()
        Observable.from(items)
            .subscribe(onNext: { (value) in
                result.append(value)
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, items)
    }

    func testMap() throws {
        let items = [1, 2, 3]
        var result = [Int]()
        Observable<Int>
            .create { (observer) -> Disposable in
                for item in items {
                    observer.onNext(item)
                }
                return Disposables.create()
            }
            .map { $0 * $0 }
            .subscribe(onNext: { (value) in
                result.append(value)
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, items.map { $0 * $0 })
    }

    func testMapError() throws {
        enum ReactiveError: Error {
            case foo
            case bar
        }
        var result = [Int]()
        Observable<Int>
            .create { (observer) -> Disposable in
                observer.onNext(1)
                observer.onNext(2)
                observer.onError(ReactiveError.foo)
                observer.onNext(4)
                observer.onNext(5)
                observer.onError(ReactiveError.bar)
                return Disposables.create()
            }
            .map { $0 * $0 }
            .mapError(mapping: { (error) in
                if let reactiveError = error as? ReactiveError {
                    if case .foo = reactiveError {
                        return 10
                    }
                }
                throw ReactiveError.bar
            })
            .map { $0 + 1 }
            .mapError(mapping: { (error) in
                if let reactiveError = error as? ReactiveError {
                    if case .bar = reactiveError {
                        return 20
                    }
                }
                throw ReactiveError.foo
            })
            .subscribe(onNext: { (value) in
                result.append(value)
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, [2, 5, 11, 17, 26, 20])
    }
}
