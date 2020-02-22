//
//  VideoClip.swift
//  AVFoundationDemo
//
//  Created by yier on 2020/2/21.
//  Copyright © 2020 yier. All rights reserved.
//

import Foundation
import UIKit

class VideoClip: NSObject {
    let url: URL
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    class func allClip() -> [VideoClip]{
        var clips: [VideoClip] = []
        
        //    // Add HLS Stream to the beginning of clip show
        //    if let url = URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.m3u8") {
        //      let remoteVideo = VideoClip(url: url)
        //      clips.append(remoteVideo)
        //    }
        
        let names = ["AVFoundation_av", "AVFoundation_hourse"]
        for name in names {
             let urlPath = Bundle.main.path(forResource: name, ofType: "mp4")!
             let url = URL(fileURLWithPath: urlPath)
             
             let clip = VideoClip(url: url)
             clips.append(clip)
           }

        return clips
    }
}
