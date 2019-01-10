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

class SetTransparencyBrick: Brick, BrickFormulaProtocol {
    var transparency: Formula?
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        return transparency
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        transparency = formula
    }
    
    func getFormulas() -> [Formula]? {
        return [transparency!]
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        transparency = Formula(integer: 50)
    }
    
    func brickTitle() -> String? {
        return kLocalizedSetTransparency + ("\n" + (kLocalizedTo + ("%@")))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "SetTransparencyBrick"
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return transparency?.getRequiredResources() ?? 0
    }
}
