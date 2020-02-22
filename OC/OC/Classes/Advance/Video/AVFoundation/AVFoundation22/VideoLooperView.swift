//
//  VideoLooperView.swift
//  AVFoundationDemo
//
//  Created by yier on 2020/2/21.
//  Copyright © 2020 yier. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class VideoLooperView: UIView {
    let clips: [VideoClip]
    let videoPlayerView = VideoPlayerView()
    
    @objc private let player = AVQueuePlayer()
    
    private var token: NSKeyValueObservation?
    
    deinit {
        token?.invalidate()
    }
    
    init(clips: [VideoClip]) {
        self.clips = clips
        
        super.init(frame: .zero)
        
        initializePlayer()
        addGestureRecognizers()
    }

    private func initializePlayer(){
        videoPlayerView.player = player
        
        addAllVideosToPlayer()
        
        player.volume = 0.0
        player.play()
    
        token = player.observe(\.currentItem, changeHandler: { [weak self] (player, _) in
            if player.items().count == 1{
                self?.addAllVideosToPlayer()
            }
        })
    }
    
    private func addAllVideosToPlayer(){
        for video in clips {
            let asset = AVURLAsset(url: video.url)
            let item = AVPlayerItem(asset: asset)
            player.insert(item, after: player.items().last)
        }
    }
    
    func pause(){
        player.pause()
    }
    
    func play(){
        player.play()
    }
    
    func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(VideoLooperView.wasTapped))
        let doubleTap = UITapGestureRecognizer(target: self,
                                                  action: #selector(VideoLooperView.wasDoubleTapped))
           doubleTap.numberOfTapsRequired = 2
           
           // 2
           tap.require(toFail: doubleTap)

           // 3
           addGestureRecognizer(tap)
           addGestureRecognizer(doubleTap)
    }
    
    @objc func wasTapped(){
        player.volume = player.volume == 1.0 ? 0.0: 1.0
    }
    
    @objc func wasDoubleTapped(){
        player.rate = player.rate == 1.0 ? 2.0 : 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
