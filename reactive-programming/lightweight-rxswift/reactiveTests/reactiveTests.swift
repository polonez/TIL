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
        let expectation = XCTestExpectation(description: "observable create")
        Observable<Int>
            .create { (observer) -> Disposable in
                for item in items {
                    observer.onNext(item)
                }
                observer.onCompleted()
                return Disposables.create()
            }
            .subscribe(onNext: { (value) in
                result.append(value)
            }, onCompleted: {
                XCTAssertEqual(result, items)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDisposed() throws {
        let values = [3, 2, 1]
        var result = [Int]()
        let expectation = XCTestExpectation(description: "observable disposed")
        let disposable = Observable.from(values)
            .subscribe(onNext: { (value) in
                result.append(value)
            }, onCompleted: {
                XCTAssertEqual(result, values)
                expectation.fulfill()
            })

        disposable.disposed(by: disposeBag)
        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(disposable.isDisposed, false)
        disposeBag = DisposeBag()
        XCTAssertEqual(disposable.isDisposed, true)
    }

    func testJust() throws {
        var result = [Int]()
        let items = [1, 3, 5]
        let expectation = XCTestExpectation(description: "just")
        let disposable = Observable.just(items)
            .subscribe(onNext: { (value) in
                result.append(contentsOf: value)
            }, onCompleted: {
                XCTAssertEqual(result, items)
                expectation.fulfill()
            })

        disposable
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 3.0)

        disposeBag = DisposeBag()
        XCTAssertEqual(disposable.isDisposed, true)
    }
}

class reactiveOperatorsTests: XCTestCase {
    var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
    }

    func testFrom() throws {
        let items = [2, 4, 6]
        var result = [Int]()
        let expectation = XCTestExpectation(description: "from")
        Observable.from(items)
            .subscribe(onNext: { (value) in
                result.append(value)
            }, onCompleted: {
                XCTAssertEqual(result, items)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 3.0)
    }

    func testMap() throws {
        let items = [1, 2, 3]
        var result = [Int]()
        let expectation = XCTestExpectation(description: "observable map")

        Observable.from(items)
            .map { $0 * $0 }
            .subscribe(onNext: { (value) in
                result.append(value)
            }, onCompleted: {
                XCTAssertEqual(result, items.map { $0 * $0 })
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    private enum ReactiveError: Error {
        case foo
        case bar
    }

    func testMapError() throws {
        var result = [Int]()
        let expectation = XCTestExpectation(description: "observable map error")
        Observable<Int>
            .create { (observer) -> Disposable in
                observer.onNext(1)
                observer.onNext(2)
                observer.onError(ReactiveError.foo)
                observer.onNext(4)
                observer.onNext(5)
                observer.onError(ReactiveError.bar)
                observer.onCompleted()
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
            }, onCompleted: {
                XCTAssertEqual(result, [2, 5, 11, 17, 26, 20])
                expectation.fulfill()
            }, onDisposed: {
            })
            .disposed(by: disposeBag)

            wait(for: [expectation], timeout: 3.0)
    }

    func testDebug() throws {
        let items = [1, 2, 3]
        var result1 = [Int]()
        let expectation1 = XCTestExpectation(description: "observable debug")

        Observable.from(items)
            .debug("debug test 1")
            .map { $0 * $0 }
            .debug("debug test 2")
            .subscribe(onNext: { (value) in
                result1.append(value)
            }, onCompleted: {
                XCTAssertEqual(result1, items.map { $0 * $0 })
                expectation1.fulfill()
            }, onDisposed: {
                NSLog("debug disposed")
            })
            .disposed(by: disposeBag)

        let expectation2 = XCTestExpectation(description: "observable debug")
        var result2 = [Int]()

        Observable<Int>
            .create { (observer) -> Disposable in
                observer.onNext(1)
                observer.onError(ReactiveError.foo)
                observer.onNext(2)
                observer.onCompleted()
                return Disposables.create()
            }
            .debug("debug test 2")
            .subscribe(onNext: { (value) in
                result2.append(value)
            }, onCompleted: {
                XCTAssertEqual(result2, [1, 2])
                expectation2.fulfill()
            }, onDisposed: {
                NSLog("debug disposed")
            })
            .disposed(by: disposeBag)

        wait(for: [expectation1, expectation2], timeout: 5.0)
    }

    func testCombineLatest() throws {
        let items1 = [1, 2, 3, 4]
        let items2 = [10, 20, 30, 40]
        var result1 = [Int]()
        let expectation = XCTestExpectation(description: "combineLatest")

        let a = Observable.from(items1)
        let b = Observable.from(items2)

        Observable<(Int, Int)>.combineLatest(
            a,
            b.delay(.milliseconds(100))
        )
            .map { arg -> Int in
                let (x, y) = arg
                return x + y
            }
            .subscribe(onNext: { (value) in
                result1.append(value)
            }, onCompleted: {
                XCTAssertEqual(result1, [14, 24, 34, 44])
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        var result2 = [Int]()

        Observable<(Int, Int)>.combineLatest(
            a.delay(.milliseconds(100)),
            b
        )
            .map { arg -> Int in
                let (x, y) = arg
                return x + y
            }
            .subscribe(onNext: { (value) in
                result2.append(value)
            }, onCompleted: {
                XCTAssertEqual(result2, [41, 42, 43, 44])
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testPrefix() throws {
        let items = [1, 2, 3, 4]
        let prefixCount = 3
        var result = [Int]()
        let expectation = XCTestExpectation(description: "prefix")

        Observable<Int>.create { (observer) -> Disposable in
            for item in items {
                observer.onNext(item)
            }
            observer.onCompleted()
            return Disposables.create()
        }
        .prefix(prefixCount)
        .subscribe(onNext: { (value) in
            result.append(value)
        }, onCompleted: {
            XCTAssertEqual(result, Array(items.prefix(prefixCount)))
            expectation.fulfill()
        })
        .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testSuffix() throws {
        let items = [1, 2, 3, 4]
        let prefixCount = 3
        var result = [Int]()
        let expectation = XCTestExpectation(description: "suffix")

        Observable<Int>.create { (observer) -> Disposable in
            for item in items {
                observer.onNext(item)
            }
            observer.onCompleted()
            return Disposables.create()
        }
        .suffix(prefixCount)
        .subscribe(onNext: { (value) in
            result.append(value)
        }, onCompleted: {
            XCTAssertEqual(result, Array(items.suffix(prefixCount)))
            expectation.fulfill()
        })
        .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testCombineLatestWithInterval() throws { // FIXME with interval
        let items1 = [1, 2, 3, 4]
        let items2 = [10, 20, 30, 40]
        var result = [Int]()
        let expectation = XCTestExpectation(description: "combineLatest with delay")

        let a = Observable<Int>.create { (observer) -> Disposable in
            for item in items1 {
                NSLog("nextItem 1 !!!")
                observer.onNext(item)
                Thread.sleep(forTimeInterval: 0.2)
            }
            observer.onCompleted()
            return Disposables.create()
        }

        let b = Observable<Int>.create { (observer) -> Disposable in
            for item in items2 {
                NSLog("nextItem 2 !!!")
                observer.onNext(item)
                Thread.sleep(forTimeInterval: 0.2)
            }
            observer.onCompleted()
            return Disposables.create()
        }

        Observable<(Int, Int)>.combineLatest(
            a.debug("combinelatest with delay 1"),
            b.delay(.milliseconds(100)).debug("combinelatest with delay 2")
        )
            .debug("combinelatest with delay")
            .map { arg -> Int in
                let (x, y) = arg
                return x + y
            }
            .subscribe(onNext: { (value) in
                result.append(value)
            }, onCompleted: {
                XCTAssertEqual(result, [14, 24, 34, 44])
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testZip() throws {
        let items1 = [1, 2, 3, 4, 5]
        let items2 = [10, 20, 30]
        var result = [Int]()
        let expectation = XCTestExpectation(description: "zip")

        let a = Observable.from(items1)
        let b = Observable.from(items2)

        Observable<(Int, Int)>.zip(
            a,
            b //.delay(.milliseconds(100))
        )
            .map { arg -> Int in
                let (x, y) = arg
                return x * y
            }
            .subscribe(onNext: { (value) in
                result.append(value)
            }, onCompleted: {
                XCTAssertEqual(result, [10, 40, 90])
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }
}
