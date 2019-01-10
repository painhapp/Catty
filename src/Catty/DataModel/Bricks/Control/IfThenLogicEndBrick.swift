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

class IfThenLogicEndBrick: Brick {
    weak var ifBeginBrick: IfThenLogicBeginBrick?
    
    override func isSelectableForObject() -> Bool {
        return false
    }
    
    override func isAnimateable() -> Bool {
        return true
    }
    
    override func isIfLogicBrick() -> Bool {
        return true
    }
    
    func brickTitle() -> String? {
        return kLocalizedEndIf
    }
    
    override func perform(from script: Script?) {
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "If Then Logic End Brick"
    }
    
    // MARK: - Compare
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(Util.isEqual(ifBeginBrick?.brickTitle(), to: (brick as? IfThenLogicEndBrick)?.ifBeginBrick?.brickTitle())) {
            return false
        }
        return true
    }
    
    // MARK: - Copy
    
    override func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        let endBrick = mutableCopy(with: context, andErrorReporting: false) as? IfThenLogicEndBrick
        let beginBrick: IfThenLogicBeginBrick? = context?.updatedReference(forReference: ifBeginBrick) as! IfThenLogicBeginBrick
        
        if beginBrick != nil {
            endBrick?.ifBeginBrick = beginBrick
            beginBrick?.ifEndBrick = endBrick
        } else {
            // TODO: CONVERT NSError("IfThenLogicBeginBrick must not be nil for Brick with class %@!", IfThenLogicEndBrick)
        }
        
        return endBrick
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
}
