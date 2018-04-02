//
//  Gauge.swift
//  MeterSwift
//
//  Created by 云南省昆明市Mao on 14-10-23.
//  Copyright (c) 2014年 maoy. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

//最大偏转角度
//let MAXOFFSETANGLE : Float = 120.0
//初始化指针偏移量
let POINTEROFFSET : CGFloat = 90.0
//最大显示数值
let MAXVALUE : CGFloat = 100.0
//缺省的表盘尺寸（正方形）
let DEFLUATSIZE : Int =  300

let GAUGE_BG_IMAGE_SIZE:CGFloat = 784
let GAUGE_BG_IMAGE_BORDE_WIDTH:CGFloat = 24

struct GaugeParam{
    var maxNum: CGFloat = MAXVALUE
    var minNum: CGFloat = 0.00

    var maxAngle: CGFloat = 0//MAXOFFSETANGLE
    var minAngle: CGFloat = 360//-MAXOFFSETANGLE
    
    var gaugeValue: CGFloat = 0.00
    var gaugeAngle: CGFloat = 0//-MAXOFFSETANGLE
    var frame: CGRect
    
    var angleperValue: CGFloat{
        get{
            return (self.maxAngle - self.minAngle)/(self.maxNum - self.minNum)
        }
    }
    var scaleNum: CGFloat{
        get{
            return (CGFloat(DEFLUATSIZE)/CGFloat(self.frame.size.width))
        }
    }
    
    init(frame:CGRect){
        self.frame = frame
    }
   
}

class GaugePanel : UIView {
    var context: CGContext!
    var gaugeView: UIImage!
    var pointer: UIView!
    var centerBluePoint:UIView!
    var progressView:RainbowProgressView!
    
    var nameLabel:UILabel!
    var valueLabel:UILabel!
    
    var frameCurr: CGRect!
    var labelArray: NSMutableArray!
    var gv: GaugeParam!
    var maxNum:CGFloat = MAXVALUE{
        didSet{
            self.gv.maxNum = maxNum
        }
    }
    override init(frame: CGRect) {
        self.pointer = UIView()
        self.gaugeView = UIImage(named: "gaugeback.png")
        self.frameCurr = frame
        self.gv = GaugeParam(frame: frame)
        self.gv.maxNum = self.maxNum
        self.centerBluePoint = UIView()
        self.nameLabel = UILabel()
        self.valueLabel = UILabel()
        self.progressView = RainbowProgressView()
        super.init(frame: frame)
        self.setFrameInit(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化绘图框架
    func setFrameInit(frame : CGRect)
    {
        let x = frame.width/2
        let y = frame.height/2
        self.center = CGPoint(x: x, y: y)
        self.backgroundColor = UIColor.clear
        //通过锚点精确定位指针
        pointer.center = self.center
        pointer.layer.bounds = CGRect(x:0, y:0, width:2, height:y*0.75)
        pointer.layer.backgroundColor = UIColor.black.cgColor
        pointer.layer.anchorPoint = CGPoint(x:0.50, y:0.85)
//        pointer.transform = CGAffineTransform(scaleX: CGFloat(gv.scaleNum), y: CGFloat(gv.scaleNum))
        self.addSubview(pointer)
//        self.setTextLabel(labelNum: CELLNUM)
        //经过测试CABaseAnimation是按最短路径不能使用，下同
        pointer.layer.transform = CATransform3DMakeRotation(self.transToRadian(angle: CGFloat(0/*-MAXOFFSETANGLE*/)) , 0, 0, 1)
        
        self.centerBluePoint.center = self.center
        self.centerBluePoint.layer.bounds = CGRect(x:0, y:0, width:16, height:16)
        self.centerBluePoint.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.centerBluePoint.layer.cornerRadius = 8
        self.centerBluePoint.layer.backgroundColor = UIColor.red.cgColor//UIColor.init(red: 0, green: 30/255, blue: 151/255, alpha: 1.0).cgColor
        self.addSubview(self.centerBluePoint)
        
        self.progressView.frame = self.frame
        self.progressView.progressPercent = 0.0
        self.progressView.circleRadius = self.frame.height/2
        self.progressView.circleWeight = self.frame.width*GAUGE_BG_IMAGE_BORDE_WIDTH/GAUGE_BG_IMAGE_SIZE
        self.addSubview(self.progressView)        
        
        self.nameLabel.frame = CGRect(x: x-100, y: y/3, width: 200, height: 70)
        self.nameLabel.textColor = UIColor.init(red: 60/255, green: 106/255, blue: 167/255, alpha: 0.8)
        self.nameLabel.font = UIFont.systemFont(ofSize: 17.0)
        self.nameLabel.textAlignment = .center
        self.nameLabel.text = ""
        
        self.valueLabel.frame = CGRect(x: x-50, y: y+y/6, width: 100, height: 40)
        self.valueLabel.font = UIFont.systemFont(ofSize: 20.0)
        self.valueLabel.textAlignment = .center
        self.valueLabel.text = "0/0"
        self.valueLabel.layer.backgroundColor = UIColor.white.cgColor
        self.valueLabel.layer.cornerRadius = 5
        
        self.addSubview(self.nameLabel)
        self.addSubview(self.valueLabel)
        self.bringSubview(toFront: pointer)
        self.bringSubview(toFront: self.centerBluePoint)
    }
    
    func setTitleName(text:String?){
        self.nameLabel.text = text
    }
    
    func updateValueLabel(value:Int, total:Int){
    
        let astring = "\(value)/\(total)"
        let attrStr = NSMutableAttributedString(string: astring)
        
        let count = "\(value)".count
        attrStr.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.init(red: 255/255, green: 94/255, blue: 19/255, alpha: 1.0)], range: NSMakeRange(0, count))
        
        let count2 = "/\(total)".count
        attrStr.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.init(red: 0/255, green: 149/255, blue: 230/255, alpha: 1.0)], range: NSMakeRange(count, count2))
        self.valueLabel.attributedText = attrStr
    }
    
    //旋转到指定的值
    func setCurrGaugeValue(value: CGFloat,animation: Bool){
        if self.maxNum <= 0{
            print("------maxNum = 0")
            return
        }
        let temp = self.parseToAngle(val: value)
        gv.gaugeValue = CGFloat(value)
        if animation{
            self.pointToAngle(duration: 0.6, angle: temp)
        }else{
            self.pointToAngle(duration: 0.0, angle: temp)
        }
        self.progressView.progressPercent = value/self.maxNum
        self.updateValueLabel(value: Int(value), total: Int(self.maxNum))
    }
    
    //动画的方式旋转
    func pointToAngle(duration: CGFloat,angle: CGFloat)
    {
        let ani: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        let values: NSMutableArray = NSMutableArray()
        let distance: CGFloat = (angle)/10
        var v: CATransform3D
        
        ani.duration = CFTimeInterval(duration)
        ani.autoreverses = false
        ani.fillMode = kCAFillModeForwards;
        ani.isRemovedOnCompletion = false
 
        var i:Int = 0
        for k in 1...10{
            i = k
            v = CATransform3DRotate(CATransform3DIdentity, self.transToRadian(angle: CGFloat(gv.gaugeAngle) + distance*CGFloat(i)), 0, 0, 1)
            values.add(NSValue.init(caTransform3D: v))
        }
        //产生指针抖动效果
        v = CATransform3DRotate(CATransform3DIdentity, self.transToRadian(angle: CGFloat(gv.gaugeAngle) + distance*CGFloat(i)), 0, 0, 1)
        values.add(NSValue.init(caTransform3D: v))
        v = CATransform3DRotate(CATransform3DIdentity, self.transToRadian(angle: CGFloat(gv.gaugeAngle) + distance*CGFloat(i-2)), 0, 0, 1)
        values.add(NSValue.init(caTransform3D: v))
        v = CATransform3DRotate(CATransform3DIdentity, self.transToRadian(angle: CGFloat(gv.gaugeAngle) + distance*CGFloat(i-1)), 0, 0, 1)
        values.add(NSValue(caTransform3D: v))
        ani.values = values as? [Any]
        pointer.layer.add(ani, forKey: "any")
        gv.gaugeAngle = CGFloat(angle)+gv.gaugeAngle
        
    }
    
    //根据半径和角度换算出X
    func parseToX(radius: CGFloat,angle: CGFloat) -> CGFloat{
        let temp = self.transToRadian(angle: angle)
        return radius*cos(temp)
    }
    
    //根据半径和角度换算出Y
    func parseToY(radius: CGFloat,angle: CGFloat) -> CGFloat{
        let temp = self.transToRadian(angle: angle)
        return radius*sin(temp)
    }
    
    //换算成弧度
    func transToRadian(angle:CGFloat) -> CGFloat {
        return angle * CGFloat(Double.pi/180)
    }
    
    //变量值换算成要旋转的角度
    func parseToAngle(val:CGFloat) -> CGFloat{
        //超过范围数据不处理
        if val < CGFloat(gv.minNum) {
            return CGFloat(gv.minNum)
        } else if val > CGFloat(gv.maxNum){
            return CGFloat(gv.maxNum)
        }
        let temp: CGFloat = -(val-CGFloat(gv.gaugeValue))*CGFloat(gv.angleperValue)
        
        return temp;
    }

    
    //已经旋转的角度换算成变量值，此功能未使用，保留
    func parseToValue(angle: CGFloat) ->CGFloat{
        let temp1 = angle/CGFloat(gv.angleperValue)
        let temp2 = CGFloat(gv.maxNum)/2 + temp1
        if temp2 > CGFloat(gv.maxNum){
            return CGFloat(gv.maxNum)
        } else if temp2 < CGFloat(gv.minNum)
        {
            return CGFloat(gv.minNum)
        }
        return temp2
    }
    
    //绘制仪表
    override func draw(_ rect: CGRect) {
        self.context = UIGraphicsGetCurrentContext()
        context.setFillColor((self.backgroundColor?.cgColor)!)
        context.fill(rect)
        self.gaugeView.draw(in: self.bounds)
        context.strokePath()
    }

}
