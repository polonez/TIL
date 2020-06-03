//
//  DisposeBag.swift
//  reactive
//
//  Created by Fred on 2020/06/03.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

final class DisposeBag {
    internal private(set) var disposables = [Disposable]()

    private var isDisposed: Bool = false
    private var lock = NSRecursiveLock()

    func insert(_ disposable: Disposable) {
        if self.isDisposed {
            disposable.dispose()
        }
        self.disposables.append(disposable)
    }

    private func dispose() {
        self.lock.lock(); defer { self.lock.unlock() }
        let disposables = self.disposables
        self.disposables.removeAll()
        for disposable in disposables {
            disposable.dispose()
        }
    }

    deinit {
        dispose()
    }
}
