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

class BrickCellFormulaData: UIButton, BrickCellDataProtocol, FormulaEditorViewControllerDelegate {
    weak var brickCell: BrickCell?
    var lineNumber: Int = 0
    var parameterNumber: Int = 0

    let BORDER_WIDTH: CGFloat = 1.0
    let BORDER_HEIGHT: CGFloat = 4
    let BORDER_TRANSPARENCY: CGFloat = 0.9
    let BORDER_PADDING: CGFloat = 3.8

    let FORMULA_MAX_LENGTH = 15
    
    func drawBorder(_ isActive: Bool) {
        if border != nil {
            border?.removeFromSuperlayer()
        }
        
        border = CAShapeLayer()
        
        let borderPath = UIBezierPath()
        
        var startPoint = CGPoint(x: bounds.maxX, y: bounds.maxY - BORDER_PADDING)
        var endPoint = CGPoint(x: bounds.maxX, y: bounds.maxY - BORDER_PADDING - BORDER_HEIGHT)
        borderPath.move(to: startPoint)
        borderPath.addLine(to: endPoint)
        
        startPoint = CGPoint(x: 0, y: bounds.maxY - BORDER_PADDING)
        endPoint = CGPoint(x: 0, y: bounds.maxY - BORDER_PADDING - BORDER_HEIGHT)
        borderPath.move(to: startPoint)
        borderPath.addLine(to: endPoint)
        
        startPoint = CGPoint(x: -BORDER_WIDTH / 2, y: bounds.maxY - BORDER_PADDING)
        endPoint = CGPoint(x: bounds.maxX + BORDER_WIDTH / 2, y: bounds.maxY - BORDER_PADDING)
        borderPath.move(to: startPoint)
        borderPath.addLine(to: endPoint)
        
        border?.frame = bounds
        border?.path = borderPath.cgPath
        border?.lineWidth = CGFloat(BORDER_WIDTH)
        border?.opacity = Float(BORDER_TRANSPARENCY)
        
        if isActive {
            border?.strokeColor = UIColor.background()!.cgColor
            border?.shadowColor = UIColor.clear.cgColor
            border?.shadowRadius = 1
            border?.shadowOpacity = 1.0
            border?.shadowOffset = CGSize(width: 0, height: 0)
        } else {
            let borderColor: UIColor? = kBrickCategoryStrokeColors[((brickCell?.scriptOrBrick?.brickCategoryType?.rawValue)! - 1)]
            //        UIColor *borderColor = self.brickCell.brickCategoryColors[self.brickCell.scriptOrBrick.brickCategoryType-1];
            border?.strokeColor = borderColor?.cgColor
        }
        
        if let aBorder = border {
            layer.addSublayer(aBorder)
        }
    }
    
    func formula() -> Formula? {
        let formulaBrick = brickCell?.scriptOrBrick as? (Brick & BrickFormulaProtocol)
        return formulaBrick?.formula(forLineNumber: lineNumber, andParameterNumber: parameterNumber)
    }
    private var border: CAShapeLayer?
    
    required init(frame: CGRect, andBrickCell brickCell: BrickCell?, andLineNumber line: Int, andParameterNumber parameter: Int) {
        let formulaBrick = brickCell?.scriptOrBrick as? (Brick & BrickFormulaProtocol)
        let formula: Formula? = formulaBrick?.formula(forLineNumber: line, andParameterNumber: parameter)
        
        //if super.init(frame: frame)
        
        self.brickCell = brickCell
        lineNumber = line
        parameterNumber = parameter
        
        titleLabel?.textColor = UIColor.white
        titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(kBrickTextFieldFontSize))
        titleLabel?.lineBreakMode = .byTruncatingTail
        setTitle(formula?.getDisplayString(), for: .normal)
        
        sizeToFit()
        if self.frame.size.width >= kBrickInputFieldMaxWidth {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: kBrickInputFieldMaxWidth, height: self.frame.size.height)
            titleLabel?.frame = CGRect(x: titleLabel?.frame.origin.x ?? 0.0, y: titleLabel?.frame.origin.y ?? 0.0, width: kBrickInputFieldMaxWidth, height: titleLabel?.frame.size.height ?? 0.0)
            titleLabel?.numberOfLines = 1
            titleLabel?.adjustsFontSizeToFitWidth = true
            titleLabel?.lineBreakMode = .byTruncatingTail
            titleLabel?.minimumScaleFactor = 10.0 / (titleLabel?.font.pointSize ?? 0.0)
        } else if (brickCell is PlaceAtBrickCell) || (brickCell is GlideToBrickCell) {
            if self.frame.size.width > Util.screenWidth() / 4.0 {
                var labelFrame: CGRect = self.frame
                labelFrame.size.width = Util.screenWidth() / 4.0
                self.frame = labelFrame
            }
        } else {
            titleLabel?.numberOfLines = 1
            titleLabel?.lineBreakMode = .byTruncatingTail
            titleLabel?.adjustsFontSizeToFitWidth = true
            titleLabel?.minimumScaleFactor = 11.0 / (titleLabel?.font.pointSize ?? 0.0)
        }
        
        var labelFrame: CGRect = self.frame
        labelFrame.size.height = self.frame.size.height
        self.frame = labelFrame
        
        drawBorder(false)
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        var title = title
        if (title?.count ?? 0) > FORMULA_MAX_LENGTH {
            title = "\((title as NSString?)?.substring(to: FORMULA_MAX_LENGTH) ?? "")..."
        }
        
        title = " \(title ?? "") "
        super.setTitle(title, for: state)
    }
    
    // MARK: - Delegate
    
    func save(_ formula: Formula?) {
        self.formula()?.setRoot(formula?.formulaTree)
        brickCell?.dataDelegate?.updateBrickCellData(self, withValue: self.formula())
    }
    
    // MARK: - User interaction
    
    func isUserInteractionEnabled() -> Bool {
        return brickCell?.scriptOrBrick?.animateInsertBrick == false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
