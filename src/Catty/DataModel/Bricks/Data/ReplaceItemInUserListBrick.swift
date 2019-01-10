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

class ReplaceItemInUserListBrick: Brick, BrickFormulaProtocol, BrickListProtocol {
    var userList: UserVariable?
    var elementFormula: Formula?
    var index: Formula?
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        if lineNumber == 2 && paramNumber == 0 {
            return index
        } else if lineNumber == 2 && paramNumber == 1 {
            return elementFormula
        }
        
        return nil
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 2 && paramNumber == 0 {
            index = formula
        } else if lineNumber == 2 && paramNumber == 1 {
            elementFormula = formula
        }
    }
    
    func list(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> UserVariable? {
        return userList
    }
    
    func setList(_ list: UserVariable?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        userList = list
    }
    
    func getFormulas() -> [Formula]? {
        return [elementFormula!, index!]
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        elementFormula = Formula(integer: 1)
        index = Formula(integer: 1)
        if spriteObject != nil {
            let lists = spriteObject?.program?.variables.allLists(for: spriteObject)
            if (lists?.count ?? 0) > 0 {
                userList = lists?[0] as? UserVariable
            } else {
                userList = nil
            }
        }
    }
    
    func brickTitle() -> String? {
        return kLocalizedReplaceItemInUserList
    }
    
    func allowsStringFormula() -> Bool {
        return true
    }
    
    // MARK: - Description
    
    override func description() -> String {
        if let aList = userList {
            return "ReplaceItemInUserListBrick (Userlist: \(aList))"
        }
        return ""
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(userList?.isEqual(to: (brick as? ReplaceItemInUserListBrick)?.userList) ?? false) {
            return false
        }
        if !(elementFormula?.isEqual(to: (brick as? ReplaceItemInUserListBrick)?.elementFormula) ?? false) {
            return false
        }
        if !(index?.isEqual(to: (brick as? ReplaceItemInUserListBrick)?.index) ?? false) {
            return false
        }
        return true
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return (elementFormula?.getRequiredResources() ?? 0) | (index?.getRequiredResources() ?? 0)
    }
}
