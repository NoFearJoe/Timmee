//
//  HabitsCollectionsLoader.swift
//  Agile diary
//
//  Created by i.kharabet on 18.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Firebase
import FirebaseStorage

struct HabitsCollection {
    let id: String
    let title: String
    let backgroundImageUrl: String
    let habits: [Habit]
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
              let title = json["title"] as? String,
              let habitsJSON = json["habits"] as? [[String: Any]]
        else { return nil }
        
        self.id = id
        self.title = title
        self.backgroundImageUrl = json["backgroundImageUrl"] as? String ?? ""
        self.habits = habitsJSON.compactMap(Habit.init(json:))
    }
}

final class HabitsCollectionsLoader {
    
    static let shared = HabitsCollectionsLoader()
    
    static func initialize() {
        FirebaseApp.configure()
    }
    
    private var cachedCollections: [HabitsCollection] = []
    
    func loadHabitsCollections(success: @escaping ([HabitsCollection]) -> Void, fail: @escaping (Error) -> Void) {
        if !cachedCollections.isEmpty {
            success(cachedCollections)
        }
        
        let storage = Storage.storage()
        let languageDirectory = getAppropriateCollectionLanguageDirectoryName()
        let pathReference = storage.reference(withPath: "collections/\(languageDirectory)").child("collections.json")
        pathReference.getData(maxSize: 1024 * 1024) { [weak self] data, error in
            if let error = error {
                fail(error)
            } else if let data = data {
                guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                    success([]); return
                }
                guard let json = jsonData as? [String: Any] else {
                    success([]); return
                }
                guard let collectionsJSONArray = json["collections"] as? [[String: Any]] else {
                    success([]); return
                }
                let collections = collectionsJSONArray.compactMap(HabitsCollection.init(json:))
                self?.cachedCollections = collections
                success(collections)
            }
        }
    }
    
    private func getAppropriateCollectionLanguageDirectoryName() -> String {
        let language = Locale.preferredLanguages.first ?? "en-EN"
        switch language {
        case let lang where lang.contains("ru"): return "ru"
        case let lang where lang.contains("en"): return "en"
        default: return "en"
        }
    }
    
}
