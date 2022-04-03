//
//  Music.swift
//  wordle
//
//  Created by 方仕賢 on 2022/4/2.
//

import Foundation
import AVFoundation
import AVKit

class Music {
    var player = AVPlayer()
    var playerItem: AVPlayerItem?
    var fileUrl: URL?
    
    func playMusic() {
        fileUrl = Bundle.main.url(forResource: "Ghost", withExtension: "mp3")!
        playerItem = AVPlayerItem(url: fileUrl!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        print("music played")
    }
}
