//
//  ViewController.swift
//  SeeFood
//
//  Created by Jeremy Van on 5/15/19.
//  Copyright © 2019 Jeremy Van. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Setting image picker delegate and camera source type
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            // Convert to CIImage and pass into detect request
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detect(image: ciImage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        // Create model to classify image, VNCoreMLModel comes from Vision framework
        // allows us to perform image analysis request, that uses our CoreML model to process images
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("CoreML Model failed to load")
        }
        // Similar to making api query requests and processing JSON data
        // VNClassificationObservation is a class that holds ClassificationObservations after model has been processed
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
//            print(results)
            if let firstResult = results.first {
                // Results have two properties:
                // identifier: a string
                // confidence: num between 0-1
//                print(firstResult.identifier, firstResult.confidence)
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }

    @IBAction func cameraTapped(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
}

