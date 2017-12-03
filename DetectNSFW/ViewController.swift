//
//  ViewController.swift
//  DetectNSFW
//
//  Created by WaiLynnZaw on 12/3/17.
//  Copyright © 2017 wailynnzaw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let model = nsfw()
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        detectPhoto(image: UIImage(named: "placeholder")!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Detect NSFW"
    }
}

extension ViewController {

    @IBAction func pickImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }

    func detectPhoto(image: UIImage) {
        answerLabel.text = "predicting..."
        let buffer = image.buffer()!
        guard let output = try? model.prediction(data: buffer) else {
            fatalError("Unexpected runtime error")
        }
        let probability = output.prob[1].doubleValue
        let percent = String(format: "%.4f", probability * 100)
        if probability > 0.8 {
            answerLabel.backgroundColor = UIColor.red
            answerLabel.text = "Definitely Not Safe with \(percent) %"
        } else if probability < 0.2 {
            answerLabel.backgroundColor = UIColor.green
            answerLabel.text = "Definitely Safe with \(percent) %"
        } else {
            answerLabel.backgroundColor = UIColor.clear
            answerLabel.text = "Nsfw scores with \(percent) %"
        }



    }
}
extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Can not load image from Photos")
        }
        photo.image = image
        detectPhoto(image: image)
    }
}


// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

extension UIImage {
    func buffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil

        let width = 224
        let height = 224

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue:0))

        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bitmapContext = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorspace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!

        bitmapContext.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))

        return pixelBuffer
    }
}
