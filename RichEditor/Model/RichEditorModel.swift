//
//  RichEditorModel.swift
//
//  Created by 孟冰川 on 2017/12/12.
//

import Foundation

enum RichEditorType {
    case md
    case rte
    var string: String {
        switch self {
        case .md:
            return "md"
        case .rte:
            return "rte"
        }
    }
    static func instance(type: String?) -> RichEditorType? {
        guard let type = type else {return nil}
        switch type {
        case "MD":
            return .md
        case "RTE":
            return .rte
        default:
            return nil
        }
    }
}

class RichEditorData {
    
    var keyBoard = true
    
    var bold = false
    var italic = false
    var underline = false
    
    var size: String?
    var color: String?
    
    var align = false
    var align_center = false
    var align_right = false
    var align_justify = false //暂时不用
    
    var list_bullet = false
    var list_ordered = false
    
    var linkDisabled = false
    
    var table: String? //暂时不用
    
    init(dic: [String: Any]) {
        if let bold = dic["bold"] as? Bool {
            self.bold = bold
        }
        if let italic = dic["italic"] as? Bool {
            self.italic = italic
        }
        if let underline = dic["underline"] as? Bool {
            self.underline = underline
        }
        
        if let size = dic["header"] as? String {
            self.size = size
        }
        if let color = dic["color"] as? String {
            self.color = color
        }
        if let align = dic["align"] as? String {
            switch align {
            case "center":
                self.align_center = true
            case "right":
                self.align_right = true
            case "left":
                self.align = true
            default:
                ()
            }
        }
        if let list_ordered = dic["list_ordered"] as? Bool {
            self.list_ordered = list_ordered
        }
        if let list_bullet = dic["list_bullet"] as? Bool {
            self.list_bullet = list_bullet
        }
        
        if let linkDisabled = dic["linkDisabled"] as? Bool {
            self.linkDisabled = linkDisabled
        }
    }
}
