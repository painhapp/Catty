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

class ArduinoSendPWMValueBrick: ArduinoBrick, BrickFormulaProtocol {
    var pin: Formula?
    var value: Formula?
    
    func brickTitle() -> String? {
        return kLocalizedArduinoSendPWMValue + ("%@\n") + (kLocalizedArduinoSetPinValueTo) + ("%@")
    }
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        if lineNumber == 0 {
            return pin
        } else if lineNumber == 1 {
            return value
        }
        
        return nil
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 0 {
            pin = formula
        } else if lineNumber == 1 {
            value = formula
        }
    }
    
    func getFormulas() -> [Formula]? {
        return [pin!, value!]
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "ArduinoSendPWMValueBrick"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(pin?.isEqual(to: (brick as? ArduinoSendPWMValueBrick)?.pin) ?? false) {
            return false
        }
        if !(value?.isEqual(to: (brick as? ArduinoSendPWMValueBrick)?.value) ?? false) {
            return false
        }
        return true
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        pin = Formula()
        value = Formula()
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.bluetoothArduino | (pin?.getRequiredResources() ?? 0) | (value?.getRequiredResources() ?? 0)
    }
}
