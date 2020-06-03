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
    func testObservable() throws {
        let disposeBag = DisposeBag()
        var result = [Int]()
        Observable<Int>.create { (observer) -> Disposable in
                observer.onNext(1)
                observer.onNext(2)
                Thread.sleep(forTimeInterval: 1.5)
                observer.onNext(3)
                return Disposables.create()
            }
            .map { $0 * $0 }
            .subscribe(onNext: { (value) in
                result.append(value)
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, [1, 4, 9])
    }

    func testDisposed() throws {
        var disposeBag = DisposeBag()
        var result = [Int]()
        let values = [3, 2, 1]
        let disposable = Observable.from(values)
            .map { $0 * $0 }
            .subscribe(onNext: { (value) in
                result.append(value)
            })

        disposable.disposed(by: disposeBag)

        XCTAssertEqual(disposable.isDisposed, true)
        disposeBag = DisposeBag()

        XCTAssertEqual(result, values.map { $0 * $0 })
        XCTAssertEqual(disposable.isDisposed, true)
    }
}

class reactiveOperatorsTests: XCTestCase {
    func testJust() throws {
        let disposeBag = DisposeBag()
        var result = [Int]()
        Observable.just([1, 3, 5])
            .subscribe(onNext: { (value) in
                result.append(contentsOf: value)
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, [1, 3, 5])
    }

    func testFrom() throws {
        let disposeBag = DisposeBag()
        var result = [Int]()
        Observable.from([2, 4, 6])
            .map { $0 * $0 }
            .subscribe(onNext: { (value) in
                result.append(value)
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(result, [2, 4, 6].map { $0 * $0 })
    }
}
