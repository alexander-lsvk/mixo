//
//  AudioPreviewService.swift
//  Mixo
//
//  Created by Alexander Lisovik on 12/3/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioPreviewStatus {
    case playing
    case stopped
}

var playingObserver: NSKeyValueObservation?

final class AudioPreviewService {
    static let shared = AudioPreviewService()

    var player: AVPlayer?
    var status: AudioPreviewStatus = .stopped {
        didSet {
            switch status {
            case .stopped:
                stop()
                print("Stop")
            case .playing:
                print("Playing")
            }
        }
    }

    func play(url: URL, statusCallback: @escaping (AudioPreviewStatus) -> Void) {
        player = AVPlayer(url: url)

        playingObserver = player?.observe(\.timeControlStatus, options:  [.new, .old], changeHandler: { player, change in
            switch player.timeControlStatus {
            case .paused:
                if self.status != .stopped {
                    self.status = .stopped
                    statusCallback(self.status)
                }

            case .waitingToPlayAtSpecifiedRate:
                break

            case .playing:
                self.status = .playing
                statusCallback(self.status)

            @unknown default:
                break
            }

        })

        player?.play()
    }
}

// MARK: - Private methods
extension AudioPreviewService {
    private func stop() {
        player?.pause()
        player = nil
        playingObserver = nil
    }
}
