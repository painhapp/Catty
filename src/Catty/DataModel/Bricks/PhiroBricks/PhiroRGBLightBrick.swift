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

class PhiroRGBLightBrick: PhiroBrick, BrickFormulaProtocol, BrickPhiroLightProtocol {
    var light = ""
    var redFormula: Formula?
    var greenFormula: Formula?
    var blueFormula: Formula?
    
    func phiroLight() -> Light {
        return PhiroHelper.string(toLight: light)
    }
    
    func brickTitle() -> String? {
        return kLocalizedPhiroRGBLight + ("\n%@\n") + (kLocalizedPhiroRGBLightRed) + ("%@ ") + (kLocalizedPhiroRGBLightGreen) + ("%@ ") + (kLocalizedPhiroRGBLightBlue) + ("%@")
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "Set Phiro Light (R: G: B:"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if redFormula != (brick as? PhiroRGBLightBrick)?.redFormula {
            return false
        }
        if greenFormula != (brick as? PhiroRGBLightBrick)?.greenFormula {
            return false
        }
        if blueFormula != (brick as? PhiroRGBLightBrick)?.blueFormula {
            return false
        }
        return true
    }
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        if lineNumber == 2 && paramNumber == 0 {
            return redFormula
        }
        if lineNumber == 2 && paramNumber == 1 {
            return greenFormula
        }
        if lineNumber == 2 && paramNumber == 2 {
            return blueFormula
        }
        
        return nil
    }
    
    func getFormulas() -> [Formula]? {
        return [redFormula!, greenFormula!, blueFormula!]
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 2 && paramNumber == 0 {
            redFormula = formula
        }
        if lineNumber == 2 && paramNumber == 1 {
            greenFormula = formula
        }
        if lineNumber == 2 && paramNumber == 2 {
            blueFormula = formula
        }
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    func light(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String? {
        return light
    }
    
    func setLight(_ light: String?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if light != nil {
            self.light = light ?? ""
        }
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        light = PhiroHelper.light(toString: Light.lBoth)
        redFormula = Formula()
        greenFormula = Formula()
        blueFormula = Formula()
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.bluetoothPhiro | (redFormula?.getRequiredResources() ?? 0) | (greenFormula?.getRequiredResources() ?? 0) | (blueFormula?.getRequiredResources() ?? 0)
    }
}
