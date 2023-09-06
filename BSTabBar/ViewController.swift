//
//  ViewController.swift
//  BSTabBAr
//
//  Created by Yi-Cheng Lin on 2021/12/3.
//

import UIKit

class ViewController: UIViewController {
	lazy var img = UIImageView(image: UIImage(named: "apple-black-logo"))
	lazy var items: [BSTabBarItem] = [
		.init(tabTitle: "Item1"),
		.init(tabTitle: "Item2WithLongTitle"),
		.init(tabIcon: self.img, tabTitle: "Item3"),
		.init(tabIcon: self.img, tabTitle: "4"),
        .init(tabIcon: self.img, tabTitle: "Item5"),
        .init(tabIcon: self.img, tabTitle: "Item6"),
        .init(tabIcon: self.img, tabTitle: "Item7"),
        .init(tabIcon: self.img, tabTitle: "Item8"),
        .init(tabIcon: self.img, tabTitle: "Item9"),
	]

	@IBOutlet weak var tabBar: BSTabBar!
	override func viewDidLoad() {
		super.viewDidLoad()
		tabBar.builder
			.setTabItems(items)
			.scrollable(isScrollable: true, isPaging: true)
			.setConfig(
                .init(
                    tabBarBackgroundColor: .white,
                    tabBarArrangedDirection: .horizontal,
                    defaultSelectPage: 7))
            .build()
	}
}

