//
//  RichEditorSwitch.swift
//
//  Created by 孟冰川 on 2017/12/12.
//

import UIKit

protocol RichEditorSwitchDelegate: class {
    
    func statusChanged(status: RichEditorType)
}

class RichEditorSwitch: UIView {
    
    let slider = UIView()
    let rte = UILabel()
    let md = UILabel()
    
    var status = RichEditorType.rte {
        didSet {
            processStatusChange()
        }
    }
    
    weak var delegate: RichEditorSwitchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(slider)
        addSubview(rte)
        addSubview(md)
        rte.text = "RTF"
        md.text = "M ↓"
        rte.font = UIFont.systemFont(ofSize: 12)
        md.font = UIFont.systemFont(ofSize: 12)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap)))
        backgroundColor = UIColor(hex: 0xf4f4f4)
        slider.backgroundColor = UIColor.white
        fontONStatus()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rte.sizeToFit()
        md.sizeToFit()
        rte.center = CGPoint(x: width/4, y: height/2)
        md.center = CGPoint(x: width*3/4, y: height/2)
        frameOnStatus()
        slider.layer.cornerRadius = height/2
        layer.cornerRadius = height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func processStatusChange() {
        fontONStatus()
        frameOnStatus()
    }
    
    func fontONStatus() {
        switch status {
        case .md:
            rte.textColor = UIColor(hex: 0x999999)
            md.textColor = UIColor(hex: 0x333333)
        case .rte:
            rte.textColor = UIColor(hex: 0x333333)
            md.textColor = UIColor(hex: 0x999999)
        }
    }
    func frameOnStatus() {
        switch status {
        case .md:
            slider.frame = CGRect(x: width/2, y: 1, width: width/2 - 1, height: height - 2)
        case .rte:
            slider.frame = CGRect(x: 1, y: 1, width: width/2 - 1, height: height - 2)
        }
    }
    
    @objc func tap() {
        switch status {
        case .md:
            self.status = .rte
        case .rte:
            self.status = .md
        }
        UIView.animate(withDuration: 0.3) {
            self.processStatusChange()
        }
        delegate?.statusChanged(status: status)
    }
}
