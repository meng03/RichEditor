//
//  RichEditorInputView.swift
//
//  Created by 孟冰川 on 2017/12/6.
//

import UIKit

//MARK: - delegate
protocol RichEditorInputViewDelegate: class {
    
    func changeFontStyle(fontStyle: String)
    func changeFont(font: String)
    func changeColor(color: String)
    
}

//MARK: - item
class RichEditorInputViewItem: UICollectionViewCell {
    
    enum ShowType {
        case style
        case font
        case color
    }
    
    var value: String? {
        didSet {
            processState()
        }
    }
    
    var type: ShowType = .style {
        didSet {
            image.isHidden = type != .style
            text.isHidden = type != .font
            circle.isHidden = type != .color
        }
    }
    
    override var isSelected: Bool {
        didSet {
            processState()
        }
    }
    
    func processState() {
        guard let value = value else { return }
        switch type {
        case .style:
            let name = isSelected ? "\(value)_click" : value
            image.image = UIImage(named: name)
        case .font:
            text.text = value
            text.textColor = isSelected ? UIColor(hex: 0x333333) : UIColor(hex: 0x999999)
            text.font = UIFont.systemFont(ofSize: 13)
            text.sizeToFit()
        case .color:
            circle.backgroundColor = UIColor(hexString: value)
            circle.layer.borderColor = isSelected ? UIColor.black.cgColor : UIColor.white.cgColor
        }
    }
    
    var image = UIImageView()
    let text = UILabel()
    let circle = UIView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        addSubview(text)
        text.set(UIColor(hex: 0x999999), font: UIFont.systemFont(ofSize: 13))
        addSubview(circle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        image.sizeToFit()
        image.center = center
        text.sizeToFit()
        text.center = center
        circle.frame.size = CGSize(width: 20, height: 20)
        circle.layer.cornerRadius = 10
        circle.layer.borderColor = UIColor.white.cgColor
        circle.layer.borderWidth = 2
        circle.center = center
    }
    
}

//MARK: - input view
class RichEditorInputView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
    
    class Model {
        init(label: String,value: String,isSelected: Bool = false) {
            self.label = label
            self.value = value
            self.isSelected = isSelected
        }
        var label: String
        var value: String
        var isSelected: Bool
    }
    
    var fontStyleContainer: UICollectionView!
    var fontStyleDivider = UIView()
    
    let fontTilte = UILabel()
    var fontContainer: UICollectionView!
    var fontDivider = UIView()
    var colorTitle = UILabel()
    var colorContainer: UICollectionView!

    var originColorValues:[String]? {
        didSet {
            if let values = originColorValues {
                color.removeAll()
                for value in values {
                    color.append(Model(label: value, value: value))
                }
            }
        }
    }
    var originalFontValues:[[String:String]]? {
        didSet {
            if let values = originalFontValues {
                fonts.removeAll()
                for value in values {
                    if let label = value["label"],let value = value["value"] {
                        fonts.append(RichEditorInputView.Model(label: label, value: value))
                    }
                }
            }
        }
    }
    
    weak var delegate: RichEditorInputViewDelegate?
    
    var images = [Model(label: "icon_typeface", value: "bold"),Model(label: "icon_italic", value: "italic"),Model(label: "icon_underline", value: "underline")]
    var fonts = [Model]()
    var color = [Model]()
    var data: RichEditorData? {
        didSet {
            guard let data = data else { return }
            if let selectedColor = data.color {
                color.forEach({$0.isSelected = $0.value == selectedColor})
            }
            colorContainer.reloadData()
            if let selectedFont = data.size {
                fonts.forEach({$0.isSelected = $0.value == selectedFont})
            }
            fontContainer.reloadData()
            
            images.filter({$0.value == "bold"}).first?.isSelected = data.bold
            images.filter({$0.value == "italic"}).first?.isSelected = data.italic
            images.filter({$0.value == "underline"}).first?.isSelected = data.underline
            fontStyleContainer.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fontStyleContainer.frame = CGRect(x: 0, y: 0, width: frame.width, height: 54)
        fontStyleDivider.frame = CGRect(x: 0, y: fontStyleContainer.frame.maxY, width: frame.width, height: SizeConst.onePixel)
        fontTilte.sizeToFit()
        fontTilte.x = 15
        fontTilte.y = fontStyleContainer.frame.maxY + 10
        fontContainer.frame = CGRect(x: 0, y: fontTilte.frame.maxY, width: frame.width, height: 48)
        fontDivider.frame = CGRect(x: 0, y: fontContainer.frame.maxY, width: frame.width, height: SizeConst.onePixel)
        colorTitle.sizeToFit()
        colorTitle.x = 15
        colorTitle.y = fontContainer.frame.maxY + 15
        colorContainer.frame = CGRect(x: 0, y: colorTitle.frame.maxY, width: frame.width, height: 51)
    }
    
    func configSubView() {
        let fontStyleFlowLayout = UICollectionViewFlowLayout()
        fontStyleFlowLayout.itemSize = CGSize(width: 40, height: 40)
        fontStyleFlowLayout.scrollDirection = .horizontal
        fontStyleFlowLayout.sectionInset.left = 20
        fontStyleFlowLayout.minimumLineSpacing = 0
        fontStyleFlowLayout.minimumInteritemSpacing = 0
        fontStyleContainer = UICollectionView(frame: CGRect.zero, collectionViewLayout: fontStyleFlowLayout)
        fontStyleContainer.register(RichEditorInputViewItem.self, forCellWithReuseIdentifier: RichEditorInputViewItem.identifier)
//        fontStyleDivider.backgroundColor = DeeperColor.divider
        
        
        let fontFlowLayout = UICollectionViewFlowLayout()
        fontFlowLayout.itemSize = CGSize(width: 50, height: 30)
        fontFlowLayout.scrollDirection = .horizontal
        fontFlowLayout.sectionInset.left = 15
        fontFlowLayout.minimumLineSpacing = 0
        fontFlowLayout.minimumInteritemSpacing = 0
        fontContainer = UICollectionView(frame: CGRect.zero, collectionViewLayout: fontFlowLayout)
        fontContainer.register(RichEditorInputViewItem.self, forCellWithReuseIdentifier: RichEditorInputViewItem.identifier)
        fontDivider.backgroundColor = UIColor(hex: 0xeaeaea)
        
        let colorFlowLayout = UICollectionViewFlowLayout()
        colorFlowLayout.itemSize = CGSize(width: 45, height: 30)
        colorFlowLayout.scrollDirection = .horizontal
        colorFlowLayout.sectionInset.left = 15
        colorFlowLayout.minimumLineSpacing = 0
        colorFlowLayout.minimumInteritemSpacing = 0
        colorContainer = UICollectionView(frame: CGRect.zero, collectionViewLayout: colorFlowLayout)
        colorContainer.register(RichEditorInputViewItem.self, forCellWithReuseIdentifier: RichEditorInputViewItem.identifier)
        
        fontTilte.set(UIColor(hex: 0x999999), font: UIFont.systemFont(ofSize: 13).withWeightThin())
        colorTitle.set(UIColor(hex: 0x999999), font: UIFont.systemFont(ofSize: 13).withWeightThin())
        fontTilte.text = "字号"
        colorTitle.text = "字色"
        
        addSubview(fontStyleContainer)
        addSubview(fontTilte)
        addSubview(fontContainer)
        addSubview(colorTitle)
        addSubview(colorContainer)
        addSubview(fontStyleDivider)
        addSubview(fontDivider)
        
        fontStyleContainer.dataSource = self
        fontContainer.dataSource = self
        colorContainer.dataSource = self
        fontStyleContainer.delegate = self
        fontContainer.delegate = self
        colorContainer.delegate = self
        
        backgroundColor = UIColor(hex: 0xf4f4f4)
        fontContainer.backgroundColor = UIColor(hex: 0xf4f4f4)
        fontStyleContainer.backgroundColor = UIColor(hex: 0xf4f4f4)
        colorContainer.backgroundColor = UIColor(hex: 0xf4f4f4)
    }
    
    func reload() {
        fontStyleContainer.reloadData()
        fontContainer.reloadData()
        colorContainer.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == fontStyleContainer {
            return images.count
        }else if collectionView == fontContainer {
            return fonts.count
        }else if collectionView == colorContainer {
            return color.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RichEditorInputViewItem.identifier, for: indexPath) as! RichEditorInputViewItem
        var model: Model!
        if collectionView == fontStyleContainer {
            cell.type = .style
            model = images[indexPath.row]
        }else if collectionView == fontContainer {
            cell.type = .font
            model = fonts[indexPath.row]
        }else if collectionView == colorContainer {
            cell.type = .color
            model = color[indexPath.row]
        }
        cell.value = model.label
        cell.isSelected = model.isSelected
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == fontStyleContainer {
            delegate?.changeFontStyle(fontStyle: images[indexPath.row].value)
        }else if collectionView == fontContainer {
            delegate?.changeFont(font: fonts[indexPath.row].value)
        }else if collectionView == colorContainer {
            delegate?.changeColor(color: color[indexPath.row].value)
        }
    }
    
}
