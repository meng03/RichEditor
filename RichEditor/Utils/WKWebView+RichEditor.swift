//
//  WKWebView+RichEditor.swift
//
//  Created by 孟冰川 on 2017/12/11.
//

import UIKit
import WebKit

fileprivate var wkContentSubClassName = "wkContentSubClass"
fileprivate var WKWebViewCustomAccessoryViewKey: UInt8 = 0
fileprivate var wkContentSubClass: AnyClass?
typealias oldClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Any) -> Void
typealias newClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool,Bool, Bool, Any?) -> Void
extension WKWebView {
    
    var customAccessoryView: Any? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewCustomAccessoryViewKey)
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewCustomAccessoryViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            replaceWkWebViewContentClass()
            if let subClass = wkContentSubClass,let wkContentView = contentView() {
                //用我们构建的wkContentView子类，替换WKWebview中的wkContentView
                object_setClass(wkContentView, subClass)
            }
        }
    }
    
    @objc var returnCustomAccessoryView: Any? {
        if let wkwebView = self.superview?.superview as? WKWebView {
            return wkwebView.customAccessoryView
        }
        return nil
    }
    
    func contentView() -> UIView? {
        for view in self.scrollView.subviews {
            if type(of: view).description().hasPrefix("WKContent") {
                return view
            }
        }
        return nil
    }
    
    
    /// 创建一个WKCOntentView的子类，
    ///给这个子类的inputAccessoryView的实现替换成我们的returnCustomAccessoryView
    func replaceWkWebViewContentClass() {
        if let wkContent = contentView(),wkContentSubClass == nil {
            let wkContentClass = type(of: wkContent)
            if let subClass = objc_allocateClassPair(wkContentClass, wkContentSubClassName.cString(using: String.Encoding.ascii)!, 0) {
                let customImp = self.method(for: #selector(getter: returnCustomAccessoryView))
                let customMethod = class_getInstanceMethod(WKWebView.self, #selector(getter: returnCustomAccessoryView))
                let selector = #selector(getter: inputAccessoryView)
                class_addMethod(subClass, selector, customImp!, method_getTypeEncoding(customMethod!))
                objc_registerClassPair(subClass)
                wkContentSubClass = subClass
            }else {
                print("创建webView content的子类失败")
            }
        }
    }
    //TODO: -可能无法通过appstore审核
    func setKeyboardRequiresUserInteraction( _ value: Bool) {
        var sel: Selector
        if #available(iOS 12.2, *) {
            sel = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        }else if #available(iOS 11.3, *) {
            sel = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        }else {
            sel = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
        }
        
        let WKContentView: AnyClass = NSClassFromString("WKContentView")!
        guard let method = class_getInstanceMethod(WKContentView, sel) else { return }
        let originalImp: IMP = method_getImplementation(method)
        if #available(iOS 11.3, *) {
            let original: newClosureType = unsafeBitCast(originalImp, to: newClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool,Bool, Any?) -> Void = {(me, arg0, arg1, arg2, arg3,arg4) in
                original(me, sel, arg0, !value, arg2, arg3,arg4)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }else {
            let original: oldClosureType = unsafeBitCast(originalImp, to: oldClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any) -> Void = {(me, arg0, arg1, arg2, arg3) in
                original(me, sel, arg0, !value, arg2, arg3)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
    }
    
}

