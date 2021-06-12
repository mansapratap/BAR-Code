//
//  ViewController.swift
//  BAR Code
//
//  Created by Mansa Pratap Singh on 12/06/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    var filter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        imageWidth.constant = view.bounds.size.width * 0.6
        generateButton.layer.cornerRadius = 8
        imageView.layer.cornerRadius = 8
        segment.layer.cornerRadius = 8
        imageView.layer.borderWidth = 2
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
    }
    
    @IBAction func generateButton(_ sender: UIButton) {
        updateUI()
    }
    
    @objc func shareButtonPressed() {
        guard let image = imageView.image else { return }
        guard let safeImage = resizedImage(image: image)?.jpegData(compressionQuality: 1.0) else { return  }
        let vc = UIActivityViewController(activityItems: [safeImage], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func updateUI() {
        if let text = textField.text, text != "" {
            if segment.selectedSegmentIndex == 0 {
                imageView.image = qrCodeGenerator(text: text)
            } else {
                imageView.image = barCodeGenerator(text: text)
            }
        }
    }
    
    func qrCodeGenerator(text: String) -> UIImage {
        var image = UIImage()
        let data = Data(text.utf8)
        filter = CIFilter(name: "CIQRCodeGenerator")
        filter.setValue(data, forKey: "inputMessage")
        if let ciImage = filter.outputImage {
            image = UIImage(ciImage: ciImage)
        }
        return image
    }
    
    func barCodeGenerator(text: String) -> UIImage {
        var image = UIImage()
        let data = Data(text.utf8)
        filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter.setValue(data, forKey: "inputMessage")
        if let ciImage = filter.outputImage {
            image = UIImage(ciImage: ciImage)
        }
        return image
    }
    
    func resizedImage(image: UIImage) -> UIImage? {
        let scaleFactor = UIScreen.main.scale
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        let size = imageView.bounds.size.applying(scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateUI()
        return textField.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.endEditing(true)
    }
}
