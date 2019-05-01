//
//  RichEditAction.swift
//
//  Created by 孟冰川 on 2017/12/10.
//

import UIKit

enum RichEditAction {
    case KeyBoard(Bool)
    case font(Bool)
    case list(Bool)
    case numberList(Bool)
    case alignLeading(Bool)
    case alignCenter(Bool)
    case alignTrailing(Bool)
    case link(Bool)
    
    func image() -> UIImage? {
        var imageName = ""
        switch self {
        case .KeyBoard:
            imageName = "icon_keyboard"
        case .font:
            imageName = "icon_chars"
        case .list:
            imageName = "icon_rank"
        case .numberList:
            imageName = "icon_sort"
        case .alignLeading:
            imageName = "icon_left"
        case .alignCenter:
            imageName = "icon_center"
        case .alignTrailing:
            imageName = "icon_right"
        case .link:
            imageName = "icon_link"
        }
        return isSelected ? UIImage(named: "\(imageName)_click") : UIImage(named: imageName)
    }
    
    var isSelected: Bool {
        switch self {
        case .KeyBoard(let selected):
            return selected
        case .font(let selected):
            return selected
        case .list(let selected):
            return selected
        case .numberList(let selected):
            return selected
        case .alignLeading(let selected):
            return selected
        case .alignCenter(let selected):
            return selected
        case .alignTrailing(let selected):
            return selected
        case .link(let selected):
            return selected
        }
    }
}
func !=(lhs: RichEditAction,rhs: RichEditAction) -> Bool {
    switch (lhs,rhs) {
    case (.KeyBoard,.KeyBoard),(.font,.font),(.list,.list),(.numberList,.numberList),(.alignLeading,.alignLeading),(.alignCenter,.alignCenter),(.alignTrailing,.alignTrailing),(.link,.link):
        return false
    default:
        return true
    }
}
func ==(lhs: RichEditAction,rhs: RichEditAction) -> Bool {
    switch (lhs,rhs) {
    case (.KeyBoard,.KeyBoard),(.font,.font),(.list,.list),(.numberList,.numberList),(.alignLeading,.alignLeading),(.alignCenter,.alignCenter),(.alignTrailing,.alignTrailing),(.link,.link):
        return true
    default:
        return false
    }
}
