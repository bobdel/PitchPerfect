//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Robert DeLaurentis on 1/25/18.
//  Copyright © 2018 Robert DeLaurentis. All rights reserved.
//

import UIKit
import AVFoundation
import os.log             // use the new os logging in iOS 11.

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

  
  // MARK: Properties

  var audioRecorder: AVAudioRecorder!

  var isRecording = false {
    didSet {
      if isRecording == true {
        recordingLabel.text = "Recording in Progress"
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
      } else {
        recordingLabel.text = "Tap to Record"
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
      }
    }
  }

  @IBOutlet weak var recordingLabel: UILabel!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var stopRecordingButton: UIButton!


  // MARK: ViewController Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    isRecording = false
  }


  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "stopRecording" {
      let playSoundsVC = segue.destination as! PlaySoundsViewController
      let recordedAudioURL = sender as! URL
      playSoundsVC.recordedAudioURL = recordedAudioURL

    }
  }


  // MARK: Actions

  @IBAction func recordAudio(_ sender: UIButton) {

    isRecording = true

    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
    let recordingName = "recordedVoice.wav"
    let pathArray = [dirPath, recordingName]
    let filePath = URL(string: pathArray.joined(separator: "/"))
    print(filePath!)

    let session = AVAudioSession.sharedInstance()
    try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)

    try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
    audioRecorder.delegate = self
    audioRecorder.isMeteringEnabled = true
    audioRecorder.prepareToRecord()
    audioRecorder.record()
  }

  @IBAction func stopRecording(_ sender: UIButton) {
    isRecording = false
    audioRecorder.stop()
    let audioSession = AVAudioSession.sharedInstance()
    try! audioSession.setActive(false)

  }


  // MARK: AVAudioRecorderDelegate Methods

  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    if flag == true {
      performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
    } else {
      os_log("Recording was not successful")
    }
  }

}

