//
//  AnnotatedImageView.swift
//  AnnotatedImageView
//
//  Created by Gene Backlin on 8/29/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit

@IBDesignable class AnnotatedImageView: UIImageView {
    @IBInspectable var alphaValue: CGFloat = 0.0
    @IBInspectable var brushWidth: CGFloat = 5.0
    @IBInspectable var opacity: CGFloat = 1.0
    @IBInspectable var brushColor : UIColor {
        set {
            lineColor = newValue
        }
        get {
            return lineColor
        }
    }
    
    var lastPoint: CGPoint = CGPoint.zero
    var lineColor: UIColor = UIColor.black
    var tempImageView: UIImageView?
    var tempTextImageView: UIImageView?
    var subViewHasFocus = false
    var currentTextImageLabel: UILabel?
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
}

// MARK: - Touch handling

extension AnnotatedImageView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        lastPoint = touch.location(in: self)
        
        if subViewHasFocus == false {
            currentTextImageLabel = nil
            tempImageView = UIImageView()
            tempImageView!.frame.size = self.frame.size
            tempImageView!.isUserInteractionEnabled = true
            addSubview(tempImageView!)
        } else {
            if let touchView = touch.view {
                if touch.tapCount > 2 {
                    touchView.removeFromSuperview()
                    currentTextImageLabel = nil
                } else {
                    if touch.tapCount == 2 {
                        currentTextImageLabel?.backgroundColor = UIColor.clear
                    }
                    currentTextImageLabel = touchView as? UILabel
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let currentPoint = touch.location(in: self)
        
        if subViewHasFocus == false {
            drawLine(from: lastPoint, to: currentPoint)
        } else {
            touch.view?.center = lastPoint
        }
        
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // draw a single point
        if subViewHasFocus == false {
            drawLine(from: lastPoint, to: lastPoint)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // draw a single point
        if subViewHasFocus == false {
            drawLine(from: lastPoint, to: lastPoint)
        }
    }
    
}

// MARK: - View Focusing

extension AnnotatedImageView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        subViewHasFocus = false
        for subView in subviews {
            for subSubView in subView.subviews {
                if let viewWasHit = subSubView.hitTest(convert(point, to: subSubView), with: event) {
                    subViewHasFocus = true
                    tempTextImageView = subSubView as? UIImageView
                    return viewWasHit
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
}

// MARK: - Drawing methods

extension AnnotatedImageView {
    
    func drawLine(from: CGPoint, to: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView!.image?.draw(in: self.bounds)
        
        context.move(to: from)
        context.addLine(to: to)
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(brushColor.cgColor)
        
        context.strokePath()
        
        tempImageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView!.alpha = opacity
        
        UIGraphicsEndImageContext()
    }
    
    
    func addText(text: String) {
        if isUserInteractionEnabled {
            addText(text: text, font: UIFont(name: "HelveticaNeue", size: 36.0)!, color: UIColor.black, backgroundColor: UIColor.white)
        }
    }
    
    func addText(text: String, font: UIFont, color: UIColor, backgroundColor: UIColor) {
        if isUserInteractionEnabled {
            let label = UILabel()
            
            label.text = text
            label.font = font
            label.textColor = color
            label.frame = bounds
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.textAlignment = .center
            label.sizeToFit()
            label.backgroundColor = backgroundColor
            label.center = CGPoint(x: frame.size.width  / 2, y: frame.size.height / 2)
            label.isUserInteractionEnabled = true
            
            tempTextImageView = UIImageView()
            tempTextImageView!.frame.size = label.frame.size
            tempTextImageView!.isUserInteractionEnabled = true
            
            tempTextImageView!.addSubview(label)
            currentTextImageLabel = label
            
            addSubview(tempTextImageView!)
        }
    }
    
}

// MARK: - Utility

extension AnnotatedImageView {
    
    func undoLast() {
        if let lastSubView = subviews.last {
            lastSubView.removeFromSuperview()
        }
    }
    
    func removeAll() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContext(self.frame.size)
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let currentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return currentImage
    }
    
    func updateTextAttributes(fontSize: CGFloat?, textColor: UIColor?, backgroundColor: UIColor?) {
        if let label = currentTextImageLabel {
            if fontSize != nil {
                let x = label.frame.origin.x
                let y = label.frame.origin.y
                label.frame = bounds
                label.frame.origin.x = x
                label.frame.origin.y = y
                label.font = label.font.withSize(fontSize!)
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                label.textAlignment = .center
                label.sizeToFit()
                //label.center = CGPoint(x: frame.size.width  / 2, y: frame.size.height / 2)
            }
            if textColor != nil {
                label.textColor = textColor
            }
            if backgroundColor != nil {
                label.backgroundColor = backgroundColor
            }
        }
    }
    
    func updateBrushAttributes(brushSize: CGFloat?, color: UIColor?) {
        if brushSize != nil {
            brushWidth = brushSize!
        }
        if color != nil {
            brushColor = color!
        }
    }
    
}

