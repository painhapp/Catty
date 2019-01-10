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

import UIKit

extension UIColor {
    class func globalTint() -> UIColor? {
        return self.medium()
    }

    class func utilityTint() -> UIColor? {
        return self.medium()
    }

    class func navBar() -> UIColor? {
        return self.medium()
    }

    class func navTint() -> UIColor? {
        return self.light()
    }

    class func navText() -> UIColor? {
        return self.background()
    }

    class func toolBar() -> UIColor? {
        return self.navBar()
    }

    class func toolTint() -> UIColor? {
        return self.navTint()
    }

    class func tabBar() -> UIColor? {
        return self.navBar()
    }

    class func tabTint() -> UIColor? {
        return self.navTint()
    }

    class func buttonTint() -> UIColor? {
        return self.medium()
    }

    class func textTint() -> UIColor? {
        return self.dark()
    }

    class func buttonHighlightedTint() -> UIColor? {
        return self.background()
    }

    class func destructiveTint() -> UIColor? {
        return self.destructive()
    }

    class func background() -> UIColor? {
        return self.white
    }

    class func whiteGray() -> UIColor? {
        return UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }

    class func textViewBorderGray() -> UIColor? {
        return UIColor(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 225.0 / 255.0, alpha: 1.0)
    }
    // FE

    class func formulaEditorOperator() -> UIColor? {
        return self.buttonTint()
    }

    class func formulaEditorHighlight() -> UIColor? {
        return self.buttonTint()
    }

    class func formulaEditorOperand() -> UIColor? {
        return self.buttonTint()
    }

    class func formulaEditorBorder() -> UIColor? {
        return self.light()
    }

    class func formulaButtonText() -> UIColor? {
        return self.light()
    }
    // Bricks & Scripts Colors

    class func brickSelectionBackground() -> UIColor? {
        return UIColor(red: 13.0 / 255.0, green: 13.0 / 255.0, blue: 13.0 / 255.0, alpha: 1.0)
    }

    class func lookBrickGreen() -> UIColor? {
        return UIColor(red: 57.0 / 255.0, green: 171.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
    }

    class func lookBrickStroke() -> UIColor? {
        return UIColor(red: 185.0 / 255.0, green: 220.0 / 255.0, blue: 110.0 / 255.0, alpha: 1.0)
    }

    class func motionBrickBlue() -> UIColor? {
        return UIColor(red: 29.0 / 255.0, green: 132.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)
    }

    class func motionBrickStroke() -> UIColor? {
        return UIColor(red: 179.0 / 255.0, green: 203.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    class func controlBrickOrange() -> UIColor? {
        return UIColor(red: 255.0 / 255.0, green: 120.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    }

    class func controlBrickStroke() -> UIColor? {
        return UIColor(red: 247.0 / 255.0, green: 208.0 / 255.0, blue: 187.0 / 255.0, alpha: 1.0)
    }

    class func variableBrickRed() -> UIColor? {
    }

    class func variableBrickStroke() -> UIColor? {
        return UIColor(red: 238.0 / 255.0, green: 149.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0)
    }

    class func soundBrickViolet() -> UIColor? {
        return UIColor(red: 180.0 / 255.0, green: 67.0 / 255.0, blue: 198.0 / 255.0, alpha: 1.0)
    }

    class func soundBrickStroke() -> UIColor? {
        return UIColor(red: 179.0 / 255.0, green: 137.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    class func phiroBrick() -> UIColor? {
        return UIColor(red: 234.0 / 255.0, green: 200.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
    }

    class func phiroBrickStroke() -> UIColor? {
        return UIColor(red: 179.0 / 255.0, green: 137.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    class func arduinoBrick() -> UIColor? {
        return UIColor(red: 234.0 / 255.0, green: 200.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
    }

    class func arduinoBrickStroke() -> UIColor? {
        return UIColor(red: 179.0 / 255.0, green: 137.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    // taken from https://github.com/anjerodesu/UIColor-ColorWithHex/blob/master/UIColor%2BColorWithHex.m

    convenience init(hex hexadecimal: UInt32) {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat

        // bitwise AND operation
        // hexadecimal's first 2 values
        red = CGFloat((Int(hexadecimal) >> 16) & 0xff)
        // hexadecimal's 2 middle values
        green = CGFloat((Int(hexadecimal) >> 8) & 0xff)
        // hexadecimal's last 2 values
        blue = CGFloat(Int(hexadecimal) & 0xff)

        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }

    // MARK: intern Colors

    class func light() -> UIColor? {
        return UIColor(hex: 0xadeef0)
    }

    class func medium() -> UIColor? {
        return UIColor(hex: 0x18a5b7)
    }

    class func dark() -> UIColor? {
        return UIColor(hex: 0x191919)
    }

    class func destructive() -> UIColor? {
        return UIColor(hex: 0xf26c4f)
    }

    // MARK: Global

    // MARK: FormulaEditor

    // MARK: IDE

    class func varibaleBrickRed() -> UIColor? {
        return UIColor(red: 234.0 / 255.0, green: 59.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
    }
}
