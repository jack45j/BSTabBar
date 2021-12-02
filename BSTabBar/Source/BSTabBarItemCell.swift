//
//  BSTabBarItemCell.swift
//  BSTabPageController
//
//  Created by 林翌埕-20001107 on 2021/2/24.
//

import UIKit

class BSTabBarItemCell: UICollectionViewCell {
    
    lazy var stackView = setupStackView([iconImageView, titleLabel])
    var expectedWidth: CGFloat = 0.0
    var maxWidth: CGFloat = .infinity
	var spacing: CGFloat = 16.0
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    lazy var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
		imgView.translatesAutoresizingMaskIntoConstraints = false
		imgView.widthAnchor.constraint(lessThanOrEqualToConstant: 32).isActive = true
		imgView.heightAnchor.constraint(equalTo: imgView.widthAnchor).isActive = true
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing / 2).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing / 2).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing / 2).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing / 2).isActive = true
        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView(_ views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    func manualSetSelected(_ config: BSTabBarConfiguration, image: UIImage?) {
        titleLabel.textColor = config.tabBarHighlightedTextColor
        guard let image = image else { return }
        iconImageView.image = image
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if #available(iOS 13.0, *) { } else {
            let targetSize = CGSize(width: expectedWidth, height: layoutAttributes.frame.height)
            layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return layoutAttributes
        }
        
        titleLabel.sizeToFit()
		iconImageView.layoutIfNeeded()
        guard titleLabel.frame.width != 0 else { fatalError() }
		
		let iconImageWidth = iconImageView.image != nil ? iconImageView.frame.width + iconImageView.frame.maxX : 0
		let prefferedWidth = maxWidth != .infinity ?
			min(maxWidth, titleLabel.frame.width + spacing + iconImageWidth) :
			titleLabel.frame.width + spacing + iconImageWidth
        let targetSize = CGSize(width: max(expectedWidth, prefferedWidth), height: layoutAttributes.frame.height)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
