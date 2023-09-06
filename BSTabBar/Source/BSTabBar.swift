//
//  BSTabBar.swift
//  BSTabPageController
//
//  Created by 林翌埕-20001107 on 2021/2/24.
//

import UIKit

protocol BSTabBarDelegate: AnyObject {
    func didSelectTab(from: Int, to: Int)
}

struct BSTabBarItem {
    // Tab item Icon
    var tabIcon: UIImageView? = nil

    // Tab title String.
    var tabTitle: String
}

class BSTabBar: UIView, UICollectionViewDelegateFlowLayout {
    
    /// Tab bar items
    var items: [BSTabBarItem] = []
    
    /// Configurations of BSTabBar
    var config: BSTabBarConfiguration = .init()
    
    /// Current selected tab's index.
    lazy var currentTab: Int! = -1
    
    /// A Bool value to determine weather tab can be select or not.
    var isTabMenuClickable: Bool = true {
        didSet { tabBarItemCollectionView.allowsSelection = isTabMenuClickable }
    }
    
    /// A Bool value to determine weather tab bar can be scroll or not.
    var scrollStyle: Bool = false
    
    private var _itemsInPage: Double = 0
    var itemsInPage: Double? {
        get {
            return scrollStyle ? _itemsInPage : nil
        }
        set {
            guard scrollStyle, let value = newValue else { return }
            _itemsInPage = value
        }
    }
    
    weak var delegate: BSTabBarDelegate?
        
    /// Bottom line's background view
    private let horizontalBarBackgroundView = UIView()
    
    /// Highlighted bottom line. Expect to point out the current selected tab.
    let horizontalBarView = UIView()
    
    lazy var tabBarItemCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: BSTabBarFlowLayout(isScrollEnable: false, isPagingEnable: true, tabBar: self))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColor = config.tabBarBackgroundColor
        return collectionView
    }()
    
    /// Dynamic constraints relates to configuration.
    lazy var horizontalBarLeftAnchorConstraint: NSLayoutConstraint = .init()
    lazy var horizontalBarWidthAnchorConstraint: NSLayoutConstraint = .init()
    lazy var horizontalBarLineHeightAnchorConstraint: NSLayoutConstraint = .init()
    lazy var horizontalBarBackgroundLineHeightAnchorConstraint: NSLayoutConstraint = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateHorizontalBar()
        guard let cell = tabBarItemCollectionView.cellForItem(at: IndexPath(item: currentTab, section: 0)) as? BSTabBarItemCell else { return }
        cell.manualSetSelected(config, image: items[currentTab].tabIcon?.highlightedImage)
    }
    
    private func commonInit() {
        tabBarItemCollectionView.register(BSTabBarItemCell.self, forCellWithReuseIdentifier: String(describing: BSTabBarItemCell.self))
        addSubview(tabBarItemCollectionView)
        tabBarItemCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tabBarItemCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        tabBarItemCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        tabBarItemCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        tabBarItemCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        initHorizontalBar()
    }
    
    private func initHorizontalBar() {
        clipsToBounds = true
        
        // Bar background view
        addSubview(horizontalBarBackgroundView)
        horizontalBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        horizontalBarBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalBarBackgroundView.widthAnchor.constraint(equalTo: tabBarItemCollectionView.widthAnchor, multiplier: 1).isActive = true
        horizontalBarBackgroundView.backgroundColor = config.tabBarLineBackgroundColor
        
        horizontalBarBackgroundLineHeightAnchorConstraint = horizontalBarBackgroundView.heightAnchor.constraint(equalToConstant: config.tabBarLineBackgroundHeight)
        horizontalBarBackgroundLineHeightAnchorConstraint.isActive = true
        
        // Bar View
        addSubview(horizontalBarView)
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        horizontalBarView.layer.masksToBounds = false
        horizontalBarView.layer.shadowOffset = CGSize(width: 0, height: -1)
        horizontalBarView.layer.shadowOpacity = 0.35
        horizontalBarView.layer.shadowColor = config.tabBarLineColor.cgColor
        horizontalBarView.backgroundColor = config.tabBarLineColor
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftAnchorConstraint.isActive = true
        
        horizontalBarWidthAnchorConstraint = horizontalBarView.widthAnchor.constraint(equalToConstant: 0)
        horizontalBarWidthAnchorConstraint.isActive = true
        
        horizontalBarLineHeightAnchorConstraint = horizontalBarView.heightAnchor.constraint(equalToConstant: config.tabBarLineHeight)
        horizontalBarLineHeightAnchorConstraint.isActive = true
        
        selectTab(item: config.defaultSelectPage, animated: false)
    }
    
    // MARK: Update HorizontalBar
    func updateHorizontalBar() {
        if let layout = tabBarItemCollectionView.collectionViewLayout as? BSTabBarFlowLayout {
            horizontalBarWidthAnchorConstraint.constant = layout.getItemWidth(index: currentTab)
        }
        updateHorizontalBarLeftAnchor()
    }
    
    private func updateHorizontalBarLeftAnchor() {
        if let layout = tabBarItemCollectionView.collectionViewLayout as? BSTabBarFlowLayout {
            horizontalBarLeftAnchorConstraint.constant = (currentTab == 0 ? 0 : Array(0...currentTab - 1).reduce(0, { $0 + layout.getItemWidth(index: $1) })) - tabBarItemCollectionView.contentOffset.x
        }
    }
}

//**********************************
// MARK: Interface API
//**********************************
extension BSTabBar {
    func selectTab(item: Int, animated: Bool = true) {
        isTabMenuClickable = false
        delegate?.didSelectTab(from: currentTab, to: item)
        currentTab = item
        guard !self.isHidden else { return }
        UIView.animate(withDuration: animated ? 0.3 : 0.0,
                       delay: 0,
                       options: [.curveEaseIn]) { [weak self] in
            guard let self = self else { return }
            self.updateHorizontalBar()
            self.updateHorizontalBarLeftAnchor()
            self.layoutIfNeeded()
        } completion: { [weak self] (completed) in
            self?.tabBarItemCollectionView.selectItem(at: IndexPath(item: item, section: 0), animated: animated, scrollPosition: [])
            self?.isTabMenuClickable = true
            
            if #available(iOS 13.0, *) { } else {
                self?.tabBarItemCollectionView.reloadData()
            }
        }
    }
}

//**********************************
// MARK: UICollectionViewDelegate
//**********************************
extension BSTabBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectTab(item: indexPath.item)
        let contentOffset = tabBarItemCollectionView.contentOffset
        tabBarItemCollectionView.reloadData()
        tabBarItemCollectionView.layoutIfNeeded()
        tabBarItemCollectionView.contentOffset = contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollStyle else { return }
        updateHorizontalBarLeftAnchor()
    }
}

//**********************************
// MARK: UICollectionViewDataSource
//**********************************
extension BSTabBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BSTabBarItemCell.self), for: indexPath) as? BSTabBarItemCell else { fatalError() }
        if let layout = collectionView.collectionViewLayout as? BSTabBarFlowLayout {
            cell.expectedWidth = layout.calItemSize().width
            cell.maxWidth = layout.maxWidth
        }
        cell.isSelected = indexPath == IndexPath(row: currentTab, section: 0)
        cell.titleLabel.text = items[indexPath.item].tabTitle
        cell.titleLabel.font = config.tabBarFont
        cell.titleLabel.textColor = cell.isSelected ? config.tabBarHighlightedTextColor : config.tabBarTextColor
        cell.iconImageView.image = items[indexPath.item].tabIcon?.image ?? .none
        cell.iconImageView.image = items[indexPath.item].tabIcon?.highlightedImage ?? .none
        cell.stackView.axis = config.tabBarArrangedDirection
        cell.backgroundColor = cell.isHighlighted ? config.tabBarHighlightedBackgroundColor ?? config.tabBarBackgroundColor : config.tabBarBackgroundColor
        
        return cell
    }
}

//**********************************
// MARK: Builder method for BSTabBar
//**********************************
extension BSBuilder where T: BSTabBar {
    func setTabItems(_ items: [BSTabBarItem]) -> BSBuilder<T> {
        return BSBuilder {
            let obj = self.build()
            obj.items = items
            return obj
        }
    }
    
    func setConfig(_ config: BSTabBarConfiguration) -> BSBuilder<T> {
        return BSBuilder {
            let obj = self.build()
            obj.config = config
            return obj
        }
    }
    
    func scrollable(isScrollable: Bool, isPaging: Bool, itemsInPage: Double = 3.0, maxWidth: CGFloat = .infinity) -> BSBuilder<T> {
        return BSBuilder {
            weak var obj = self.build()
            guard let obj = obj else { return self.build() }
            obj.scrollStyle = isScrollable
            obj.itemsInPage = itemsInPage
            obj.tabBarItemCollectionView.setCollectionViewLayout(BSTabBarFlowLayout(isScrollEnable: isScrollable, isPagingEnable: isPaging, itemsInPage: itemsInPage, maxWidth: maxWidth, tabBar: obj), animated: false)
            return obj
        }
    }
}
