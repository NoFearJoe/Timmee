//
//  DiaryEntryAttachmentPickerProvider.swift
//  Agile diary
//
//  Created by i.kharabet on 29/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import UIComponents

final class DiaryEntryAttachmentPickerProvider: NSObject, DetailModuleProvider {
    
    var onSelectAttachment: ((Any) -> Void)?
    
    private let attachmentType: DiaryEntryAttachmentType
    
    private let contentView = AutoSizingTableView(frame: .zero, style: .plain)
    
    private var entities: [Any] = []
    private var dataSource: [(String, String?)] = []
    
    private var searchText: String = ""
    
    private let habitsService = ServicesAssembly.shared.habitsService
    private let goalsService = ServicesAssembly.shared.goalsService
    private let sprintsService = ServicesAssembly.shared.sprintsService
    
    init(type: DiaryEntryAttachmentType) {
        self.attachmentType = type
        
        super.init()
        
        setupContentView()
    }
    
    func loadContent(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    func reloadContent() {
        if contentView.superview == nil {
            stackViewContainer.addView(contentView)
            setupContentView()
        }
        
        switch attachmentType {
        case .habit:
            let habits = habitsService.searchHabits(searchText: searchText)
            entities = habits
            dataSource = habits.map { ($0.title, $0.notificationDate?.asTimeString) }
        case .goal:
            let goals = goalsService.searchGoals(searchText: searchText)
            entities = goals
            dataSource = goals.map { ($0.title, nil) }
        case .sprint:
            let sprints = sprintsService.fetchSprints()
            self.entities = sprints
            if searchText.isEmpty {
                dataSource = sprints.map { ($0.title, "\($0.startDate.asDayMonthYear) - \($0.endDate.asDayMonthYear)") }
            } else {
                dataSource = sprints.filter { $0.title.lowercased().contains(searchText.lowercased()) }
                    .map { ($0.title, "\($0.startDate.asDayMonthYear) - \($0.endDate.asDayMonthYear)") }
            }
        }
        
        contentView.reloadData()
    }
    
    lazy var header: UIViewController & VerticalCompressibleViewContainer = {
        let container = CompressibleViewContainerController()
        container.compressibleViewContainer.backgroundView.backgroundColor = AppTheme.current.colors.foregroundColor
        
        let searchBarView = CompressibleSearchBarView()
        searchBarView.configure(with: CompressibleSearchBarView.Model(placeholder: "Search...".localized))
        searchBarView.onTextChange = { [unowned self] text in
            self.searchText = text
            self.reloadContent()
        }
        searchBarView.searchBar.tintColor = AppTheme.current.colors.activeElementColor
        searchBarView.searchBar.barBackgroundColor = AppTheme.current.colors.decorationElementColor
        searchBarView.searchBar.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        searchBarView.searchBar.barStyle = AppThemeType.current == .dark ? .black : .default
        container.add(compressibleView: searchBarView)
        
        let separator = CompressibleEmptyView()
        separator.configure(with: CompressibleEmptyView.Model(backgroundColor: AppTheme.current.colors.decorationElementColor,
                                                              maximizedStateHeight: 1,
                                                              minimizedStateHeight: 1,
                                                              reversed: false))
        container.add(compressibleView: separator)
        
        return container
    }()
    
    lazy var stackViewContainer: UIScrollView & ITCSStackViewContainer = TCSStackViewContainer.loadedFromNib()
    
    var cachedHeaderDataAvailable: Bool {
        return true
    }
    
    var cachedContentDataAvailable: Bool {
        return true
    }
    
    lazy var fullPlaceholder: UIView & AnimatableView = {
        let skeletView = DetailsFullPlaceholderDefault.loadedFromNib()
        let placeholderView = SkeletonAnimatableView(skeletView: skeletView, animationKey: "ak")
        placeholderView.backgroundColor = AppTheme.current.colors.foregroundColor
        return placeholderView
    }()
    
    lazy var contentPlaceholder: UIView & AnimatableView = {
        let skeletView = DetailsContentPlaceholderDefault.loadedFromNib()
        let placeholderView = SkeletonAnimatableView(skeletView: skeletView, animationKey: "ak")
        placeholderView.backgroundColor = AppTheme.current.colors.foregroundColor
        return placeholderView
    }()
    
    var viewConfiguration: DetailsContentViewConfiguration {
        return .init(bottomBackgroundColor: AppTheme.current.colors.foregroundColor,
                     errorPlaceholderTextColor: AppTheme.current.colors.activeElementColor)
    }
    
    private func setupContentView() {
        contentView.register(DiaryEntryAttachmentPickerCell.self, forCellReuseIdentifier: DiaryEntryAttachmentPickerCell.identifier)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.separatorColor = AppTheme.current.colors.decorationElementColor
        contentView.keyboardDismissMode = .onDrag
        contentView.showsVerticalScrollIndicator = false
        contentView.isScrollEnabled = false
    }
    
}

extension DiaryEntryAttachmentPickerProvider: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryEntryAttachmentPickerCell.identifier, for: indexPath) as! DiaryEntryAttachmentPickerCell
        
        let model = dataSource[indexPath.row]
        cell.configure(title: model.0, subtitle: model.1)
        
        return cell
    }
    
}

extension DiaryEntryAttachmentPickerProvider: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = entities[indexPath.row]
        onSelectAttachment?(entity)
    }
    
}
