//
//  BSBuilder.swift
//  BooksReader
//
//  Created by Benson Lin on 2021/3/2.
//  Copyright © 2021 www.ycstudio.com.tw. All rights reserved.
//

import Foundation

public protocol BuilderCompatible {}
extension BSTabBar: BuilderCompatible {}

extension BuilderCompatible {
    var builder: BSBuilder<Self> {
        get { BSBuilder(self) }
    }
}

public struct BSBuilder<T: BuilderCompatible> {
    private let _build: () -> T

    @discardableResult
    public func build() -> T { _build() }
    init(_ build: @escaping () -> T) { self._build = build }
    init(_ base: T) { self._build = { base } }
}

extension BSBuilder where T: BSTabBar {
    @discardableResult
    func build() -> T {
        _build().tabBarItemCollectionView.collectionViewLayout.invalidateLayout()
        return _build()
    }
}
