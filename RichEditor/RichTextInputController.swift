//
//  RichTextInputController.swift
//
//  Created by 孟冰川 on 2017/12/11.
//

import UIKit
import SwiftyJSON
import Zip

class RichTextInputView: UIView {
    
    let toolBarHeight = 52
    let contentHeight = 140
    
    let confirmBtn = UIButton()
    let swtch = RichEditorSwitch()
    let divider = UIView()
    let textView = RichEditorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        addSubview(confirmBtn)
        addSubview(swtch)
        addSubview(divider)
        
        backgroundColor = UIColor.white
        divider.backgroundColor = UIColor(hex: 0xeaeaea)
        confirmBtn.setAttributeString(title: "确定", font: UIFont.systemFont(ofSize: 15), color: UIColor.brown, state: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        swtch.frame = CGRect(x: 15, y: 17, width: 90, height: 24)
        confirmBtn.size = CGSize(width: 44, height: 30)
        confirmBtn.x = width - confirmBtn.width - 15
        confirmBtn.y = 15
        divider.frame = CGRect(x: 0, y: 52, width: width, height: SizeConst.onePixel)
        textView.frame = CGRect(x: 15, y: divider.frame.maxY + 8, width: width - 30, height: height - divider.frame.maxY - 20)
    }
    
}

class RichTextInputController: UIViewController,RichEditorSwitchDelegate {
    
    //传入参数
    var completion: ((_ desc: String,_ html: String) -> Void)?
    var editorType = RichEditorType.rte {
        didSet {
            input.textView.editorType = editorType
            input.swtch.status = editorType
        }
    }
    
    let input = RichTextInputView(frame: CGRect.zero)
    var bottomMargin: CGFloat = 0
    var inputHeight: CGFloat = 200
    let textTransitioningDelegate = TextInputTransitioningDelegate()
    
    var inputFrame: CGRect {
        return CGRect(x: 0, y: self.view.height - inputHeight - bottomMargin, width: self.view.width, height: inputHeight)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.transitioningDelegate = textTransitioningDelegate
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transitioningDelegate = textTransitioningDelegate
        self.modalPresentationStyle = .custom
    }
    var isLoadJs = false
    func unZipFile(_ filePath: URL) {
        do {
            try Zip.unzipFile(filePath, destination: FilePath.H5Resource, overwrite: true, password: nil, progress: { (progress) -> () in
                print(progress)
                if progress == 1 && !self.isLoadJs {
                    self.isLoadJs = true
                    self.input.textView.loadJS()
                }
            })
        } catch {
            #if DEBUG
            fatalError("Unzip file error:\(error)")
            #endif
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unZipFile(Bundle.main.url(forResource: "editor", withExtension: "zip")!)
        view.addSubview(input)
        input.swtch.delegate = self
        input.swtch.tap()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissSelf)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        input.confirmBtn.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        input.frame = inputFrame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.textView.becomeFirstResponder()
    }
    
    func statusChanged(status: RichEditorType) {
        input.textView.editorType = status
    }
    
    @objc func confirm() {
        input.textView.getText {[weak self] (value, error) in
            if let dic = value{
                let text = JSON(dic).description
                let html = dic["html"] as! String
                self?.completion?(text,html)
                self?.dismissSelf()
            }else {
            }
        }
    }
    
    @objc func dismissSelf() {
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - keyboard
    @objc func keyboardWillShow(_ noti: Notification) {
        guard let info = noti.userInfo else { return }
        guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        bottomMargin = keyboardFrame.height
        animateIntputWithKeyBoard(duration: duration,animateType: info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int)
    }
    
    @objc func keyboardWillHide(_ noti: Notification) {
        guard let info = noti.userInfo else { return }
        guard let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        bottomMargin = 0
        animateIntputWithKeyBoard(duration: duration,animateType: info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int)
    }
    
    func animateIntputWithKeyBoard(duration: Double,animateType: Int?) {
        let block: (() -> Void) = {
            self.input.frame = self.inputFrame
        }
        var animation: UIView.AnimationCurve
        if let type = animateType {
            animation = UIView.AnimationCurve(rawValue: type) ?? .linear
        }else {
            animation = .linear
        }
        func viewAnimationType() -> UIView.AnimationOptions {
            switch animation {
            case .easeIn:
                return .curveEaseIn
            case .easeOut:
                return .curveEaseOut
            case .easeInOut:
                return UIView.AnimationOptions()
            default:
                return .curveLinear
            }
        }
        UIView.animate(withDuration: duration, delay: 0, options: viewAnimationType(), animations: block, completion: nil)
    }
}


class TextInputTransitioningDelegate:NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return TextInputPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

class TextInputPresentationController: UIPresentationController {
    fileprivate var dimmingView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?)
    {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
    }
    
    override func presentationTransitionWillBegin()
    {
        super.presentationTransitionWillBegin()
        
        self.presentingViewController.view.tintAdjustmentMode = .dimmed
        self.dimmingView.alpha = 0
        
        self.containerView?.addSubview(self.dimmingView)
        
        let coordinator = self.presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { _ in self.dimmingView.alpha = 1 }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin()
    {
        super.dismissalTransitionWillBegin()
        
        self.presentingViewController.view.tintAdjustmentMode = .automatic
        
        let coordinator = self.presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { _ in self.dimmingView.alpha = 0 }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews()
    {
        super.containerViewWillLayoutSubviews()
        
        guard let containerView = self.containerView else { return }
        self.dimmingView.frame = containerView.frame
    }
    
}

