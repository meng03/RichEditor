//
//  RichEditorView.swift
//
//  Created by 孟冰川 on 2017/12/6.
//

import UIKit
import WebKit
import SwiftyJSON

class RichEditorView: UIView {
    
    fileprivate let webView = WKWebView()
    fileprivate let toolBar = RichEditorToolBar()
    fileprivate let toolBarInputView = RichEditorInputView()
    
    var query = "?defaultMdSplit=false"
    
    //需要外部赋值的变量
    var delta: String?
    var defaultPlaceHolder: String? {
        didSet {
            if let placeHolder = self.defaultPlaceHolder {
                query += "&placeholder=\(placeHolder)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            }
        }
    }
    var editorType = RichEditorType.rte {
        didSet {
            query += "&defaultMode=\(editorType.string)"
            if editorType == .rte {
                webView.customAccessoryView = toolBar
            }else {
                webView.customAccessoryView = nil
            }
            self.endEditing(true)
            self.switchType()
            self.excuteCommand(method: "focus", completion: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configSubView() {
        addSubview(webView)
        toolBar.height = 43
        toolBarInputView.height = 216
        toolBar.itemInputView = toolBarInputView
        toolBar.delegate = self
        toolBarInputView.delegate = self
        webView.setKeyboardRequiresUserInteraction(false)
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.white
        toolBar.editList = [.KeyBoard(true),.font(false),.list(false),.numberList(false),.alignLeading(false),.alignCenter(false),.alignTrailing(false),.link(false)]
        toolBar.collectionView.reloadData()
//        loadJS()
        
    }
    
    func loadJS() {
//        webView.load(URLRequest(url: URL(string: "http://test-editor.jingdata.com/richEditor.html#/editor")!))
        if let urlValue = URL(string: FilePath.H5Resource.absoluteString + "richEditor.html#/editor") {
            webView.loadFileURL(urlValue, allowingReadAccessTo: FilePath.H5Resource)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
    }
    
    func setRichEditType(type: RichEditorType) {
        self.editorType = type
    }
    
    func getText(completion: @escaping (([String: Any]?,Error?) -> Void)) {
        excuteCommand(method: "getData") { (value, error) in
            if let error = error {
                completion(nil,error)
            }else if let value = value as? [String: Any]{
                completion(value,nil)
            }
        }
    }
    
    //MARK: - 执行js
    fileprivate func jsCommand(method: String,args: [String]? = nil) -> String {
        var js = "window.NATIVE_ENTRY("
        js.append("'\(method)'")
        if let args = args {
            for arg in args {
                js.append(",\(arg)")
            }
        }
        js.append(")")
        return js
    }
    
    fileprivate func excuteCommand(js: String,needsBack: Bool = true,completion: ((Any?,Error?) -> Void)?) {
        webView.evaluateJavaScript(js) {[weak self] (value, error) in
            if needsBack {
                guard let slf = self else { return }
                self?.webView.evaluateJavaScript(slf.jsCommand(method: "updateTb"), completionHandler: nil)
            }
            completion?(value,error)
        }
    }
    
    fileprivate func excuteCommand(method: String,args: [String]? = nil,needsBack: Bool = true,completion: ((Any?,Error?) -> Void)?) {
        excuteCommand(js: jsCommand(method: method,args: args), needsBack: needsBack, completion: completion)
    }
    
    func processQuery(query: String?) -> [String: String]? {
        return query?.components(separatedBy: "&").map({ (queryItem) -> [String: String]? in
            let keyValue = queryItem.components(separatedBy: "=")
            if keyValue.count == 2 {
                if let value = keyValue[1].removingPercentEncoding {
                    return [keyValue[0]: value]
                }else {
                    return nil
                }
            }else {
                return nil
            }
        }).compactMap({$0}).reduce([:], { (result, item: [String : String]) -> [String: String] in
            var comibinedDic = result
            for (k,v) in item {
                comibinedDic[k] = v
            }
            return comibinedDic
        })
    }
}

extension RichEditorView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if let schema = url.scheme,schema == "jingdata" {
                if let host = url.host,let queryDic = processQuery(query: url.query?.removingPercentEncoding) {
                    switch host {
                    case "setData":
                        setData(queryDic)
                    case "route":
                        route(queryDic)
                    default:
                        ()
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
    
    fileprivate func setData(_ dic: [String: String]) {
        guard let dataId = dic["dataId"],let dataIdStr = JSON(parseJSON: dataId).string else { return }
        guard let data = dic["data"],let dataDic = JSON(parseJSON: data).dictionaryObject else { return }
        switch dataIdStr {
        case "active":
            let data = RichEditorData(dic: dataDic)
            self.toolBar.data = data
            self.toolBarInputView.data = data
        case "config":
            if let size = dataDic["header"] as? [[String: String]],
                let color = dataDic["color"] as? [String] {
                self.toolBarInputView.originColorValues = color
                self.toolBarInputView.originalFontValues = size
                self.toolBarInputView.reload()
            }
            if let delta = self.delta {
                excuteCommand(method: "setDelta", args: [delta], needsBack: true, completion: nil)
            }
            self.excuteCommand(method: "focus", completion: nil)
        default:
            return
        }
    }
    
    
    fileprivate func route(_ query: [String: String]) {
        guard let action = query["action"],let actionStr = JSON(parseJSON: action).string else { return }
        switch actionStr {
//        case "onAtStart":
//            onAtStart()
        case "onEditLink":
            guard let data = query["data"] else { return }
            let json = JSON(parseJSON: data)
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "编辑链接", style: .default, handler: { (_) in
                if let link = json["href"].string,let text = json["text"].string {
                    self.onEditLink(link,text: text)
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "移除链接", style: .default, handler: { (_) in
                self.removeLink()
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            UIViewController.topViewController()?.present(actionSheet, animated: true)
        default:
            ()
        }
    }
    
    fileprivate func removeLink() {
        excuteCommand(method: "removeLink", needsBack: false, completion: nil)
    }
    
    fileprivate func onEditLink(_ link: String,text: String) {
        let alert = UIAlertController(title: "请输入文本和链接", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textfield) in
            textfield.text = text
        })
        alert.addTextField(configurationHandler: { (textfield) in
            textfield.text = link
        })
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            guard let text = alert.textFields?.first?.text else {
                return
            }
            guard let link = alert.textFields?.last?.text else {
                return
            }
            self.excuteCommand(method: "focus", completion: {[weak self] (_, _) in
                self?.excuteCommand(method: "updateLink", args: ["'\(text)'","'\(link)'"], needsBack: false, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        UIViewController.topViewController()?.present(alert, animated: true)
    }
    
    fileprivate func addLink() {
        let alert = UIAlertController(title: "请输入文本和链接", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textfield) in
            textfield.placeholder = "请输入文本"
        })
        alert.addTextField(configurationHandler: { (textfield) in
            textfield.text = "http://"
        })
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            guard let text = alert.textFields?.first?.text else {
                return
            }
            guard let link = alert.textFields?.last?.text else {
                return
            }
            self.excuteCommand(method: "focus", completion: {[weak self] (_, _) in
                self?.excuteCommand(method: "addLink", args: ["'\(text)'","'\(link)'"], needsBack: false, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        UIViewController.topViewController()?.present(alert, animated: true)
    }
}

//MARK: - 处理富文本的操作
extension RichEditorView: RichEditorToolBarDelegate,RichEditorInputViewDelegate {
    
    //富文本和markdown切换
    func switchType() {
        excuteCommand(method: "changeMode", args: ["'\(editorType.string)'"], needsBack: false, completion: nil)
    }
    //toolbar
    func edit(type: RichEditAction) {
        switch type {
        case .KeyBoard,.font:
            ()
        case .list:
            excuteCommand(method: "format",args: ["'list_bullet'"], completion: nil)
        case .numberList:
            excuteCommand(method: "format",args: ["'list_ordered'"], completion: nil)
        case .alignLeading:
            excuteCommand(method: "format",args: ["'align'","'left'"], completion: nil)
        case .alignCenter:
            excuteCommand(method: "format",args: ["'align'","'center'"], completion: nil)
        case .alignTrailing:
            excuteCommand(method: "format",args: ["'align'","'right'"], completion: nil)
        case .link:
            addLink()
        }
        
        switch type {
        case .font(let isSelected):
            if isSelected {
                self.toolBar.dismissFontPanel()
                self.excuteCommand(method: "focus",needsBack: false, completion: nil)
            }else {
                excuteCommand(method: "blur",needsBack: false, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
                    self.toolBar.showFontPanel()
                })
            }
        case .KeyBoard(let isSelected):
            if isSelected {
                endEditing(true)
            }else {
                self.toolBar.dismissFontPanel()
                self.excuteCommand(method: "focus",needsBack: false, completion: nil)
            }
        default:
            self.toolBar.dismissFontPanel()
            self.excuteCommand(method: "focus",needsBack: false, completion: nil)
        }
    }
    //input view
    func changeFont(font: String) {
        excuteCommand(method: "format",args:["'header'","'\(font)'"], completion: nil)
    }
    
    func changeFontStyle(fontStyle: String) {
        excuteCommand(method: "format",args: ["'\(fontStyle)'"], completion: nil)
    }
    
    func changeColor(color: String) {
        excuteCommand(method: "format",args: ["'color'","'\(color)'"], completion: nil)
    }
    
}
