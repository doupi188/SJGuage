//
//  RainbowProgressView.swift
//  MeterSwift
//
//  Created by songjian on 2018/3/21.
//  Copyright © 2018年 maoy. All rights reserved.
//

import UIKit

class RainbowProgressView: UIView {
    var progressColor: UIColor = UIColor.init(red: 255/255, green: 94/255, blue: 19/255, alpha: 1.0)
    
    //进度条半径
    var circleRadius:CGFloat = 70
    
    //进度0～1
    var progressPercent:CGFloat = 0.75{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    //进度条宽度
    var circleWeight:CGFloat = 16
    
    private var layerArray = Array<CALayer>()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    // 绘制
    override func draw(_ rect: CGRect) {
        self.addCirle()
    }
    
    //添加环形进度
    func addCirle() {
        let X = self.bounds.midX
        let Y = self.bounds.midY
        
        // 进度条圆弧
        let barPath = UIBezierPath(arcCenter: CGPoint(x: X, y: Y), radius: circleRadius-circleWeight/2,
                                   startAngle: -CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi*1.5),
                                   clockwise: true).cgPath
        self.addOval(lineWidth: circleWeight, path: barPath, strokeStart: 0, strokeEnd: progressPercent,
                     strokeColor: progressColor, fillColor: UIColor.clear,
                     shadowRadius: 0, shadowOpacity: 0, shadowOffsset: CGSize.zero)
    }
    
    //添加圆弧
    func addOval(lineWidth: CGFloat, path: CGPath, strokeStart: CGFloat,
                 strokeEnd: CGFloat, strokeColor: UIColor, fillColor: UIColor,
                 shadowRadius: CGFloat, shadowOpacity: Float, shadowOffsset: CGSize) {
       
        for layer in self.layerArray{
            layer.removeFromSuperlayer()
        }
        self.layerArray.removeAll()
        
        let layer = CALayer()
        layer.backgroundColor = fillColor.cgColor
        layer.frame = self.frame
        
        let arc = CAShapeLayer()
        arc.lineWidth = lineWidth
        arc.path = path
        arc.strokeStart = strokeStart
        arc.strokeEnd = strokeEnd
        arc.strokeColor = strokeColor.cgColor
        arc.fillColor = UIColor.clear.cgColor
        arc.shadowColor = fillColor.cgColor//UIColor.black.cgColor
        arc.shadowRadius = shadowRadius
        arc.shadowOpacity = 0.5
        arc.shadowOffset = shadowOffsset
        arc.lineCap = kCALineCapRound
        arc.lineDashPhase = 0.8
        
        let color1 = UIColor.init(red: 252/255, green: 219/255, blue: 141/255, alpha: 1.0).cgColor
        let color2 = UIColor.init(red: 255/255, green: 143/255, blue: 44/255, alpha: 1.0).cgColor
        let color3 = UIColor.init(red: 255/255, green: 94/255, blue: 19/255, alpha: 1.0).cgColor
        let colors:[CGColor] = [color1, color2, color3]

        let gradientLayer = CAGradientLayer()
        gradientLayer.shadowPath = path
        gradientLayer.frame = self.frame
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = colors

        layer.addSublayer(gradientLayer)
        layer.mask = arc

        self.layerArray.append(layer)
        self.layer.addSublayer(layer)
//        self.layer.addSublayer(arc)
//        self.layerArray.append(arc)
    }

}
