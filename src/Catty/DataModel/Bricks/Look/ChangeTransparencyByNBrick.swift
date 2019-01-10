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

class ChangeTransparencyByNBrick: Brick, BrickFormulaProtocol {
    var changeTransparency: Formula?
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        return changeTransparency
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        changeTransparency = formula
    }
    
    func getFormulas() -> [Formula]? {
        return [changeTransparency!]
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        changeTransparency = Formula(integer: 25)
    }
    
    func brickTitle() -> String? {
        return kLocalizedChangeTransparency + ("\n" + (kLocalizedBy + ("%@")))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "ChangeTransparencyByNBrick"
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return changeTransparency?.getRequiredResources() ?? 0
    }
}
