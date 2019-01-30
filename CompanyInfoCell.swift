//
//  CompanyInfoCell.swift
//  Market
//
//  Created by Igor Trukhin on 20/12/2018.
//  Copyright © 2018 Igor Trukhin. All rights reserved.
//

import IGListKit
import UIKit
import SnapKit

final class CompanyInfoCell: UICollectionViewCell {
    
    private static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    
    private static let keyLabelfont = UIFont.systemFont(ofSize: 14)
    private static let valueLabelfont = UIFont.systemFont(ofSize: 17)
    
    static func textHeight(_ text: String, width: CGFloat) -> CGFloat {
        let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: valueLabelfont]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height) + insets.top + insets.bottom
    }
    
    private let container = UIView()
    
    private let label: UILabel = {
        let view = UILabel()
        view.font = keyLabelfont
        view.textColor = UIColor.lightGray
        view.numberOfLines = 1
        return view
    }()
    
    private let value: UILabel = {
        let view = UILabel()
        view.font = valueLabelfont
        view.numberOfLines = 0
        return view
    }()
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 200 / 255.0, green: 199 / 255.0, blue: 204 / 255.0, alpha: 1).cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(container)
        container.addSubview(label)
        container.addSubview(value)
        contentView.layer.addSublayer(separator)
        contentView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutUI()
    }
    
    private func layoutUI() {
        let bounds = contentView.bounds
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(CompanyInfoCell.insets)
        }
        
        label.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(16)
        }
        
        value.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(5)
            make.left.bottom.right.equalToSuperview()
        }
        
        let height: CGFloat = 0.5
        let left = CompanyInfoCell.insets.left
        separator.frame = CGRect(x: left, y: bounds.height - height, width: bounds.width - left - left, height: height)
    }
    
}

extension CompanyInfoCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? PresentableRow else { return }
        label.text = viewModel.key
        value.text = viewModel.value
    }
    
}
