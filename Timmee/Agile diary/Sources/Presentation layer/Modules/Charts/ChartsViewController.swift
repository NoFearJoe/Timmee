//
//  ChartsViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 19.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

enum Charts {
    case habits
    
    static let all: [Charts] = [habits]
    
    var title: String {
        switch self {
        case .habits: return "habits".localized
        }
    }
    
    var cellType: BaseChartCell.Type {
        switch self {
        case .habits: return HabitsChartCell.self
        }
    }
}

final class ChartsViewController: BaseViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "my_progress".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
        collectionView.reloadData()
    }
    
}

extension ChartsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Charts.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chart = Charts.all[indexPath.item]
        let cell = dequeueChartCell(ofType: chart.cellType, collectionView: collectionView, indexPath: indexPath)
        cell.update()
        return cell
    }
    
    private func dequeueChartCell<T: BaseChartCell>(ofType type: T.Type, collectionView: UICollectionView, indexPath: IndexPath) -> T {
        return collectionView.dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath) as! T
    }
    
}

extension ChartsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension ChartsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Charts.all[indexPath.item].cellType.size(for: collectionView.bounds.size)
    }
    
}
