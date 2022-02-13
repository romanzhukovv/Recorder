//
//  AudioCell.swift
//  Recorder
//
//  Created by Roman Zhukov on 12.02.2022.
//

import UIKit
import AVFAudio

class AudioCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var duration: UILabel!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var timeLeftLabel: UILabel!
    
    private var audio: AVAudioPlayer!
    private var isPlaying = false
    
    lazy var progressLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateProgressSong))
    lazy var currentTimeLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateCurrentTime))
    lazy var currentLeftTime: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateLeftTime))
    lazy var currentPlayButton: CADisplayLink = CADisplayLink(target: self, selector: #selector(updatePlayButton))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor.black
    }

    @IBAction func playButtonAction() {
        if isPlaying == false {
            audio.play()
            progressLink.add(to: .main, forMode: .common)
            currentTimeLink.add(to: .main, forMode: .common)
            currentLeftTime.add(to: .main, forMode: .common)
            currentPlayButton.add(to: .main, forMode: .common)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playButton.tintColor = UIColor.black
            isPlaying = true
        } else if isPlaying == true {
            audio.pause()
            progressLink.isPaused
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.tintColor = UIColor.black
            isPlaying = false
        } else if !audio.isPlaying {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.tintColor = UIColor.black
        }
        
    }
    
    @IBAction func jumpButtonAction() {
        audio.currentTime += 3
    }
    
    @IBAction func rewindButtonAction() {
        audio.currentTime -= 3
    }
    @IBAction func progressSliderAction() {
        audio.currentTime = audio.duration * CFTimeInterval(progressSlider.value)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.audio.play()
            self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.playButton.tintColor = UIColor.black
        }
    }
    
    func getAudio(audio: AVAudioPlayer) {
        self.audio = audio
    }
    
    @objc private func updateProgressSong() {
        let progress = Float((audio.currentTime) / (audio.duration))
        progressSlider.setValue(progress, animated: true)
    }
    
    @objc private func updateCurrentTime() {
        let time = Int(audio.currentTime)
        currentTimeLabel.text = "\(time)"
    }
    
    @objc private func updateLeftTime() {
        let time = Int(audio.currentTime - audio.duration)
        timeLeftLabel.text = "\(time)"
    }
    
    @objc private func updatePlayButton() {
        if !audio.isPlaying {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.tintColor = UIColor.black
        }
    }
}
