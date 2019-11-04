//
//  ViewController.swift
//  AnnotatedImageView
//
//  Created by Gene Backlin on 8/29/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var annotateImageViewStackView: UIStackView!
    @IBOutlet weak var attributesStackView: UIStackView!
    @IBOutlet weak var brushAttributesStackView: UIStackView!
    @IBOutlet weak var textAttributesStackView: UIStackView!
    @IBOutlet weak var textEntryStackView: UIStackView!
    
    @IBOutlet weak var brushSizeColorSwitch: UISwitch!
    @IBOutlet weak var brushSizeTextEntry: UITextField!
    @IBOutlet weak var fontSizeTextField: UITextField!
    @IBOutlet weak var textBackgroundColorSwitch: UISwitch!
    
    @IBOutlet weak var blueColorLabel: UILabel!
    @IBOutlet weak var blueColorSlider: UISlider!
    @IBOutlet weak var greenColorSlider: UISlider!
    @IBOutlet weak var greenColorLabel: UILabel!
    @IBOutlet weak var redColorLabel: UILabel!
    @IBOutlet weak var redColorSlider: UISlider!
    
    @IBOutlet weak var thumbImageView: AnnotatedImageView!
    @IBOutlet weak var imageView: AnnotatedImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var textEntryField: UITextField!
    
    var picker: UIImagePickerController = UIImagePickerController()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        picker.delegate = self
        colorView.backgroundColor = getColorFromSliderValues()

        hideStackViews(isHidden: true)
        initializeColorView()
    }
    
    // MARK: - Utility
    
    func hideStackViews(isHidden: Bool) {
        annotateImageViewStackView.isHidden = isHidden
        textEntryStackView.isHidden = isHidden
        attributesStackView.isHidden = isHidden
        textAttributesStackView.isHidden = isHidden
        brushAttributesStackView.isHidden = isHidden
    }
    
    func getColorFromSliderValues() -> UIColor {
        let red = CGFloat(redColorSlider.value / 255.0)
        let green = CGFloat(greenColorSlider.value / 255.0)
        let blue = CGFloat(blueColorSlider.value / 255.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func initializeColorView() {
        colorView.layer.cornerRadius = 5
        colorView.layer.masksToBounds = true
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1
    }
}

// MARK: - @IBAction methods

extension ViewController {
    
    // MARK: - Brush Overlay
    
    @IBAction func updateBrushAttributes(_ sender: UIButton) {
        var size = 0.0
        
        if let brushSize: Double = Double(brushSizeTextEntry.text!) {
            size = brushSize
        } else {
            size = 5.0
        }
        
        if brushSizeColorSwitch.isOn {
            imageView.updateBrushAttributes(brushSize: nil, color: getColorFromSliderValues())
        } else {
            imageView.updateBrushAttributes(brushSize: CGFloat(size), color: nil)
        }
        brushSizeTextEntry.resignFirstResponder()
    }
    
    @IBAction func updateTextFont(_ sender: UIButton) {
        var size = 0.0
        
        if let fontSize: Double = Double(fontSizeTextField.text!) {
            size = fontSize
        } else {
            size = 36.0
        }
        
        if textBackgroundColorSwitch.isOn {
            imageView.updateTextAttributes(fontSize: CGFloat(size), textColor: getColorFromSliderValues(), backgroundColor: nil)
        } else {
            imageView.updateTextAttributes(fontSize: CGFloat(size), textColor: nil, backgroundColor: getColorFromSliderValues())
        }
        fontSizeTextField.resignFirstResponder()
    }
    
    // MARK: - Text Label Overlay
    
    @IBAction func addText(_ sender: UIButton) {
        if let text = textEntryField.text {
            var size = 0.0
            
            if let fontSize: Double = Double(fontSizeTextField.text!) {
                size = fontSize
            } else {
                size = 36.0
            }

            textEntryField.resignFirstResponder()
            
            imageView.addText(text: text, font: UIFont(name: "HelveticaNeue", size: CGFloat(size))!, color: getColorFromSliderValues(), backgroundColor: UIColor.clear)
        }
    }
    
    // MARK: - Image Editable Status
    
    @IBAction func setImageAnnotation(_ sender: UISwitch) {
        imageView.isUserInteractionEnabled = sender.isOn
    }
    
    // MARK: - Annotation Housekeeping
    
    @IBAction func removeAllAnnotations(_ sender: UIBarButtonItem) {
        imageView.removeAll()
    }
    @IBAction func undo(_ sender: UIBarButtonItem) {
        imageView.undoLast()
    }
    
    // MARK: - Image Selection
    
    @IBAction func promptForImageSource(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Source", message: "Select where you want to get the image from.", preferredStyle: .actionSheet)
        let cameraButtonAction = UIAlertAction(title: "Camera", style: .default) {[weak self] (action) in
            debugPrint("Camera")
            alert.dismiss(animated: true, completion: nil)
            
            if(UIImagePickerController .isSourceTypeAvailable(.camera)){
                self!.picker.sourceType = .camera
                self!.present(self!.picker, animated: true, completion: nil)
            } else {
                debugPrint("Do not have permission for Camera usage.")
            }
        }
        let libraryButtonAction = UIAlertAction(title: "Library", style: .default) {[weak self] (action) in
            debugPrint("Library")
            alert.dismiss(animated: true, completion: nil)
            
            self!.picker.sourceType = .photoLibrary
            self!.present(self!.picker, animated: true, completion: nil)
        }
        let cancelButtonAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            debugPrint("Cancel")
        }
        
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            alert.addAction(cameraButtonAction)
        }
        alert.addAction(libraryButtonAction)
        alert.addAction(cancelButtonAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Color Selection
    
    @IBAction func updateColorValue(_ sender: UISlider) {
        let colorValue = Int(sender.value)
        switch sender.tag {
        case 0:
            redColorLabel.text = String(colorValue)
            break
        case 1:
            greenColorLabel.text = String(colorValue)
            break
        case 2:
            blueColorLabel.text = String(colorValue)
            break
        default:
            break
        }
        
        colorView.backgroundColor = getColorFromSliderValues()
    }
    
    // MARK: - Image Overlay Retrival
    
    @IBAction func getSnapshot(_ sender: UIBarButtonItem) {
        thumbImageView.image = imageView.snapshot()
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        debugPrint(info)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] {
            imageView.image = pickedImage as? UIImage
            hideStackViews(isHidden: false)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate

extension ViewController: UINavigationControllerDelegate {
    
}
