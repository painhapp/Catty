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

class BroadcastWaitBrick: Brick, BrickMessageProtocol {
    var broadcastMessage = ""
    
    init(message: String?) {
        super.init()
        
        
        broadcastMessage = message ?? ""
        
    }
    
    func brickTitle() -> String? {
        return kLocalizedBroadcastAndWait + ("\n%@")
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        if spriteObject != nil {
            let messages = Util.allMessages(for: spriteObject?.program)
            if messages!.count > 0 {
                broadcastMessage = messages![0] as? String ?? ""
            } else {
                broadcastMessage = ""
            }
        }
        if broadcastMessage.count == 0 {
            broadcastMessage = kLocalizedMessage1
        }
    }
    
    func setMessage(_ message: String?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if message != nil {
            broadcastMessage = message ?? ""
        }
    }
    
    func message(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String? {
        return broadcastMessage
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "BroadcastWait (Msg: \(broadcastMessage))"
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
}
