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

class Look: NSObject, CBMutableCopying {
    var fileName = ""
    var name: String?

    // MARK: - init methods

    init(path filePath: String) {
        super.init()
        
        name = nil
        if filePath.isEmpty {
            // TODO: CONVERT throw NSException(name: .internalInconsistencyException, reason: "You cannot instantiate a costume without a file path", userInfo: nil)
        } else {
            fileName = filePath
        }
    }
    
    init(name: String?, andPath filePath: String?) {
        super.init()
        
        self.name = name ?? ""
        if filePath == null || filePath.isEmpty {
            // TODO: CONVERT throw NSException(name: .internalInconsistencyException, reason: "You cannot instantiate a costume without a file path", userInfo: nil)
        } else {
            fileName = filePath ?? ""
        }
    }
    
    func previewImageFileName() -> String? {
        // e.g. 34A109A82231694B6FE09C216B390570_normalCat
        let result: NSRange = (fileName as NSString).range(of: kResourceFileNameSeparator)
        if (Int(result.location) == NSNotFound) || (Int(result.location) == 0) || (Int(result.location) >= (fileName.count - 1)) {
            return nil // Invalid file name convention -> this should not happen. FIXME: maybe abort here??
        }
        
        return "\((fileName as? NSString)?.substring(to: result.location) ?? "")_\(kPreviewImageNamePrefix)\((fileName as? NSString)?.substring(from: (Int(result.location) + 1)) ?? "")"
    }
    
    func description() -> String {
        return "Name: \(name ?? "")\rPath: \(fileName)\r"
    }
    
    func isEqual(to look: Look?) -> Bool {
        if (name == look?.name) && (fileName == look?.fileName) {
            return true
        }
        return false
    }

    // MARK: - Copy
    
    func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        if context == nil {
            // TODO: CONVERT NSError("%@ must not be nil!", CBMutableCopyContext.self)
        }
        
        let copiedLook = Look(path: fileName)
        copiedLook.fileName = fileName
        copiedLook.name = name
        context?.updateReference(self, withReference: copiedLook)
        return copiedLook
    }
    
    // MARK: - description
}
