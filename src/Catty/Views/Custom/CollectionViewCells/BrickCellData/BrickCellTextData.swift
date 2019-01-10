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

class BrickCellTextData: UITextField, BrickCellDataProtocol, UITextFieldDelegate {
    weak var brickCell: BrickCell?
    var lineNumber: Int = 0
    var parameterNumber: Int = 0

    private var border: CAShapeLayer?
    let BORDER_WIDTH: CGFloat = 1.0
    let BORDER_HEIGHT: CGFloat = 4
    let BORDER_TRANSPARENCY: CGFloat = 0.9
    let BORDER_PADDING: CGFloat = 3.8

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
            
            border?.strokeColor = UIColor.globalTint()!.cgColor
            
            border?.shadowColor = UIColor.globalTint()!.cgColor
            border?.shadowRadius = 1
            border?.shadowOpacity = 1.0
            border?.shadowOffset = CGSize(width: 0, height: 0)
        } else {
            
            let borderColor = UIColor.controlBrickStroke()
            border?.strokeColor = borderColor!.cgColor
        }
        
        if let aBorder = border {
            layer.addSublayer(aBorder)
        }
    }
    
    func update() {
        let frame: CGRect = self.frame
        sizeToFit()
        correctHeightAndWidth(Int(frame.size.height))
        setNeedsDisplay()
        drawBorder(false)
    }
    
    required init(frame: CGRect, andBrickCell brickCell: BrickCell?, andLineNumber line: Int, andParameterNumber parameter: Int) {
        //if super.init(frame: frame)
        
        self.brickCell = brickCell
        lineNumber = line
        parameterNumber = parameter
        let textBrick = brickCell?.scriptOrBrick as? (Brick & BrickTextProtocol)
        text = textBrick?.text(forLineNumber: line, andParameterNumber: parameter)
        
        borderStyle = .none
        font = UIFont.systemFont(ofSize: CGFloat(kBrickTextFieldFontSize))
        autocorrectionType = .no
        keyboardType = .default
        returnKeyType = .done
        clearButtonMode = .whileEditing
        contentVerticalAlignment = .center
        //        self.userInteractionEnabled = NO;
        textColor = UIColor.white
        
        sizeToFit()
        
        let availableHeightWithBorder = Int(frame.size.height + CGFloat(2) * BORDER_WIDTH)
        
        correctHeightAndWidth(availableHeightWithBorder)
        
        setNeedsDisplay()
        drawBorder(false)
        
        delegate = self
        addTarget(self, action: #selector(BrickCellTextData.textFieldDone(_:)), for: .editingDidEndOnExit)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BrickCellTextData.keyboardDidAppear(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidAppear(_ notification: Notification?) {
        if isFirstResponder {
            let keyboardInfo = notification?.userInfo
            let keyboardFrameBegin = keyboardInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
            let keyboardFrameBeginRect: CGRect? = keyboardFrameBegin?.cgRectValue
            brickCell?.dataDelegate?.disableUserInteractionAndHighlight(brickCell, withMarginBottom: (keyboardFrameBeginRect?.size.height)!)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = bounds
        bounds.origin.x += 5
        bounds.size.width -= 6
        return bounds
    }
    
    func correctHeightAndWidth(_ availableHeight: Int) {
        if frame.size.height < CGFloat(availableHeight) {
            var newFrame: CGRect = frame
            newFrame.size.height = CGFloat(availableHeight)
            frame = newFrame
        }
        if frame.origin.x + frame.size.width + 60 > Util.screenWidth() {
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: Util.screenWidth() - 60 - frame.origin.x, height: frame.size.height)
        }
    }
    
    // MARK: - delegates
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    @objc func textFieldDone(_ sender: Any?) {
        resignFirstResponder()
        brickCell?.dataDelegate?.updateBrickCellData(self, withValue: text)
        update()
    }
    
    // MARK: - User interaction
    
    func isUserInteractionEnabled() -> Bool {
        return brickCell?.scriptOrBrick?.animateInsertBrick == false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
