//
//  DetailsBaseViewController.swift
//  MobileBank
//
//  Created by a.y.zverev on 15.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit
import Workset

private enum Constants {
    
    static var statusBarHeight: CGFloat {
        return UIDevice.current.isPhone && UIScreen.main.bounds.height >= 812 ? 44.0 : 20.0
    }
    
    /// Отступ при прилипании к верху
    static let detailsTopAdditionalOffset: CGFloat = 4.0
    static let detailsTopOffset: CGFloat = statusBarHeight + detailsTopAdditionalOffset
    
    /// На сколько нужно дополнительно проскролить, чтобы закрыть экран
    static let detailShouldCloseAdditionalOffset: CGFloat = 50.0
    
    /// При каком изменении состояния скролла производить автоматическую доводку
    static let userInteractionApplyingMultiplier: CGFloat = 0.5
    
    /// Дополнительные
    /// Чтобы скролл не вылезал за хедер нужно его начало оставить ниже конца хедера на размер "ушек"
    static let headerViewEarsHeight: CGFloat = 24.0
    static let scrollViewToHeaderTopOffset: CGFloat = headerViewEarsHeight + detailsTopOffset
    
    static var detailsStartHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.85
    }
}

public class DetailsBaseViewController: UIViewController {
    
    // State
    var content: DetailModuleProvider
    var hasContent: Bool = false
    var headerViewLastDynamicState: CGFloat = 1.0
    
    fileprivate let animator = PresentingAnimator(style: .transparent)
    fileprivate lazy var tapToCloseHelpView = UIView()
    
    // Привязка хедера, чтобы можно было его двигать вместе с контентом
    fileprivate var headerViewControllerBottomConstraint: NSLayoutConstraint?
    
    /// Замена self.view
    private lazy var detailsBaseView = DetailsBaseView()
    
    /// Белый фон для плейсхолдера
    private lazy var placeholderBackgroundView = UIView()
    
    // Нижняя белая плашка
    private lazy var bottomBackgroundView = UIView()
    private var bottomBackgroundViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var tapOutsideRecognizer: UITapGestureRecognizer? = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
    
    /// Dynamic UI
    fileprivate var scrollViewStartInset: CGFloat {
        let maxHeaderHeight = self.content.header.maximizedStateHeight

        if UIDevice.current.isIpad {
            return maxHeaderHeight
        } else {
            return view.frame.size.height
                - Constants.scrollViewToHeaderTopOffset
                - Constants.detailsStartHeight
                + maxHeaderHeight
        }
    }
    
    // MARK: - Initialization
    
    public init(content: DetailModuleProvider) {
        self.content = content
        
        super.init(nibName: nil, bundle: nil)
        
        tapOutsideRecognizer?.cancelsTouchesInView = false
        tapOutsideRecognizer?.delegate = self
    }
    
    @available(*, unavailable, message: "init(coder:) not implemented")
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Lifecycle
    
    override public func loadView() {
        view = detailsBaseView
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasContent {
            performDataAppearing()
        }
        
        if let headerViewContoller = content.header as? CompressibleViewContainerController {
            headerViewContoller.updateHeights()
            headerViewContoller.changeCompression(to: headerViewLastDynamicState)
        }
        
        content.stackViewContainer.contentInset.top = scrollViewStartInset
        setupBottomInsetIfNeeded()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIDevice.current.isIpad, let tapOutsideRecognizer = tapOutsideRecognizer {
            view.window?.addGestureRecognizer(tapOutsideRecognizer)
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // layout анимированного плейсхолдера (закругление углов)
        if placeholderBackgroundView.superview != nil {
            placeholderBackgroundView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        }
        
        guard hasContent == true else { return }
        guard content.header.view.superview != nil else { return }
        
        content.stackViewContainer.contentInset.top = scrollViewStartInset
        
        bottomBackgroundViewHeightConstraint?.constant = view.frame.size.height
            - content.header.view.frame.origin.y
            - Constants.detailsTopOffset
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        content.fullPlaceholder.clearAnimations()
        content.contentPlaceholder.clearAnimations()
        if let tapOutsideRecognizer = tapOutsideRecognizer {
            view.window?.removeGestureRecognizer(tapOutsideRecognizer)
            self.tapOutsideRecognizer = nil
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Data loading
    
    private func performDataAppearing() {
        if content.cachedFullDataAvailable {
            performDetailsAppearingWithoutPlaceholder()
        } else if content.cachedHeaderDataAvailable {
            performDetailsAppearingWithContentPlaceholder()
        } else {
            performDetailsAppearingWithFullPlaceholder()
        }
    }
    
    private func performDetailsAppearingWithoutPlaceholder() {
        content.reloadContent()
        placeContent(header: content.header,
                     stackViewContainer: content.stackViewContainer)
    }
    
    private func performDetailsAppearingWithContentPlaceholder() {
        placeContent(header: content.header,
                     stackViewContainer: content.stackViewContainer)
        
        content.stackViewContainer.addView(content.contentPlaceholder)
        content.contentPlaceholder.startAnimating()
        
        content.loadContent { [weak self] (error) in
            DispatchQueue.main.async {
                self?.content.contentPlaceholder.stopAnimating()
                
                if let error = error {
                    self?.content.contentPlaceholder.removeFromSuperview()
                    self?.createAndPlaceLabel(with: error)

                } else if let stackViewContainer = self?.content.stackViewContainer {
                    
                    UIView.animate(withDuration: .detailsElementDisappearingAnimationTime,
                                   animations: {
                                    stackViewContainer.alpha = 0.0
                    }, completion: { (_) in
                        self?.content.reloadContent()
                        self?.content.contentPlaceholder.isHidden = true
                        
                        UIView.animate(withDuration: .animation300ms,
                                       animations: {
                                        stackViewContainer.alpha = 1.0
                        })
                    })
                }
            }
        }
    }
    
    private func performDetailsAppearingWithFullPlaceholder() {
        placePlaceholderView()
        content.fullPlaceholder.startAnimating()
        content.loadContent(completion: { [weak self] (error) in
            DispatchQueue.main.async {
                self?.content.fullPlaceholder.stopAnimating()
                if let error = error {
                    self?.content.fullPlaceholder.removeFromSuperview()
                    self?.createAndPlaceLabel(with: error)
                } else if let header = self?.content.header, let stackViewContainer = self?.content.stackViewContainer {
                    self?.content.reloadContent()
                    self?.placeContent(header: header, stackViewContainer: stackViewContainer)
                    self?.animateContentAppearenceAfterPlaceholder()
                }
            }
        })
    }
    
    // MARK: - UI Configuration
    
    /// Добавляет и настраивает весь контент (включая header, stackcontainer и вспомогательные вьюшки)
    private func placeContent(header: UIViewController & VerticalCompressibleViewContainer,
                              stackViewContainer: UIScrollView) {
        placeStackViewContainer(stackViewContainer)
        placeHeader(header, on: stackViewContainer)
        placeBottomBackgroundView(with: content.viewConfiguration.bottomBackgroundColor)
        
        // Включаем скролл по хедеру и самому ScrollView одновременно
        detailsBaseView.headerView = content.header.view
        detailsBaseView.stackViewContainer = content.stackViewContainer
        
        pinTapToCloseView(to: content.header.view)
        
        hasContent = true
    }
    
    /// Добавляет header
    private func placeHeader(_ header: UIViewController & VerticalCompressibleViewContainer,
                             on stackViewContainer: UIScrollView) {
        addChild(header)
        view.addSubview(header.view)
        
        header.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        header.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerViewControllerBottomConstraint = header.view.bottomAnchor.constraint(equalTo: stackViewContainer.topAnchor,
                                                                                   constant: scrollViewStartInset)
        headerViewControllerBottomConstraint?.isActive = true
        
        header.view.translatesAutoresizingMaskIntoConstraints = false
        
        header.updateHeights()
    }
    
    /// Добавляет и настраивает stackViewContainer
    private func placeStackViewContainer(_ stackViewContainer: UIScrollView) {
        view.addSubview(stackViewContainer)
        
        let stackViewContainerTopOffset = UIDevice.current.isIpad ? 0.0 : Constants.scrollViewToHeaderTopOffset
        
        stackViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackViewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: stackViewContainerTopOffset).isActive = true
        
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        stackViewContainer.delaysContentTouches = false
        
        stackViewContainer.showsVerticalScrollIndicator = false
        stackViewContainer.backgroundColor = .clear
        stackViewContainer.delegate = self
    }
    
    /// Добавяет белую вьюшку на фон (будет белый фон снизу при скролле вверх)
    private func placeBottomBackgroundView(with color: UIColor) {
        bottomBackgroundView.backgroundColor = color
        view.insertSubview(bottomBackgroundView, at: 0)
        
        bottomBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let height = view.frame.size.height
            - content.header.view.frame.origin.y
            - Constants.detailsTopOffset
        bottomBackgroundViewHeightConstraint = bottomBackgroundView.heightAnchor.constraint(equalToConstant: height)
        bottomBackgroundViewHeightConstraint?.isActive = true
        
        bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Добавляет в stackContainer под контен том отсуп снизу, если контента мало
    private func setupBottomInsetIfNeeded() {
        guard content.header.view != nil else {
            content.stackViewContainer.contentInset.bottom = 0.0
            return
        }
        
        let minimizedSizeHeight = content.header.minimizedStateHeight
        let fullsizeHeight = content.header.maximizedStateHeight
        
        let detailsTopOffset = UIDevice.current.isIpad ? 0.0 : Constants.detailsTopOffset
        let contentSizeHeightForMinimizedState = view.frame.size.height
            - detailsTopOffset
            - minimizedSizeHeight
        let contentSizeHeightForFullsizeState = view.frame.size.height
            - detailsTopOffset
            - fullsizeHeight
        
        guard
            contentSizeHeightForMinimizedState > content.stackViewContainer.contentSize.height,
            content.stackViewContainer.contentSize.height > contentSizeHeightForFullsizeState
            else {
                content.stackViewContainer.contentInset.bottom = 0.0
                return
        }
        
        content.stackViewContainer.contentInset.bottom
            = contentSizeHeightForMinimizedState - content.stackViewContainer.contentSize.height
    }
    
    /// Добавляет на экран fullPlaceholder
    private func placePlaceholderView() {
        self.view.addSubview(placeholderBackgroundView)
        placeholderBackgroundView.backgroundColor = UIColor.white
        
        let distance = UIDevice.current.isIpad ? 0 : UIScreen.main.bounds.height - Constants.detailsStartHeight
        
        placeholderBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        placeholderBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        placeholderBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        placeholderBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: distance).isActive = true
        placeholderBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        placeholderBackgroundView.addGestureRecognizer(panRecognizer)
        
        let fullPlaceholder = content.fullPlaceholder
        placeholderBackgroundView.addSubview(fullPlaceholder)
        
        fullPlaceholder.leftAnchor.constraint(equalTo: placeholderBackgroundView.leftAnchor).isActive = true
        fullPlaceholder.rightAnchor.constraint(equalTo: placeholderBackgroundView.rightAnchor).isActive = true
        fullPlaceholder.bottomAnchor.constraint(equalTo: placeholderBackgroundView.bottomAnchor).isActive = true
        fullPlaceholder.topAnchor.constraint(equalTo: placeholderBackgroundView.topAnchor).isActive = true
        fullPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        pinTapToCloseView(to: placeholderBackgroundView)
    }
    
    /// Добавляет на экран сообщение с ошибкой
    private func createAndPlaceLabel(with error: Error) {
        let errorLabel = UILabel()
        errorLabel.font = UIFont.systemFont(ofSize: 17)
        errorLabel.textColor = content.viewConfiguration.errorPlaceholderTextColor
        errorLabel.text = error.localizedDescription
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        placeholderBackgroundView.addSubview(errorLabel)
        
        errorLabel.leftAnchor.constraint(equalTo: placeholderBackgroundView.leftAnchor, constant: 15).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: placeholderBackgroundView.rightAnchor, constant: -15).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: placeholderBackgroundView.bottomAnchor).isActive = true
        errorLabel.topAnchor.constraint(equalTo: placeholderBackgroundView.topAnchor).isActive = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Анимированно с фейдом показывает контент и удаляет плейсхолдер
    private func animateContentAppearenceAfterPlaceholder() {
        self.content.fullPlaceholder.clearAnimations()
        self.content.header.view.alpha = 0
        self.content.stackViewContainer.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.content.header.view.alpha = 1
            self.content.stackViewContainer.alpha = 1
        }, completion: {(_) in
            self.placeholderBackgroundView.removeFromSuperview()
        })
    }
    
    // MARK: - Скрытие экрана по тапу на пустую область сверху
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(shouldCloseModule))
    
    private func configureTapToCloseHelpView() {
        tapToCloseHelpView.backgroundColor = .clear
        tapToCloseHelpView.addGestureRecognizer(tapRecognizer)
    }

    private func pinTapToCloseView(to view: UIView) {
        if !UIDevice.current.isIpad {
            configureTapToCloseHelpView()
            
            tapToCloseHelpView.removeFromSuperview()
            self.view.addSubview(tapToCloseHelpView)
            
            tapToCloseHelpView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            tapToCloseHelpView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            tapToCloseHelpView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            tapToCloseHelpView.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            tapToCloseHelpView.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    @objc fileprivate func shouldCloseModule() {
        dismiss(animated: true,
                completion: nil)
    }
    
    @objc private func onTapOutside(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        
        let location = recognizer.location(in: nil)
        
        if !view.point(inside: view.convert(location, from: view.window), with: nil) {
            view.window?.removeGestureRecognizer(recognizer)
            dismiss(animated: true,
                    completion: nil)
        }
    }
    
    // MARK: - Dragging placeholder
    
    private var initialPlaceholderPosition: CGPoint?
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: placeholderBackgroundView)
        
        switch sender.state {
        case .began:
            initialPlaceholderPosition = placeholderBackgroundView.center

        case .changed:
            guard let initialPlaceholderPosition = initialPlaceholderPosition else { return }
            // запрещаем скролл вверх
            guard placeholderBackgroundView.center.y + translation.y >= initialPlaceholderPosition.y else { return }
            
            placeholderBackgroundView.center.y += translation.y
            sender.setTranslation(CGPoint.zero, in: placeholderBackgroundView)

        case .cancelled:
            endDragging()

        case .ended:
            endDragging()

        default:
            break
        }
    }
    
    private func endDragging() {
        guard let initialPlaceholderPosition = initialPlaceholderPosition else { return }
        if placeholderBackgroundView.center.y > initialPlaceholderPosition.y + Constants.detailShouldCloseAdditionalOffset {
            self.shouldCloseModule()
        } else {
            UIView.animate(withDuration: .detailsElementDisappearingAnimationTime, animations: {
                self.placeholderBackgroundView.center.y = initialPlaceholderPosition.y
            })
        }
        
        self.initialPlaceholderPosition = nil
    }
}

// MARK: - UIScrollViewDelegate

extension DetailsBaseViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxHeaderHeight = content.header.maximizedStateHeight
        let minHeaderHeight = content.header.minimizedStateHeight
        
        let reversedContentOffset = -scrollView.contentOffset.y
        
        let isWideDesign = UIDevice.current.isIpad
        if isWideDesign, reversedContentOffset >= maxHeaderHeight {
            scrollView.setContentOffset(CGPoint(x: 0, y: -maxHeaderHeight), animated: false)
            headerViewControllerBottomConstraint?.constant = maxHeaderHeight
            self.content.header.changeCompression(to: .maximizedState)
            return
        }
        
        let headerViewEarsHeight = isWideDesign ? 0.0 : Constants.headerViewEarsHeight
        
        // Смещение хедера в зависимости от скролла
        let minimumHeaderBottomOffset = (minHeaderHeight - headerViewEarsHeight)
        
        if reversedContentOffset >= minimumHeaderBottomOffset {
            headerViewControllerBottomConstraint?.constant = reversedContentOffset
        } else {
            headerViewControllerBottomConstraint?.constant = minimumHeaderBottomOffset
        }
        
        // Сворачивание хедера в зависимости от скролла
        var headerViewDynamicState: CGFloat
        if reversedContentOffset < maxHeaderHeight - headerViewEarsHeight {
            
            if reversedContentOffset >= minHeaderHeight - headerViewEarsHeight {
                let minMaxHeaderViewHeightDifference = (maxHeaderHeight - minHeaderHeight)
                let newScaleState =
                    (reversedContentOffset - minHeaderHeight + headerViewEarsHeight) / minMaxHeaderViewHeightDifference
                
                headerViewDynamicState = newScaleState
            } else {
                headerViewDynamicState = .minimizedState
            }
        } else {
            headerViewDynamicState = .maximizedState
        }
        
        headerViewLastDynamicState = headerViewDynamicState
        content.header.changeCompression(to: headerViewLastDynamicState)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let maxHeaderHeight = content.header.maximizedStateHeight
        let minHeaderHeight = content.header.minimizedStateHeight
        let stackViewContainer = content.stackViewContainer
        
        let contentOffset = -targetContentOffset.pointee.y
        
        let headerViewEarsHeight = UIDevice.current.isIpad ? 0.0 : Constants.headerViewEarsHeight
        
        // Начало сжатия хедера
        let headerBeganScalingDown = (contentOffset <= maxHeaderHeight - headerViewEarsHeight)
        let headerNotScaledToZero = (contentOffset > minHeaderHeight - headerViewEarsHeight)
        
        if headerBeganScalingDown && headerNotScaledToZero {
            let minMaxHeaderDifference = (maxHeaderHeight - minHeaderHeight)
            let enoughOffsetToScaleDown = minMaxHeaderDifference * Constants.userInteractionApplyingMultiplier
            
            var yOffset = headerViewEarsHeight
            
            if ((maxHeaderHeight - headerViewEarsHeight) - contentOffset) > enoughOffsetToScaleDown {
                yOffset -= minHeaderHeight
            } else {
                yOffset -= maxHeaderHeight
                yOffset += 1.0
            }
            
            stackViewContainer.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffset = -scrollView.contentOffset.y
        
        // Закрытие экрана
        if contentOffset > scrollViewStartInset + Constants.detailShouldCloseAdditionalOffset {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension DetailsBaseViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.mode = .presentation
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.mode = .dismission
        return animator
    }
}

extension DetailsBaseViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

// MARK: - Constants

extension TimeInterval {
   
    static let detailsElementDisappearingAnimationTime: TimeInterval = 0.1
}
