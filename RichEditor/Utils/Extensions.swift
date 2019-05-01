//
//  Extensions.swift
//  RichEditor
//
//  Created by 孟冰川 on 2019/5/1
//

import UIKit

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}


extension UIColor {
    /**
     通过颜色值的 Hex 字符串和 默认为1.0的 Alpha 值来初始化一个 UIColor 或者 NSColor.
     
     - parameter hexString: 颜色值的 Hex 字符串, 传入的字符串可以为 `FFFFFF`
     或者 `#FFFFFF` 的形式.
     - parameter alpha:     颜色值的 alpha 值, 默认为 1.0
     
     - returns: 如果传入的 Hex 字符串有效, 则返回一个初始化成功的UIColor 或者 NSColor;
     如果传入的 Hex 字符串无效, 则返回 nil.
     */
    convenience init?(hexString: String, alpha: CGFloat = 1.0){
        var result: UInt32 = 0
        
        let scanner = Scanner(string: hexString)
        if Array(hexString).first == "#" {
            scanner.scanLocation = 1
        } else {
            scanner.scanLocation = 0
        }
        
        if !scanner.scanHexInt32(&result) { return nil }
        
        self.init(hex: result, alpha: alpha)
    }
    /**
     通过颜色值的 Hex 值和默认为1.0的 Alpha 值来初始化一个 UIColor 或者 NSColor.
     
     - parameter hex:   颜色值的 Hex值, 传入 UInt32类型的值.
     - parameter alpha: 颜色值的 alpha 值, 默认为 1.0
     
     - returns: 返回一个初始化成功的UIColor 或者 NSColor
     */
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat(((hex & 0xFF0000) >> 16)) / 255.0
        let g = CGFloat(((hex & 0xFF00) >> 8)) / 255.0
        let b = CGFloat(((hex & 0xFF))) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
}

extension UIView {
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        } set (value) {
            self.frame = CGRect (x: value, y: self.y, width: self.width, height: self.height)
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        } set (value) {
            self.frame = CGRect (x: self.x, y: value, width: self.width, height: self.height)
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: value, height: self.height)
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: self.width, height: value)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set (value) {
            self.frame = CGRect (origin: self.frame.origin, size: value)
        }
    }
}

extension String {
    func sizeWithGivenSize(_ size: CGSize,attributes: [NSAttributedString.Key: Any]) -> CGSize {
        return (self as NSString).boundingRect(with: size,
                                               options: [.usesLineFragmentOrigin,.usesFontLeading],
                                               attributes: attributes,
                                               context: nil).size
    }
    func sizeWithGivenSize(_ size: CGSize,font: UIFont,paragraph: NSMutableParagraphStyle? = nil) -> CGSize {
        var attributes = [NSAttributedString.Key:Any]()
        attributes[NSAttributedString.Key.font] = font
        if let p = paragraph {
            attributes[NSAttributedString.Key.paragraphStyle] = p
        }
        attributes[NSAttributedString.Key.font] = font
        return sizeWithGivenSize(size, attributes: attributes)
    }
}

extension UIButton {
    func setAttributeString(title: String,font: UIFont,color: UIColor,state: UIControl.State) {
        setAttributedTitle(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor: color]), for: state)
    }
}

extension UILabel {
    func set(_ textColor: UIColor,font: UIFont) {
        self.textColor = textColor
        self.font = font
    }
}

extension UIFont {
    
    func withWeightThin() -> UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: UIFont.Weight.thin)
    }
    
    func withWeightBold() -> UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: UIFont.Weight.bold)
    }
    
}

extension UIViewController {
    
    static func topViewController(_ viewController: UIViewController? = nil) -> UIViewController?
    {
        let viewController = viewController ?? (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
        
        if let navigationController = viewController as? UINavigationController, !navigationController.viewControllers.isEmpty
        {
            return topViewController(navigationController.viewControllers.last)
        } else if let tabBarController = viewController as? UITabBarController,
            let selectedController = tabBarController.selectedViewController
        {
            return topViewController(selectedController)
        } else if let presentedController = viewController?.presentedViewController {
            return topViewController(presentedController)
        }
        
        return viewController
    }
}

public extension FileManager {
    // MARK: - Enums -
    
    /**
     Directory type enum
     
     - MainBundle: Main bundle directory
     - Library:    Library directory
     - Documents:  Documents directory
     - Cache:      Cache directory
     */
    public enum DirectoryType : Int {
        case MainBundle
        case Library
        case Documents
        case Cache
    }
    
   
    
    /**
     Get the Bundle path for a filename
     
     - parameter file: Filename
     
     - returns: Returns the path as a String
     */
    public static func getBundlePathForFile(file: String) -> String {
        let fileExtension = (file as NSString).pathExtension
        return Bundle.main.path(forResource: file.replacingOccurrences(of: String(format: ".%@", file), with: ""), ofType: fileExtension)!
    }
    
    /**
     Get the Documents directory for a filename
     
     - parameter file: Filename
     
     - returns: Returns the directory as a String
     */
    public static func getDocumentsDirectoryForFile(file: String) -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentsDirectory as NSString).appendingPathComponent(String(format: "%@/", file))
    }
    
    /**
     Get the Library directory for a filename
     
     - parameter file: Filename
     
     - returns: Returns the directory as a String
     */
    public static func getLibraryDirectoryForFile(file: String) -> String {
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        return (libraryDirectory as NSString).appendingPathComponent(String(format: "%@/", file))
    }
    
    /**
     Get the Cache directory for a filename
     
     - parameter file: Filename
     
     - returns: Returns the directory as a String
     */
    public static func getCacheDirectoryForFile(file: String) -> String {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return (cacheDirectory as NSString).appendingPathComponent(String(format: "%@/", file))
    }
    
    /**
     Returns the size of the file
     
     - parameter file:      Filename
     - parameter directory: Directory of the file
     
     - returns: Returns the file size
     */
    public static func fileSize(file: String, fromDirectory directory: DirectoryType) throws -> NSNumber? {
        if file.count != 0 {
            var path: String
            
            switch directory {
            case .MainBundle:
                path = self.getBundlePathForFile(file: file)
            case .Library:
                path = self.getLibraryDirectoryForFile(file: file)
            case .Documents:
                path = self.getDocumentsDirectoryForFile(file: file)
            case .Cache:
                path = self.getCacheDirectoryForFile(file: file)
            }
            
            if FileManager.default.fileExists(atPath: path) {
                let fileAttributes: NSDictionary? = try FileManager.default.attributesOfItem(atPath: file) as NSDictionary?
                if let _fileAttributes = fileAttributes {
                    return NSNumber(value: _fileAttributes.fileSize())
                }
            }
        }
        
        return nil
    }
    
   
    /**
     Set the given settings for a given object and key. The file will be saved in the Library directory
     
     - parameter settings: Settings filename
     - parameter object:   Object to set
     - parameter objKey:   Key to set the object
     
     - returns: Returns true if the operation was successful, otherwise false
     */
    public static func setSettings(settings: String, object: AnyObject, forKey objKey: String) -> Bool {
        var path: String = self.getLibraryDirectoryForFile(file: "")
        
        path = path.appending("/Preferences/")
        path = path.appending("\(settings)-Settings.plist")
        
        var loadedPlist: NSMutableDictionary
        if FileManager.default.fileExists(atPath: path) {
            loadedPlist = NSMutableDictionary(contentsOfFile: path)!
        } else {
            loadedPlist = NSMutableDictionary()
        }
        
        loadedPlist[objKey] = object
        
        return loadedPlist.write(toFile: path, atomically: true)
    }
    
}
