//
//  VideoPlayerView.swift
//  AVFoundationDemo
//
//  Created by yier on 2020/2/21.
//  Copyright © 2020 yier. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlayerView: UIView{
    var player: AVPlayer?{
        get{
            return playerLayer.player
        }
        
        set{
            playerLayer.player = newValue
        }
    }
    
    override class var layerClass: AnyClass{
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer{
        return layer as! AVPlayerLayer
    }
}
