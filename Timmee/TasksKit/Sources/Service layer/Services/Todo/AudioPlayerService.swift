//
//  AudioPlayerService.swift
//  TasksKit
//
//  Created by Илья Харабет on 09.05.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset

public protocol AudioPlayerServiceInput: class {
    func play(fileName: String, completion: @escaping () -> Void)
    func stop()
}

final class AudioPlayerService: AudioPlayerServiceInput {
    
    private var sound: Sound?
    
    func play(fileName: String, completion: @escaping () -> Void) {
        let url = URL(fileURLWithPath: getPathToAudioFile(named: fileName))
        sound = Sound(url: url)
        sound?.play { _ in
            completion()
        }
    }
    
    func stop() {
        sound?.stop()
    }
    
    private let recordsDirectory: URL = FilesService.URLs.documents!.appendingPathComponent("AudioRecords", isDirectory: true)
    
    private func getPathToAudioFile(named name: String) -> String {
        var fileName = name
        if !fileName.hasSuffix(".m4a") {
            fileName += ".m4a"
        }
        return recordsDirectory.appendingPathComponent(fileName).path
    }
    
}
