//
//  RichEditorToolBar.swift
//
//  Created by 孟冰川 on 2017/12/6.
//

import UIKit

protocol RichEditorToolBarDelegate: class {
    
    func edit(type: RichEditAction)
    
}

class RichEditorToolBar: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    var editList: [RichEditAction]!
    weak var delegate: RichEditorToolBarDelegate?
    var itemInputView: RichEditorInputView!
    var lastIndexPath: IndexPath?
    var cells = [RichEditorToolBarButton]()
    
    var fontCell: RichEditorToolBarButton? {
        return cells.filter({ (cell) -> Bool in
            if let type = cell.editType {
                return type == .font(false)
            }else {
                return false
            }
        }).first
    }
    
    var data: RichEditorData? {
        didSet {
            guard let data = data else { return }
            
            var newList = [RichEditAction]()
            newList.append(.KeyBoard(true))
            newList.append(.font(false))
            newList.append(.list(data.list_bullet))
            newList.append(.numberList(data.list_ordered))
            newList.append(.alignLeading(data.align))
            newList.append(.alignCenter(data.align_center))
            newList.append(.alignTrailing(data.align_right))
            newList.append(.link(data.linkDisabled))
            self.editList = newList
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 48, height: 42)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(RichEditorToolBarButton.self, forCellWithReuseIdentifier: RichEditorToolBarButton.identifier)
        addSubview(collectionView)
        
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor(hex: 0x8073e2).cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editList.count
    }
    
    //不使用重用机制
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: RichEditorToolBarButton
        if cells.count <= indexPath.row {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: RichEditorToolBarButton.identifier, for: indexPath) as! RichEditorToolBarButton
            cell.inputView = itemInputView
            cells.append(cell)
            return cell
        }else {
            cell = cells[indexPath.row]
        }
        cell.editType = editList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let editType = editList[indexPath.row]
        delegate?.edit(type: editType)
    }
    
    func showFontPanel() {
        editList[0] = .KeyBoard(false)
        editList[1] = .font(true)
        collectionView.reloadData()
        fontCell?.becomeFirstResponder()
    }
    func dismissFontPanel() {
        fontCell?.resignFirstResponder()
    }

}

class RichEditorToolBarButton: UICollectionViewCell {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override var canResignFirstResponder: Bool {
        return true
    }
    
    private var _inputView: UIView?
    
    override var inputView: UIView? {
        get {
            return _inputView
        }
        set { _inputView = newValue }
    }
    
    let image = UIImageView()
    
    var selectedImage: UIImage?
    var normalImage: UIImage?
    
    var shadowImage = UIImageView()
    
    var editType: RichEditAction? {
        didSet {
            guard let type = editType else { return }
            image.image = type.image()
            image.sizeToFit()
            
            if type == .KeyBoard(true) {
                shadowImage.isHidden = false
            } else {
                shadowImage.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(shadowImage)
        addSubview(image)
        shadowImage.image = #imageLiteral(resourceName: "editor_shadow")
        shadowImage.isHidden = true
        shadowImage.alpha = 0.4
        image.image = normalImage
        layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowImage.frame = CGRect(x: frame.width - 4, y: 0, width: 4, height: frame.height)
        image.sizeToFit()
        image.center = CGPoint(x: frame.width/2, y: frame.height/2)
    }
}
