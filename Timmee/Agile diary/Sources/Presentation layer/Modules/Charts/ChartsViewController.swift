//
//  ChartsViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 19.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

enum ChartType {
    case habits
    case water
    case mostFrequentlyPerformedHabit
    case mostRarelyPerformedHabit
    case averageMood
    
    static var all: [ChartType] {
        if ProVersionPurchase.shared.isPurchased() {
            return [habits, mostFrequentlyPerformedHabit, mostRarelyPerformedHabit, water, averageMood]
        } else {
            return [habits, mostFrequentlyPerformedHabit, mostRarelyPerformedHabit]
        }
    }
    
    var title: String {
        switch self {
        case .habits: return "habits".localized
        case .water: return "water".localized
        case .mostFrequentlyPerformedHabit: return "f".localized
        case .mostRarelyPerformedHabit: return "r".localized
        case .averageMood: return "average_mood".localized
        }
    }
    
    var cellType: BaseChartCell.Type {
        switch self {
        case .habits: return HabitsChartCell.self
        case .water: return WaterChartCell.self
        case .mostFrequentlyPerformedHabit: return MostFrequentlyPerformedHabitChartCell.self
        case .mostRarelyPerformedHabit: return MostRarelyPerformedHabitChartCell.self
        case .averageMood: return MoodChartCell.self
        }
    }
}

final class ChartsViewController: BaseViewController, SprintInteractorTrait {
    
    var sprint: Sprint?
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    
    @IBOutlet private var collectionView: UICollectionView!
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare() {
        super.prepare()
        
        title = "my_progress".localized
    }
    
    override func refresh() {
        super.refresh()
        
        if sprint == nil {
            sprint = getCurrentSprint()
        }
        
        collectionView.reloadData()
    }
    
    private func showFullProgress(chartType: ChartType) {
        switch chartType {
        case .habits: performSegue(withIdentifier: "ShowExtendedHabitsProgress", sender: sprint)
        case .water: performSegue(withIdentifier: "ShowExtendedWaterProgress", sender: sprint)
        case .averageMood: performSegue(withIdentifier: "ShowExtendedMoodProgress", sender: sprint)
        default: return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let extendedChartViewController = segue.destination as? ExtendedChartViewController {
            extendedChartViewController.sprint = sender as? Sprint
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}

extension ChartsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    } 
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChartType.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chart = ChartType.all[indexPath.item]
        let cell = dequeueChartCell(ofType: chart.cellType, collectionView: collectionView, indexPath: indexPath)
        if let sprint = sprint {
            cell.update(sprint: sprint)
        }
        cell.onShowFullProgress = { [unowned self] in
            self.showFullProgress(chartType: chart)
        }
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
        return ChartType.all[indexPath.item].cellType.size(for: collectionView.bounds.size)
    }
    
}
