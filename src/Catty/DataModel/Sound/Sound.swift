/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import UIKit

class Sound: NSObject, CBMutableCopying {
    var name: String?
    var fileName: String?
    var playing = false
    // this property must be thread-safe!
    init(name: String?, fileName: String?) {
        super.init()
        
        self.name = name
        self.fileName = fileName
        
    }
    
    func isEqual(to sound: Sound?) -> Bool {
        if (name == sound?.name) && (fileName == sound?.fileName) {
            return true
        }
        return false
    }
    
    func description() -> String {
        return "Sound: \(name ?? "")\r"
    }
    
    // MARK: - Copy
    
    func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        if context == nil {
            // TODO: CONVERT NSError("%@ must not be nil!", CBMutableCopyContext.self)
        }
        
        let copiedSound = Sound()
        copiedSound.fileName = fileName ?? ""
        copiedSound.name = name ?? ""
        copiedSound.playing = false
        
        context?.updateReference(self, withReference: copiedSound)
        return copiedSound
    }
}
