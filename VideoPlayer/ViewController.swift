//
//  ViewController.swift
//  VideoPlayer_fishCQ
//
//  Created by iK on 6/22/18.
//  Copyright © 2018 iK. All rights reserved.


import UIKit
import AVFoundation
import AVKit


class ViewController: UIViewController {
   
    
    @IBOutlet weak var viewVideo: UIView!
    
    @IBOutlet weak var sliderTime: UISlider!
    @IBOutlet weak var lblcurrentTime: UILabel!
    @IBOutlet weak var lbldurationTime: UILabel!
    
    @IBOutlet weak var buton: UIButton!
    var player:AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isPlaying = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!
        player = AVPlayer(url: url)
       
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        viewVideo.layer.addSublayer(playerLayer)
        
        addTimeObserver()
        
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        player.play()
//    }
//
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        playerLayer.frame = viewVideo.bounds
    }

    @IBAction func bntPlay(_ sender: UIButton) {
        if isPlaying {
            player.pause()
            sender.setTitle("Play", for: .normal)
        } else {
            player.play()
            sender.setTitle("Pause", for: .normal)
        }
        isPlaying = !isPlaying
    }

    @IBAction func bntX2(_ sender: Any) {
        guard let duration = player.currentItem?.duration else {
            return
        }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 5.0
        
        if newTime < (CMTimeGetSeconds(duration) - 5.0) {
            let  time: CMTime = CMTimeMake(Int64(newTime*1000), 1000)
            player.seek(to: time)
            
        }
    }

    @IBAction func bntX(_ sender: Any) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
       var newTime = currentTime + 5.0
        if newTime < 0 {
            newTime = 0
        }
        let  time: CMTime = CMTimeMake(Int64(newTime*1000), 1000)
        player.seek(to: time)
    }
    // slider action
    
    @IBAction func bntSliderChangeTime(_ sender: UISlider) {
        player.seek(to: CMTimeMake(Int64(sender.value*1000), 1000))
    }
    ///???
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath ==  "duration",
            let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.lbldurationTime.text = getTimeString(from: player.currentItem!.duration)
//            self.lblcurrentTime.text = getTimeString(from: player.currentItem?.currentTime())
        }
    }
    // format time for label
    func getTimeString(from time:CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%d:%02d:%02d", arguments: [hours, minutes, seconds])
          } else {
              return String(format: "%02d:%02d", arguments: [minutes, seconds])
                }
    }
    // label currentTime
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        let timePeri = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: {[weak self] time in
            guard let currentItem = self?.player.currentItem
                else {
                return
            }
            self?.sliderTime.maximumValue = Float(currentItem.duration.seconds)
            self?.sliderTime.minimumValue = 0
            self?.sliderTime.value = Float(currentItem.currentTime().seconds)
            self?.lblcurrentTime.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }
}


