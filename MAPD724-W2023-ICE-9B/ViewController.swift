//
//  ViewController.swift
//  MAPD724-W2023-ICE-9B
//
//  Created by Raziel Hernandez on 2023-03-31.
//

import UIKit
import Vision
import Photos
import AVKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var pictureChosen: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func getImage_pressed(_ sender: UIButton) {
        getPhoto()
        
    }
    
    func getPhoto() {
        print("get photo")
        /*let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true, completion: nil)*/
        let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        let picker = UIImagePickerController()
        picker.mediaTypes = mediaTypes
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let gotImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            pictureChosen.image = gotImage
            analyzeImage(image: gotImage)
            identifyFacesWithLandmarks(image: gotImage)
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerController 2 ")
        picker.dismiss(animated: true, completion:nil)
    }
    
    func identifyFacesWithLandmarks(image: UIImage)
    {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [ : ])
        let request =
        VNDetectFaceLandmarksRequest(completionHandler: handleFaceLandmarksRecognition)
        try! handler.perform([request])
    }
    
    func handleFaceLandmarksRecognition(request: VNRequest, error: Error?)
    {
        guard let foundFaces = request.results as? [VNFaceObservation] else {
            fatalError ("Problem loading picture to examine faces")
        }

        for faceRectangle in foundFaces {
            let landmarkRegions: [VNFaceLandmarkRegion2D] = []
            drawImage(source: pictureChosen.image!, boundary: faceRectangle.boundingBox, faceLandmarkRegions: landmarkRegions)
        }
    }
    
    func drawImage(source: UIImage, boundary: CGRect, faceLandmarkRegions: [VNFaceLandmarkRegion2D]) {
         UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
         let context = UIGraphicsGetCurrentContext()!
         context.translateBy(x: 0, y: source.size.height)
         context.scaleBy(x: 1.0, y: -1.0)
         context.setLineJoin(.round)
         context.setLineCap(.round)
         context.setShouldAntialias(true)
         context.setAllowsAntialiasing(true)
         let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
         context.draw(source.cgImage!, in: rect)
         //draw rectangles around faces
         let fillColor = UIColor.systemGreen
         fillColor.setStroke()
         context.setLineWidth(10.0)
         let rectangleWidth = source.size.width * boundary.size.width
         let rectangleHeight = source.size.height * boundary.size.height

         context.addRect(CGRect(
         x: boundary.origin.x * source.size.width,
         y:boundary.origin.y * source.size.height,
         width: rectangleWidth,
         height: rectangleHeight))

         context.drawPath(using: CGPathDrawingMode.stroke)
         let modifiedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
         UIGraphicsEndImageContext()
         pictureChosen.image = modifiedImage
    }
    
    func analyzeImage(image: UIImage)
    {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [ : ])
        messageLabel.text = "Analyzing picture..."
        let request = VNDetectFaceRectanglesRequest(completionHandler: handleFaceRecognition)
        try! handler.perform([request])
    }
    
    func handleFaceRecognition(request: VNRequest, error: Error?) {
        guard let foundFaces = request.results as? [VNFaceObservation] else {
            fatalError ("Can't find a face in the picture")
        }
        messageLabel.text = "Found \(foundFaces.count) faces in the picture"
    }
}

