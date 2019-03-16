//
//  ViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import AVFoundation

class TwentyViewController: UIViewController {
    @IBOutlet weak var newGameImageView: UIImageView!
    @IBOutlet weak var statisticsImageView: UIImageView!

    private let imageAlpha: CGFloat = 0.40
    private var viewHeightDividedByTwo: CGFloat = 0
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        setImagesToOriginalAlpha()
        
        // Ask for permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
            
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        }
    }
    
    func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(for: .video)
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else {
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        let photoOutput = AVCapturePhotoOutput()
        
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
    }

    override func viewDidLayoutSubviews() {
        viewHeightDividedByTwo = view.bounds.height / 2
    }

    override func viewDidDisappear(_ animated: Bool) {
        setImagesToOriginalAlpha()
    }

    @IBAction func segueToNewGameVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.newGameVCSegue, sender: nil)
    }

    @IBAction func segueToStatisticsVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.statisticsVCSegue, sender: nil)

    }

    private func setImagesToOriginalAlpha() {
        newGameImageView.alpha = imageAlpha
        statisticsImageView.alpha = imageAlpha
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsVC = segue.destination as? StatisticsViewController {
            statsVC.statsOrdering = StatsOrdering(rawValue: defaults.integer(forKey: UserDefaults.savedStatsOrderingKey))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstTouch = touches.first

        if let firstTouchLocation = firstTouch?.location(in: view) {
            if firstTouchLocation.y < viewHeightDividedByTwo {
                newGameImageView.alpha = 0.8
            } else {
                statisticsImageView.alpha = 0.8
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setImagesToOriginalAlpha()
    }
}
