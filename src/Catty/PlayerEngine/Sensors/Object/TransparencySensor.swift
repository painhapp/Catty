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

@objc class TransparencySensor: NSObject, ObjectSensor, ReadWriteSensor {
    
    static let tag = "OBJECT_GHOSTEFFECT"
    static let name = kUIFEObjectTransparency
    static let defaultRawValue = 1.0
    static let requiredResource = ResourceType.noResources
    
    func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return TransparencySensor.defaultRawValue
        }
        
        return Double(spriteNode.alpha)
    }
    
    /*  on iOS, the transparency function is descending:
        1.0 - no transparency
        0.0 - maximum transaprency
 
        on Android the transparency function is ascending:
        0.0 - no transparency
        100.0 - maximum transparency
     
        And they also have different ranges and scales.
     */
    
    // f:[0, 1] -> [0, 100]
    func convertToStandardized(rawValue: Double) -> Double {
        
        if rawValue >= 1 {
            return 0.0 // maximum transparency
        }
        if rawValue <= 0 {
            return 100.0 // no transparency
        }
        return 100 - 100 * rawValue
    }
    
    // f:[0, 100] -> [0, 1]
    func convertToRaw(standardizedValue: Double) -> Double {
        
        if standardizedValue >= 100 {
            return 0.0 // maximum transparency
        }
        if standardizedValue <= 0 {
            return 1.0 // no transparency
        }
        return (100 - standardizedValue) / 100
    }
    
    func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return true
    }
}