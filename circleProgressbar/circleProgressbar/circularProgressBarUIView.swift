//
//  circularProgressBarUIView.swift
//  circleProgressBar
//
//  Created by Julian Schenkemeyer on 19/11/2016.
//  Copyright © 2016 Julian Schenkemeyer. All rights reserved.
//

import UIKit

@IBDesignable class circularProgressbarUIView: UIView {
    
    struct Constants {
        let circleDegrees = 360.0
        let minValue = 0.0
        let maxValue = 0.99999999
        var contentView: UIView = UIView()
    }
    
    let constants = Constants()
    var intProgress: Double = 0.0
    
    
    // Progress
    @IBInspectable var progress: Double = 0.0 {
        didSet {
            intProgress = progress
            setNeedsDisplay()
        }
    }
    
    // line width of progressbar
    @IBInspectable var progressBarWidth: Double = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // color of progressbar
    @IBInspectable var progressbarColor: UIColor = UIColor.blue {
        didSet{
            setNeedsDisplay()
        }
    }
    
    // start/end angle
//    @IBInspectable var startAngle: CGFloat = 180.0 {
//        didSet{
//            setNeedsDisplay()
//        }
//    }
    
    var progressView: UIView {
        return UIView()
    }
        
    // Width of Guidelines
    @IBInspectable var guideLineWidth: Double = 10.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var guidelineBorderWidth: Double = 0.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    // Color of Guidelines
    @IBInspectable var guidelineColor: UIColor = UIColor.black {
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var guidelineBackgroundColor: UIColor = UIColor.gray {
        didSet{
            setNeedsDisplay()
        }
    }
    
    // Color of center circle
    @IBInspectable var centerCircleColor: UIColor = UIColor.white {
        didSet{
            setNeedsDisplay()
        }
    }
    
    
    
//    // Bezierpath for the guidelines and progressbar
//    var path: UIBezierPath? {
//        didSet {
//            
//        }
//    }
    
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addSubview(progressView)
    }
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        let innerRect = rect.insetBy(dx: CGFloat(guideLineWidth), dy: CGFloat(guideLineWidth))
        
        intProgress = (intProgress / 1.0) == 0.0 ? constants.minValue : progress
        intProgress = (intProgress / 1.0) == 1.0 ? constants.maxValue : progress
        intProgress = (-270.0 + ((1.0 - intProgress) * 360.0))
        
        let context = UIGraphicsGetCurrentContext()
        let circlePath = UIBezierPath(ovalIn: CGRect(x: innerRect.minX, y: innerRect.minY, width: innerRect.width, height: innerRect.height))
        
        // Draw guideline circle
        drawGuideline(innerRect: innerRect, circlePath: circlePath)
        
        // Draw progressbar
        drawProgress(innerRect: innerRect, circlePath: circlePath, context: context)
        
        // Draw centercircle
        drawCenterCircle(innerRect: innerRect)
        
    }
 
    fileprivate func drawGuideline(innerRect: CGRect, circlePath: UIBezierPath) {
        guidelineBackgroundColor.setFill()
        circlePath.fill()
        
        if guidelineBorderWidth > 0 {
            circlePath.lineWidth = CGFloat(guidelineBorderWidth)
            guidelineColor.setStroke()
            circlePath.stroke()
        }
    }
    
    
    fileprivate func drawCenterCircle(innerRect: CGRect) {
        let centerPath = UIBezierPath(ovalIn: CGRect(x: innerRect.minX + CGFloat(guideLineWidth), y: innerRect.minY + CGFloat(guideLineWidth), width: innerRect.width - (2 * CGFloat(guideLineWidth)), height: innerRect.height - (2 * CGFloat(guideLineWidth))))
        centerCircleColor.setFill()
        centerPath.fill()
        
//        let layer = CAShapeLayer()
//        layer.path = centerPath.cgPath
//        progressView.layer.mask = layer
        
        if guidelineBorderWidth > 0 {
            centerPath.lineWidth = CGFloat(guidelineBorderWidth)
            guidelineColor.setStroke()
            centerPath.stroke()
        }
    }
    
    fileprivate func drawProgress(innerRect:CGRect, circlePath: UIBezierPath, context: CGContext?) {
        let progressPath = UIBezierPath()
        let progressRect: CGRect = CGRect(x: innerRect.minX, y: innerRect.minY, width: innerRect.width, height: innerRect.height)
        let center = CGPoint(x: progressRect.midX, y: progressRect.midY)
        let radius = (progressRect.width - CGFloat(guidelineBorderWidth)) / 2.0
        
        let startAngle = CGFloat(270.0) * CGFloat(M_PI) / 180.0
//        startAngle = startAngle * CGFloat(M_PI) / 180.0
        let endAngle: CGFloat = CGFloat(-intProgress) * CGFloat(M_PI) / 180.0
        
        progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        progressPath.addLine(to: CGPoint(x: progressRect.midX, y: progressRect.midY))
        progressPath.close()
        
        context?.saveGState()
        progressPath.addClip()
        
        progressbarColor.setFill()
        circlePath.fill()
        
        context?.restoreGState()
    }
    
//    func setProgress(newProgress: Double, animated: Bool) {
//        if animated {
//            
//        }
//    }
}
