//
//  BSTabBarConfiguration.swift
//  BSTabPageController
//
//  Created by 林翌埕-20001107 on 2021/2/25.
//

import UIKit

struct BSTabBarConfiguration {
    var tabBarHeight: CGFloat = 60
    var tabBarFont: UIFont? = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
    var tabBarTextColor: UIColor = .lightGray
    var tabBarHighlightedTextColor: UIColor = .black
    var tabBarLineHeight: CGFloat = 2
    var tabBarLineBackgroundHeight: CGFloat = 1
    var tabBarLineBackgroundColor: UIColor = .lightGray
	var tabBarLineColor: UIColor = .systemGreen
    var tabBarBackgroundColor: UIColor = .clear
    var tabBarHighlightedBackgroundColor: UIColor?
    var tabBarArrangedDirection: NSLayoutConstraint.Axis = .horizontal
    var defaultSelectPage: Int = 0
}
