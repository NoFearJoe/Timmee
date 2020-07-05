//
//  SiriIntentsManager.swift
//  Agile diary
//
//  Created by Илья Харабет on 05.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Intents

final class SiriIntentsManager {
    
    static let shared = SiriIntentsManager()
    
    func donateTodaysHabitsIntent() {
        guard #available(iOS 12.0, *) else { return }
        
        let intent = TodayHabitsIntentIntent()
        intent.suggestedInvocationPhrase = "todays_habits_suggestion".localized
        INInteraction(intent: intent, response: nil).donate { error in
            guard let error = error else { return }
            
            print("::: Intent donation error: \(error)")
        }
    }
    
}
