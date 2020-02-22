//
//  Video.swift
//  AVFoundationDemo
//
//  Created by yier on 2020/2/20.
//  Copyright © 2020 yier. All rights reserved.
//

import Foundation

class Video:NSObject {
    let url: URL
    let thumbURL: URL
    let title: String
    let subtitle: String
    
    init(url: URL, thumbURL: URL, title: String, subtitle: String ) {
        self.url = url;
        self.thumbURL = thumbURL;
        self.title = title;
        self.subtitle = subtitle;
        super.init()
    }
    
    class func localVideos() -> [Video] {
        var videos: [Video] = []
        let names = ["AVFoundation_hourse.mp4", "AVFoundation_av.mp4","AVFoundation_testMOV.mov"]
        let titles = ["New York Flip", "Bullet Train Adventure", "Monkey Village", "Robot Battles"]
        let subtitles = ["Can this guys really flip all of his bros? You'll never believe what happens!",
        "Enjoying the soothing view of passing towns in Japan",
        "Watch as a roving gang of monkeys terrorizes the top of this mountain!",
        "Have you ever seen a robot shark try to eat another robot?"]
        for (index, name) in names.enumerated() {
            let urlPath = Bundle.main.path(forAuxiliaryExecutable: name)!
            let url = URL(fileURLWithPath: urlPath)
            let thumbURLPath = Bundle.main.path(forResource: "background", ofType: "jpeg")!
            let thumbURL = URL(fileURLWithPath: thumbURLPath)
            
            let video = Video(url: url, thumbURL: thumbURL, title: titles[index], subtitle: subtitles[index])
            videos.append(video)
        }
        
        return videos
    }
    
    class func allVideos() -> [Video] {
        var videos = localVideos()
        
        //add one remote video
        let videoURLString = "https://free-hls.boxueio.com/z68-relationship-delete-rules.m3u8"
        if let url = URL(string: videoURLString) {
         let thumbURLPath = Bundle.main.path(forResource: "overlay", ofType: "png")!
         let thumbURL = URL(fileURLWithPath: thumbURLPath)
         let remoteVideo = Video(url: url, thumbURL: thumbURL, title: "泊学", subtitle: "Will we be mauled by vicious foxes? Tune in to find out!")
         videos.append(remoteVideo)
        }

        return videos
    }
}
