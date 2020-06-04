//
//  Disposables.swift
//  reactive
//
//  Created by Fred on 2020/06/03.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

struct Disposables {
}

// MARK: - Other Disposables
extension Disposables {
    static func create() -> Disposable {
        return NopDisposable.nop
    }
}

// MARK: - AnyDisposable
extension Disposables {
    static func create(with dispose: @escaping () -> Void) -> Disposable {
        AnyDisposable(dispose)
    }
}

private final class AnyDisposable: Disposable {
    private(set) var isDisposed: Bool = false

    private var disposeAction: (() -> Void)?

    init(_ disposeAction: @escaping () -> Void) {
        self.disposeAction = disposeAction
    }

    func dispose() {
        self.disposeAction?()
        self.disposeAction = nil
        self.isDisposed = true
    }
}

// MARK: - NopDisposable
private final class NopDisposable: Disposable {
    /// Shared static no op.
    static let nop = NopDisposable()

    private(set) var isDisposed: Bool = false

    private init() {}

    func dispose() {
        // nop
        self.isDisposed = true
    }
}

//// MARK: - BinaryDisposable
//extension Disposables {
//    static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Disposable {
//        return BinaryDisposable(disposable1, disposable2)
//    }
//}
//
//private final class BinaryDisposable: Disposable {
//    private var disposable1: Disposable?
//    private var disposable2: Disposable?
//
//    private(set) var isDisposed: Bool = false
//
//    init(_ disposable1: Disposable, _ disposable2: Disposable) {
//        self.disposable1 = disposable1
//        self.disposable2 = disposable2
//    }
//
//    func dispose() {
//        self.disposable1?.dispose()
//        self.disposable2?.dispose()
//        self.disposable1 = nil
//        self.disposable2 = nil
//
//        self.isDisposed = true
//    }
//}

// MARK: - CompositeDisposable
extension Disposables {
    static func create(_ disposables: Disposable ...) -> Disposable {
        return CompositeDisposable(disposables)
    }
}

private final class CompositeDisposable: Disposable {
    private var disposables: [Disposable]

    private var lock = NSRecursiveLock()

    private(set) var isDisposed: Bool = false

    init(_ disposables: [Disposable]) {
        self.disposables = disposables
    }

    func dispose() {
        _dispose().forEach { $0.dispose() }
        
        self.isDisposed = true
    }

    private func _dispose() -> [Disposable] {
        self.lock.lock(); defer { self.lock.unlock() }
        let disposables = self.disposables
        self.disposables = []
        return disposables
    }
}
