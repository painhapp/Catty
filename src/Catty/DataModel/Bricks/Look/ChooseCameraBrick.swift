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

class ChooseCameraBrick: Brick, BrickStaticChoiceProtocol {
    var cameraPosition: Int = 0
    
    init(choice: Int) {
        super.init()
        
        cameraPosition = choice
        
    }
    
    func brickTitle() -> String? {
        return kLocalizedChooseCamera + ("\n%@")
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        cameraPosition = 1
    }
    
    func setChoice(_ choice: String?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if (choice == kLocalizedCameraBack) {
            cameraPosition = 0
        } else {
            cameraPosition = 1
        }
    }
    
    func choice(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String? {
        let choices = possibleChoices(forLineNumber: 1, andParameterNumber: 0)
        return choices?[cameraPosition]
    }
    
    func possibleChoices(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> [String]? {
        let choices = [kLocalizedCameraBack, kLocalizedCameraFront] as? [String]
        return choices
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return String(format: "camera position (%i)", cameraPosition)
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
}
