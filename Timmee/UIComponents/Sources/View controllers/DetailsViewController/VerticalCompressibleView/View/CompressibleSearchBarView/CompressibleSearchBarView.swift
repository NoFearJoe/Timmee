//
//  CompressibleSearchBarView.swift
//  UIComponents
//
//  Created by i.kharabet on 29/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class CompressibleSearchBarView: UIView, VerticalCompressibleView, ConfigurableView {
    
    public var onTextChange: ((String) -> Void)?
    
    public let searchBar = UISearchBar(frame: .zero)
    
    public var maximizedStateHeight: CGFloat = 56
    public var minimizedStateHeight: CGFloat = 56
    
    public init() {
        super.init(frame: .zero)
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    public func changeCompression(to state: CGFloat) {
        
    }
    
    public func configure(with model: Model) {
        searchBar.placeholder = model.placeholder
    }
    
    private func setupSubviews() {
        addSubview(searchBar)
        
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.returnKeyType = .search
        searchBar.backgroundColor = .clear
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        [searchBar.leading(8), searchBar.trailing(8), searchBar.top(), searchBar.bottom()].toSuperview()
        searchBar.height(56)
    }
    
}

extension CompressibleSearchBarView: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        onTextChange?(searchText)
    }
    
}

extension CompressibleSearchBarView {
    
    public struct Model {
        let placeholder: String
        
        public init(placeholder: String) {
            self.placeholder = placeholder
        }
    }
    
}
