//
//  GoalCreationViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 01/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

enum GoalStep {
    case stage(Subtask)
    case habit(Habit)
}

enum GoalPriority: Int {
    case high = 3
    case normal = 2
    case low = 1
}

final class GoalCreationViewController: UINavigationController {
    
    struct State {
        var goalSpecific: String?
        var goalMeasurement: String?
        var goalSteps: [GoalStep] = []
        var goalPriority: GoalPriority?
    }
    
    var state = State()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isNavigationBarHidden = true
        
        let goalSpecificViewController = GoalSpecificViewController()
        goalSpecificViewController.output = self
        
        viewControllers = [goalSpecificViewController]
    }
    
}

extension GoalCreationViewController: GoalSpecificOutput {
    
    func didAskToContinue(specific: String) {
        state.goalSpecific = specific
        
        let goalMeasurementViewController = GoalMeasurementViewController()
        goalMeasurementViewController.output = self
        
        pushViewController(goalMeasurementViewController, animated: true)
    }
    
}

extension GoalCreationViewController: GoalMeasurementOutput {
    
    func didAskToContinue(measurement: String) {
        state.goalMeasurement = measurement
        
        let goalStepsViewController = GoalStepsViewController()
        goalStepsViewController.output = self
        
        pushViewController(goalStepsViewController, animated: true)
    }
    
}

extension GoalCreationViewController: GoalStepsOutput {
    
    func didAskToContinue(steps: [GoalStep]) {
        state.goalSteps = steps
    }
    
}
