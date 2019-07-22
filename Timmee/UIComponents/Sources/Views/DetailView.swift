//
//  DetailView.swift
//  UIComponents
//
//  Created by i.kharabet on 16/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class DetailView: UIView {
    
    public let titleLabel = UILabel()
    private let detailContainerView = UIView()
    
    public init(title: String, detailView: UIView) {
        super.init(frame: .zero)
        
        setupTitleLabel()
        setupDetailContainerView()
        
        titleLabel.text = title
        
        setupDetailView(detailView)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        
        titleLabel.textAlignment = .left
        
        [titleLabel.top(), titleLabel.leading(), titleLabel.trailing()].toSuperview()
    }
    
    private func setupDetailContainerView() {
        addSubview(detailContainerView)
        
        detailContainerView.backgroundColor = .clear
        detailContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        [detailContainerView.leading(), detailContainerView.trailing(), detailContainerView.bottom()].toSuperview()
        detailContainerView.topToBottom(4).to(titleLabel, addTo: self)
    }
    
    private func setupDetailView(_ detailView: UIView) {
        detailContainerView.addSubview(detailView)
        
        detailView.allEdges().toSuperview()
    }
    
}
