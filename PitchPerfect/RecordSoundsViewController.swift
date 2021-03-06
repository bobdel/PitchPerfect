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
      stopRecordingButton.isEnabled = !stopRecordingButton.isEnabled
      recordButton.isEnabled = !recordButton.isEnabled
      recordingLabel.text = isRecording ?  "Recording in Progress" : "Tap to Record"
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
      displaySimpleAlert(title: "Unable to Record.", message: "Something went wrong. Please try again.")
    }
  }
}


// MARK: Simple Modal Alert

extension UIViewController {

  func displaySimpleAlert(title:String, message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction((UIAlertAction(title: "OK", style: .default, handler: nil)))

    self.present(alert, animated: true, completion: nil)

  }
}

