//
//  CompressibleViewContainerController.swift
//  MobileBank
//
//  Created by g.novik on 18.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

/// Контроллер контейнера вертикально-сжимаемых объектов отображения
public final class CompressibleViewContainerController: UIViewController, VerticalCompressibleViewContainer {
    
    /// Outlet
    public lazy var compressibleViewContainer = CompressibleViewContainer.loadedFromNib()
    
    /// Private
    private var compressibleViews = [UIView & VerticalCompressibleView]()
    
    // MARK: - Lifecycle
    
    public override func loadView() {
        view = compressibleViewContainer
    }
    
    public init() {
        super.init(nibName: nil, bundle: Bundle(for: CompressibleViewContainerController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        compressibleViews.forEach {
            compressibleViewContainer.add(compressibleView: $0)
        }
    }

    // MARK: - VerticalCompressibleViewContainer
    
    public func add(compressibleView: UIView & VerticalCompressibleView) {
        compressibleViews.append(compressibleView)
    }
    
    public var minimizedStateHeight: CGFloat {
        return compressibleViewContainer.minimizedStateHeight
    }
    
    public var maximizedStateHeight: CGFloat {
        return compressibleViewContainer.maximizedStateHeight
    }
    
    public func changeCompression(to state: CGFloat) {
        compressibleViewContainer.changeCompression(to: state)
    }
    
    public func updateHeights() {
        compressibleViewContainer.updateHeights()
    }
}
