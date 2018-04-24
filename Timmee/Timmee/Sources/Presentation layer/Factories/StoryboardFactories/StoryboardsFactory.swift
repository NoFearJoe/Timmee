//
//  StoryboardsFactory.swift
//  Timmee
//
//  Created by Ilya Kharabet on 14.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIStoryboard

final class StoryboardsFactory {

    static var main: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "Main")
    }
    
    static var lists: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "Lists")
    }
    
    static var listRepresentations: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "ListRepresentations")
    }
    
    static var taskEditor: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "TaskEditor")
    }
    
    static var listEditor: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "ListEditor")
    }
    
    static var taskParameterEditors: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "TaskParameterEditors")
    }
    
    static var pin: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "Pin")
    }
    
    static var settings: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "Settings")
    }
    
    static var search: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "Search")
    }
    
    static var photoPreview: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "PhotoPreview")
    }
    
    static var education: UIStoryboard {
        return StoryboardsFactory.storyboard(named: "Education")
    }

}

fileprivate extension StoryboardsFactory {

    static func storyboard(named name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }

}
