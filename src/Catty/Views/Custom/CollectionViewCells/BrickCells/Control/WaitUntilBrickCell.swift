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

class WaitUntilBrickCell: BrickCell {
    weak var waitConditionTextField: UITextField?
    private var leftTextLabel: UILabel?
    private var rightTextLabel: UILabel?
    
    override func draw(_ rect: CGRect) {
        BrickShapeFactory.drawSquareBrickShape(withFill: UIColor.controlBrickOrange(),
                                               stroke: UIColor.controlBrickStroke(),
                                               height: CGFloat(smallBrick),
                                               width: Util.screenWidth())
    }
    
    override func hookUpSubViews(_ inlineViewSubViews: [Any]?) {
        leftTextLabel = inlineViewSubViews?[0] as? UILabel
        waitConditionTextField = inlineViewSubViews?[1] as? UITextField
        rightTextLabel = inlineViewSubViews?[2] as? UILabel
    }
}
