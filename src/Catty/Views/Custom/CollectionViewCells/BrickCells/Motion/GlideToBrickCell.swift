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

class GlideToBrickCell: BrickCell {
    weak var durationTextField: UITextField?
    weak var xCoordTextField: UITextField?
    weak var yCoordTextField: UITextField?
    private var firstRowLeftLabel: UILabel?
    private var firstRowRightLabel: UILabel?
    private var secondRowLeftLabel: UILabel?
    private var secondRowRightLabel: UILabel?
    
    override func draw(_ rect: CGRect) {
        BrickShapeFactory.drawSquareBrickShape(withFill: UIColor.motionBrickBlue(),
                                               stroke: UIColor.motionBrickStroke(),
                                               height: CGFloat(largeBrick),
                                               width: Util.screenWidth())
    }
    
    override func cellHeight() -> CGFloat {
        return BrickHeightType.height3.rawValue
    }
    
    override func hookUpSubViews(_ inlineViewSubViews: [Any]?) {
        firstRowLeftLabel = inlineViewSubViews?[0] as? UILabel
        durationTextField = inlineViewSubViews?[1] as? UITextField
        firstRowRightLabel = inlineViewSubViews?[2] as? UILabel
        secondRowLeftLabel = inlineViewSubViews?[3] as? UILabel
        xCoordTextField = inlineViewSubViews?[4] as? UITextField
        secondRowRightLabel = inlineViewSubViews?[5] as? UILabel
        yCoordTextField = inlineViewSubViews?[6] as? UITextField
    }
}
