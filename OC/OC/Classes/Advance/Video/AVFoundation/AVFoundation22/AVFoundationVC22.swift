//
//  AVFoundationVC22.swift
//  AVFoundationDemo
//
//  Created by yier on 2020/2/20.
//  Copyright © 2020 yier. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class AVFoundationVC22 : UIViewController  {
    var videos: [Video] = Video.allVideos()
         
     let VideoCellReuseIdentifier = "VideoCell"
     let tableView = UITableView()
     
     let videoPreviewLooper = VideoLooperView(clips: VideoClip.allClip())
         
    deinit {
        print("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 10.0, *) {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient, mode: AVAudioSession.Mode.moviePlayback, options: [.mixWithOthers])
        } else {
            // Fallback on earlier versions
        }
        videoPreviewLooper.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoPreviewLooper.pause()
    }
    
    //结合的AVPlayerItem播放
   //AVPlayerLooper
   //AVQueuePlayer
}

extension AVFoundationVC22: UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoCellReuseIdentifier, for: indexPath) as? VideoTableViewCell else {
          return VideoTableViewCell()
        }
        cell.video = videos[indexPath.row]
        return cell
      }
      
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = videos[indexPath.row]
        return VideoTableViewCell.height(for: video)
      }
      
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //2 Create an AVPlayerViewController and present it when the user taps
        let video = videos[indexPath.row]

        let videoURL = video.url
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
      
        present(playerViewController, animated: true) {
          player.play()
        }
      }
}

extension AVFoundationVC22: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videos.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
}
