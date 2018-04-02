//
//  ViewController.swift
//  SJGauge
//
//  Created by songjian on 2018/3/29.
//  Copyright © 2018年 songjian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet var containView: UIView!
    var panel : GaugePanel!
    
    @IBAction func sliderChange(sender: UISlider) {
        //设置显示值
        panel.setCurrGaugeValue(value: CGFloat(sender.value), animation: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化绘制范围参数
        let frame = CGRect(x:100, y:300, width:300, height:300)
        //初始化控件
        panel = GaugePanel(frame: frame)
        self.slider.maximumValue = Float(MAXVALUE)
        self.slider.minimumValue = 0
        containView.addSubview(panel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


