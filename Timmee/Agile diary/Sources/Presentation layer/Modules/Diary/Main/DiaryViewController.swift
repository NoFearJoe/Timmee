//
//  DiaryViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 23/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import UIComponents

final class DiaryViewController: BaseViewController {
    
    // MARK: UI
    
    private let headerView = LargeHeaderView(frame: .zero)
    
    private let diaryEntriesListView = DiaryEntriesListView()
    
    private let bottomViewsContainer = UIStackView(frame: .zero)
    private let diaryEntryCreationView = DiaryEntryCreationView()
    private let diaryEntryAttachmentView = DiaryEntryAttachmentView()
    private let bottomStretchableView = UIView()
    
    private var bottomViewBottomConstraint: NSLayoutConstraint!
    
    private let placeholderContainer = UIView()
    private let placeholderView = PlaceholderView.loadedFromNib()
    
    // MARK: Services
    
    private let keyboardManager = KeyboardManager()
    
    private let swipeActionsProvider = DiaryEntryCellSwipeActionsProvider()
    
    private let diaryService = ServicesAssembly.shared.diaryService
    
    private lazy var cacheSubscriber = TableViewCacheAdapter(tableView: diaryEntriesListView)
    private lazy var diaryObserver: CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry> = {
        let observer = diaryService.diaryEntriesObserver()
        observer.setSubscriber(cacheSubscriber)
        observer.setDelegate(
            CachedEntitiesObserverDelegate<DiaryEntry>(onEntitiesCountChange: { [weak self] count in
                self?.placeholderContainer.isHidden = count > 0
            })
        )
        return observer
    }()
    
    // MARK: State
    
    private var attachmentState = AttachmentState()
    
    // MARK: Lifecycle
    
    override func prepare() {
        super.prepare()
        
        setupHeaderView()
        setupBottomViewsContainer()
        setupDiaryEntryCreationView()
        setupDiaryEntryAttachmentView()
        setupBottomStretchableView()
        setupDiaryEntriesListView()
        setupPlaceholder()
        
        setupLayout()

        setupKeyboardManager()
        setupSwipeActionsProvider()
    }
    
    override func refresh() {
        super.refresh()
        
        diaryObserver.fetch()
        
        reloadAttachmentView()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        diaryEntriesListView.backgroundColor = AppTheme.current.colors.middlegroundColor
        diaryEntryCreationView.backgroundColor = AppTheme.current.colors.foregroundColor
        diaryEntryAttachmentView.backgroundColor = AppTheme.current.colors.foregroundColor
        bottomStretchableView.backgroundColor = AppTheme.current.colors.foregroundColor
        setupPlaceholderAppearance()
    }
    
    // MARK: Public methods
    
    func forceEntryCreation(text: String, attachment: DiaryEntry.Attachment, attachedEntity: Any?) {
        diaryEntryCreationView.setText(text)
        attachmentState.attachment = attachment
        attachmentState.attachedEntity = attachedEntity
        reloadAttachmentView()
        diaryEntryCreationView.forceEditing()
    }
    
    // MARK: Private methods
    
    private func setupHeaderView() {
        view.addSubview(headerView)
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = AppTheme.current.fonts.bold(34)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.text = "diary".localized
        
        let subtitleLabel = UILabel(frame: .zero)
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
        subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        let labelsContainerView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsContainerView.axis = .vertical
        labelsContainerView.distribution = .equalSpacing
        labelsContainerView.spacing = 8
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "cross"), for: .normal)
        closeButton.addTarget(self, action: #selector(onTapToCloseButton), for: .touchUpInside)
        
        headerView.titleLabel = titleLabel
        headerView.subtitleLabel = subtitleLabel
        headerView.leftButton = closeButton
        
        headerView.addSubview(closeButton)
        headerView.addSubview(labelsContainerView)
        
        [headerView.leading(), headerView.top(), headerView.trailing()].toSuperview()
        
        closeButton.leading(8).toSuperview()
        closeButton.width(36)
        closeButton.height(36)
        if #available(iOS 11.0, *) {
            closeButton.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        } else {
            closeButton.topAnchor.constraint(equalTo: headerView.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
        }
        [labelsContainerView.leading(15), labelsContainerView.bottom(8), labelsContainerView.trailing(15)].toSuperview()
        labelsContainerView.topToBottom(8).to(closeButton, addTo: headerView)
    }
    
    private func setupDiaryEntriesListView() {
        view.addSubview(diaryEntriesListView)
        
        diaryEntriesListView.delegate = self
        diaryEntriesListView.dataSource = self
        
        [diaryEntriesListView.leading(), diaryEntriesListView.trailing()].toSuperview()
        diaryEntriesListView.topToBottom().to(headerView, addTo: view)
        diaryEntriesListView.bottomToTop().to(bottomViewsContainer, addTo: view)
    }
    
    private func setupBottomViewsContainer() {
        view.addSubview(bottomViewsContainer)
        
        bottomViewsContainer.axis = .vertical
        bottomViewsContainer.distribution = .equalSpacing
        
        [bottomViewsContainer.leading(), bottomViewsContainer.trailing()].toSuperview()
        if #available(iOS 11.0, *) {
            bottomViewBottomConstraint = bottomViewsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            bottomViewBottomConstraint = bottomViewsContainer.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        }
        bottomViewBottomConstraint.isActive = true
    }
    
    private func setupDiaryEntryCreationView() {
        bottomViewsContainer.addArrangedSubview(diaryEntryCreationView)
        diaryEntryCreationView.onCreate = { [unowned self] text in
            let entity = DiaryEntry(id: RandomStringGenerator.randomString(length: 24),
                                    text: text,
                                    date: Date.now,
                                    attachment: self.attachmentState.attachment)
            self.diaryService.createOrUpdateDiaryEntry(entity, completion: { success in
                self.attachmentState.clear()
                self.diaryEntryAttachmentView.configure(attachment: .none, subject: nil)
                self.diaryEntryCreationView.clear()
            })
        }
        diaryEntryCreationView.onAttachment = { [unowned self] in
            let sourceView = self.diaryEntryCreationView.attachmentButton
            let attachmentController = DiaryEntryAttachmentTypePickerViewController(sourceView: sourceView)
            attachmentController.onSelectType = { [unowned self] type in
                self.presentAttachmentPicker(type: type)
            }
            self.present(attachmentController, animated: true, completion: nil)
        }
    }
    
    private func setupDiaryEntryAttachmentView() {
        bottomViewsContainer.addArrangedSubview(diaryEntryAttachmentView)
        diaryEntryAttachmentView.onClear = { [unowned self] in
            self.attachmentState.clear()
            self.reloadAttachmentView()
        }
    }
    
    private func reloadAttachmentView() {
        let subject: String?
        switch attachmentState.attachedEntity {
        case let sprint as Sprint: subject = sprint.title
        case let habit as Habit: subject = habit.title
        case let goal as Goal: subject = goal.title
        default: subject = nil
        }
        diaryEntryAttachmentView.configure(attachment: attachmentState.attachment,
                                           subject: subject)
    }
    
    private func setupBottomStretchableView() {
        view.addSubview(bottomStretchableView)
        
        [bottomStretchableView.leading(), bottomStretchableView.trailing(), bottomStretchableView.bottom()].toSuperview()
        bottomStretchableView.topToBottom().to(bottomViewsContainer, addTo: view)
    }
    
    private func setupPlaceholder() {
        view.addSubview(placeholderContainer)
        placeholderContainer.backgroundColor = .clear
        [placeholderContainer.leading(), placeholderContainer.trailing()].toSuperview()
        placeholderContainer.topToBottom().to(headerView, addTo: view)
        placeholderContainer.bottomToTop().to(bottomViewsContainer, addTo: view)
        
        placeholderView.icon = UIImage(imageLiteralResourceName: "history")
        placeholderView.title = "diary_placeholder_title".localized
        placeholderView.subtitle = "diary_placeholder_subtitle".localized
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
    }
    
    private func setupPlaceholderAppearance() {
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
    }
    
    private func setupLayout() {
        view.bringSubviewToFront(bottomViewsContainer)
        view.bringSubviewToFront(headerView)
    }
    
    private func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            self.view.layoutIfNeeded()
            if #available(iOS 11.0, *) {
                self.bottomViewBottomConstraint.constant = -frame.height + self.view.safeAreaInsets.bottom
            } else {
                self.bottomViewBottomConstraint.constant = -frame.height
            }
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            self.view.layoutIfNeeded()
            self.bottomViewBottomConstraint.constant = 0
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupSwipeActionsProvider() {
        swipeActionsProvider.shouldShowDeleteAction = { indexPath in
            return true
        }
        
        swipeActionsProvider.onDelete = { [unowned self] indexPath in
            guard let diaryEntry = self.diaryObserver.item(at: indexPath) else { return }
            self.diaryService.removeDiaryEntry(diaryEntry, completion: { success in
                print(success)
            })
        }
    }
    
    private func presentAttachmentPicker(type: DiaryEntryAttachmentType) {
        let attachmentPickerProvider = DiaryEntryAttachmentPickerProvider(type: type)
        
        let detailsViewController = DetailsBaseViewController(content: attachmentPickerProvider)
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .formSheet
        if UIDevice.current.isPhone {
            navigationController.transitioningDelegate = detailsViewController
        }
        
        attachmentPickerProvider.onSelectAttachment = { [unowned self, unowned navigationController] entity in
            self.attachmentState.attachedEntity = entity
            switch entity {
            case let habit as Habit:
                self.attachmentState.attachment = .habit(id: habit.id)
            case let goal as Goal:
                self.attachmentState.attachment = .goal(id: goal.id)
            case let sprint as Sprint:
                self.attachmentState.attachment = .sprint(id: sprint.id)
            default: break
            }
            self.reloadAttachmentView()
            
            navigationController.dismiss(animated: true, completion: nil)
        }
        
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func onTapToCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension DiaryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return diaryObserver.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryObserver.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryEntryCell.identifier, for: indexPath) as! DiaryEntryCell
        if let diaryEntry = diaryObserver.item(at: indexPath) {
            cell.configure(model: diaryEntry)
            cell.delegate = swipeActionsProvider
        }
        return cell
    }
    
}

extension DiaryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
