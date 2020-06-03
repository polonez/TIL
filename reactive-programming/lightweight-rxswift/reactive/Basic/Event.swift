//
//  Event.swift
//  reactive
//
//  Created by Fred on 2020/06/02.
//  Copyright © 2020 etude. All rights reserved.
//

enum Event<Element> {
    case next(Element)
    case error(Swift.Error)
    case completed
}
