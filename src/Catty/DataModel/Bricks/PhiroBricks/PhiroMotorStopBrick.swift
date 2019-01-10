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

class PhiroMotorStopBrick: PhiroBrick, BrickPhiroMotorProtocol {
    var motor = ""
    
    func phiroMotor() -> Motor {
        return PhiroHelper.string(toMotor: motor)
    }
    
    func brickTitle() -> String? {
        return kLocalizedStopPhiroMotor + ("\n%@")
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return String(format: "Stop Phiro Motor (Motor: %lu)", UInt(motor)!)
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if motor == (brick as? PhiroMotorStopBrick)?.motor {
            return true
        }
        return false
    }
    
    func motor(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String? {
        return motor
    }
    
    func setMotor(_ motor: String?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if motor != nil {
            self.motor = motor ?? ""
        }
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        motor = PhiroHelper.motor(toString: Motor.both)
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.bluetoothPhiro
    }
}
