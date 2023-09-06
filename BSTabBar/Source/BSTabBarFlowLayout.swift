//
//  BSTabBarFlowLayout.swift
//  BooksReader
//
//  Created by 林翌埕-20001107 on 2021/10/27.
//  Copyright © 2021 www.books.com.tw. All rights reserved.
//

import UIKit

final class BSTabBarFlowLayout: UICollectionViewFlowLayout {
    
    var cachedWidth: CGFloat?
    var contentBounds = CGRect.zero
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    var itemsInPage: Double?
    var isScrollEnable: Bool
    var isPagingEnable: Bool
    weak var tabBar: BSTabBar?
    
    var expectWidth: CGFloat = .infinity
    let maxWidth: CGFloat
    
    init(isScrollEnable: Bool, isPagingEnable: Bool, itemsInPage: Double? = nil, maxWidth: CGFloat = .infinity, tabBar: BSTabBar) {
        self.maxWidth = maxWidth
        self.isScrollEnable = isScrollEnable
        self.isPagingEnable = isPagingEnable
        self.itemsInPage = itemsInPage
        self.tabBar = tabBar
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        guard let cv = collectionView,
              cv.frame != .zero,
              tabBar?.items.count != 0 else { return }
        cv.isPagingEnabled = isPagingEnable
        cv.isScrollEnabled = isScrollEnable
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        scrollDirection = .horizontal
        
        let lineSpacing = 0
        let interSpacing = 0
        minimumLineSpacing = CGFloat(lineSpacing)
        minimumInteritemSpacing = CGFloat(interSpacing)
        
//        cachedAttributes.removeAll()
        contentBounds = .zero
        
        let cachedWidths: [CGFloat] = .init(repeating: calItemSize().width, count: cv.numberOfItems(inSection: 0))
        contentBounds = .init(x: 0, y: 0, width: cachedWidths.reduce(0, +), height: cv.frame.height)
        for idx in 0..<cv.numberOfItems(inSection: 0) {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: idx, section: 0))
            attributes.frame = .init(x: idx == 0 ? 0 : cachedWidths[0..<idx].reduce(0, +),
                                     y: 0,
                                     width: calItemSize().width,
                                     height: cv.frame.height)
            cachedAttributes.append(attributes)
        }

        tabBar?.updateHorizontalBar()
        return
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView,
              cv.frame != .zero
        else { return false }
        let result = !newBounds.size.equalTo(cv.bounds.size)
        if result {
            cachedAttributes.removeAll()
            cv.reloadData()
            tabBar?.tabBarItemCollectionView.selectItem(at: IndexPath(item: tabBar?.currentTab ?? 0, section: 0), animated: false, scrollPosition: [])
        }
        return result
    }
    
    /// - Tag: CollectionViewContentSize
    override var collectionViewContentSize: CGSize {
        return .init(width: contentBounds.width, height: contentBounds.height)
    }
    
    /// - Tag: LayoutAttributesForItem
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    /// - Tag: LayoutAttributesForElements
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attributesArray = [UICollectionViewLayoutAttributes]()
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxX >= rect.minX else { break }
            attributesArray.append(attributes)
        }

        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minX <= rect.maxX else { break }
            attributesArray.append(attributes)
        }

        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    private func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start {
            return nil
        }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxX < rect.minX {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
    
    func calItemSize() -> CGSize {
        guard let cv = collectionView,
              let itemCount = tabBar?.items.count,
              cv.frame.width != 0 || tabBar?.frame.width != 0,
              let tabBar = tabBar
        else { return .zero }
        
        var referenceSize: CGSize
        if #available(iOS 13.0, *) {
            referenceSize = cv.frame.size
        } else {
            referenceSize = tabBar.frame.size
        }
        
        expectWidth = referenceSize.width / CGFloat(isScrollEnable ? itemsInPage ?? Double(itemCount) : Double(itemCount))
        
        if isScrollEnable {
            // if current frame width is greater than total items width
            if expectWidth * CGFloat(itemCount) < referenceSize.width {
                return .init(width: (referenceSize.width / CGFloat(itemCount)).rounded(.up), height: referenceSize.height)
            } else {
                return .init(width: (referenceSize.width / CGFloat(itemsInPage ?? Double(itemCount))).rounded(.up), height: referenceSize.height)
            }
        } else {
            return .init(width: (referenceSize.width / CGFloat(itemCount)).rounded(.up), height: referenceSize.height)
        }
    }
    
    func getItemWidth(index: Int) -> CGFloat {
        guard index < cachedAttributes.count else { return 0.0 }
        return cachedAttributes[index].frame.size.width
    }
}

// Dynamic Width.
extension BSTabBarFlowLayout {
    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)

        let index = originalAttributes.indexPath.item
        context.invalidateItems(at: [IndexPath(item: index, section: 0)])

        return context
    }
    
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        
        let index = originalAttributes.indexPath.item
        let preferredWidth = preferredAttributes.size.width.rounded(.up)
        
        // iOS 13 以下不做額外處理
        if #available(iOS 13.0, *) { } else {
            return true
        }
        
        if maxWidth != .infinity && cachedAttributes[index].frame.width > maxWidth {
            cachedAttributes[index].frame.size.width = maxWidth
            return true
        }
        
        guard cachedAttributes.reduce(0, { $0 + $1.frame.width }) >= collectionView?.frame.width ?? 0 else {
            for idx in 0..<cachedAttributes.count {
                cachedAttributes[idx].frame.size.width = max(cachedAttributes[idx].frame.size.width.rounded(.up), calItemSize().width)
            }
            return true
        }
        
        guard preferredWidth != cachedAttributes[index].frame.width else {
            return false
        }
        
        guard preferredWidth > calItemSize().width else {
            self.cachedAttributes[index].frame.size.width = calItemSize().width
            return true
        }
        if preferredWidth != cachedAttributes[index].frame.size.width.rounded(.up) {
            if #available(iOS 13.0, *) {
                self.cachedAttributes[index] = preferredAttributes
                return true
            }
        }
        return false
    }
}
