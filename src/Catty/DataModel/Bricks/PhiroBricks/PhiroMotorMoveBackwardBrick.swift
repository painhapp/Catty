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

class PhiroMotorMoveBackwardBrick: PhiroBrick, BrickPhiroMotorProtocol, BrickFormulaProtocol {
    var motor = ""
    var formula: Formula?
    
    func phiroMotor() -> Motor {
        return PhiroHelper.string(toMotor: motor)
    }
    
    func brickTitle() -> String? {
        return kLocalizedPhiroMoveBackward + ("\n%@\n") + (kLocalizedPhiroSpeed) + ("%@")
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return String(format: "PhiroMotorMoveBackwardBrick (Motor: %lu)", UInt(motor)!)
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if motor != (brick as? PhiroMotorMoveBackwardBrick)?.motor {
            return false
        }
        if !(formula?.isEqual(to: (brick as? PhiroMotorMoveBackwardBrick)?.formula) ?? false) {
            return false
        }
        return true
    }
    
    func motor(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String? {
        return motor
    }
    
    func setMotor(_ motor: String?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if motor != nil {
            self.motor = motor ?? ""
        }
    }
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        return formula
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.formula = formula
    }
    
    func getFormulas() -> [Formula]? {
        return [formula!]
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        motor = PhiroHelper.motor(toString: Motor.both)
        formula = Formula()
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.bluetoothPhiro | ((formula?.getRequiredResources())!)
    }
}
