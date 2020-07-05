//
//  TableHeaderViewWithTitle.swift
//  UIComponents
//
//  Created by Илья Харабет on 04.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class TableHeaderViewWithTitle: UITableViewHeaderFooterView {
    
    let titleLabel: UILabel = UILabel(frame: .zero)
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupBackgroundView()
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackgroundView()
        setupTitleLabel()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.frame = bounds
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        backgroundView?.backgroundColor = AppTheme.current.colors.middlegroundColor
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
    }
    
    private func setupBackgroundView() {
        backgroundView = UIView(frame: .zero)
        backgroundView?.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.font = AppTheme.current.fonts.medium(14)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.clipsToBounds = true
        titleLabel.layer.cornerRadius = 6
        [titleLabel.leading(15), titleLabel.trailing(15), titleLabel.top(4)].toSuperview()
        titleLabel.centerY().toSuperview()
    }
    
}
