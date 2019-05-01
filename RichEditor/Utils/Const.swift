//
//  Const.swift
//  RichEditor
//
//  Created by 孟冰川 on 2019/5/1.
//  Copyright © 2019 孟冰川. All rights reserved.
//

import UIKit

struct FilePath {
    static var H5Resource: URL {
        return URL(fileURLWithPath: FileManager.getCacheDirectoryForFile(file: "H5resource"))
    }    
}

struct SizeConst {
    static let onePixel: CGFloat = 1.0 / UIScreen.main.scale
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
}
