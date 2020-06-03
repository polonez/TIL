//
//  Dispose.swift
//  reactive
//
//  Created by Fred on 2020/06/02.
//  Copyright © 2020 etude. All rights reserved.
//

import Foundation

protocol Disposable {
    var isDisposed: Bool { get }
    func dispose()
}

extension Disposable {
    func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}
