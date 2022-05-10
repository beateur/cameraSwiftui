//
//  File.swift
//  
//
//  Created by Bilel Hattay on 05/05/2022.
//

import SwiftUI

#if !os(macOS)
@available(iOS 14, *)
class defaultManager {
    static let instance = defaultManager()
    
    var flashisActive = false
    
    func toggleFlash() {
        flashisActive.toggle()
    }
}
#endif

