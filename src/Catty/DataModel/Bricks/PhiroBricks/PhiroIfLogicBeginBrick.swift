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

class PhiroIfLogicBeginBrick: IfLogicBeginBrick, BrickPhiroIfSensorProtocol {
    var sensor = ""
    
    override func brickTitle() -> String? {
        return kLocalizedPhiroIfLogic + ("%@ ") + (kLocalizedPhiroThenLogic)
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "Move Phiro If Logic (Sensor: \(sensor))"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if sensor != (brick as? PhiroIfLogicBeginBrick)?.sensor {
            return false
        }
        
        return true
    }
    
    func sensor(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String? {
        return sensor
    }
    
    func setSensor(_ sensor: String?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if sensor != nil {
            self.sensor = sensor ?? ""
        }
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        sensor = BluetoothPhiroHelper.self.defaultTag()
    }
    
    override func isPhiroBrick() -> Bool {
        return true
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.bluetoothPhiro
    }
}
