//
//  ViewController.swift
//  Recorder
//
//  Created by Roman Zhukov on 09.02.2022.
//

import AVFoundation
import UIKit

class RecorderViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var recordingTableView: UITableView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords = 0
    
    var selectedIndex: Int = 0
    var isExpandRow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        recordingSession = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission { hasPermission in
            if hasPermission {
                print("accepted")
            }
        }
        
        if let number = UserDefaults.standard.object(forKey: "myNumber") {
            numberOfRecords = number as! Int
        }
    }
    
    @IBAction func recordButtonAction() {
        if audioRecorder == nil {
            numberOfRecords += 1
            let fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 1200,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                recordButton.layer.cornerRadius = 15
            } catch {
                displayAlert(title: "Error", message: "Recording failed")
            }
        } else {
            audioRecorder.stop()
            audioRecorder = nil
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            recordingTableView.reloadData()
            recordButton.layer.cornerRadius = recordButton.frame.width/2
        }
    }
    
    func getDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
    }
    
}

extension RecorderViewController {
    private func setupUI() {
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.backgroundColor = UIColor(displayP3Red: 229/255, green: 57/255, blue: 53/255, alpha: 1)
        
        if #available(iOS 13, *)
             {
                 let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                 statusBar.backgroundColor = UIColor(displayP3Red: 229/255, green: 57/255, blue: 53/255, alpha: 1)
                 UIApplication.shared.keyWindow?.addSubview(statusBar)
             } else {
                let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
                if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
                   statusBar.backgroundColor = UIColor(displayP3Red: 229/255, green: 57/255, blue: 53/255, alpha: 1)
                }
             }
        
        recordButton.layer.cornerRadius = recordButton.frame.width/2
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default))
        present(alert, animated: true)
    }
}

extension RecorderViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "Новая запись \(indexPath.row)"
        content.secondaryText = "\(Date().formatted(date: .abbreviated, time: .shortened))"
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recordingTableView.deselectRow(at: indexPath, animated: true)
    
        if selectedIndex == indexPath.row {
            isExpandRow.toggle()
        } else {
            isExpandRow = true
        }
        selectedIndex = indexPath.row
        
        recordingTableView.reloadRows(at: [indexPath], with: .automatic)
        
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: path)
                    audioPlayer.play()
                } catch {
                    print("Errorr")
                }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row && isExpandRow == true {
            return 200
        } else {
            return 70
        }
    }
}

