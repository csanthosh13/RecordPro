//
//  RecordProController.swift
//  RecordPro


import UIKit
import AVFoundation

extension RecordProController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "Finish Recording", message: "Successfully recorded the audio!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
        }
    }
    
}

extension RecordProController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        let alertMessage = UIAlertController(title: "Finish Playing", message: "Finish playing the recording!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
    }
}

class RecordProController: UIViewController {

    @IBOutlet private var stopButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var recordButton: UIButton!
    @IBOutlet private var timeLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    private var timer: Timer?
    private var elapsedTimeInSecond: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Action methods
    
    @IBAction func stop(sender: UIButton) {
        
        recordButton.setImage(UIImage(named: "Record"), for: UIControlState.normal)
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        playButton.isEnabled = true
        // Stop the audio recorder
        audioRecorder?.stop()
        resetTimer()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
        
    }

    @IBAction func play(sender: UIButton) {
        
        if !audioRecorder.isRecording {
            guard let player = try? AVAudioPlayer(contentsOf: audioRecorder.url) else
            {
                print("Failed to initialize AVAudioPlayer")
                return
            }
            audioPlayer = player
            audioPlayer?.delegate = self
            audioPlayer?.play()
            resetTimer()
        }
        
    }

    @IBAction func record(sender: UIButton) {
        
        // Stop the audio player before recording
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        if !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                // Start recording
                audioRecorder.record()
                startTimer()
                // Change to the Pause image
                recordButton.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
            } catch {
                print(error)
            }
        } else {
            // Pause recording
            audioRecorder.pause()
            // Change to the Record image
            pauseTimer()
            recordButton.setImage(UIImage(named: "Record"), for: UIControlState.normal)
        }
        stopButton.isEnabled = true
        playButton.isEnabled = false
        
    }
    
    private func configure() {
        // Disable Stop/Play button when application launches
        stopButton.isEnabled = false
        playButton.isEnabled = false
        // Get the document directory. If fails, just skip the rest of the code
        guard let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
            else
        {
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            return
        }
        // Set the default audio file
        let audioFileURL = directoryURL.appendingPathComponent("MyAudioMemo.m4a")
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            // Define the recorder setting
            let recorderSetting: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            // Initiate and prepare the recorder
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: recorderSetting)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.elapsedTimeInSecond += 1
            self.updateTimeLabel()
        })
    }
    func pauseTimer() {
        timer?.invalidate()
    }
    func resetTimer() {
        timer?.invalidate()
        elapsedTimeInSecond = 0
        updateTimeLabel()
    }
    func updateTimeLabel() {
        let seconds = elapsedTimeInSecond % 60
        let minutes = (elapsedTimeInSecond / 60) % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
            
                

}
