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

@objc protocol iOSComboboxDelegate: NSObjectProtocol {
    @objc optional func comboboxOpened(_ combobox: iOSCombobox?)
    @objc optional func comboboxClosed(_ combobox: iOSCombobox?, withValue value: String?)
    @objc optional func comboboxChanged(_ combobox: iOSCombobox?, toValue: String?)
    @objc optional func comboboxDonePressed(_ combobox: iOSCombobox?, withValue value: String?)
}

let BORDER_WIDTH = 1.0
let BORDER_OFFSET = BORDER_WIDTH / 2
let ARROW_BOX_WIDTH = 20.0
let ARROW_WIDTH = 10.0
let ARROW_HEIGHT = 10.0
let FONT_NAME = "Helvetica"
let TEXT_LEFT = 5.0
let PICKER_VIEW_HEIGHT = 216.0

class iOSCombobox: UIControl, UIPickerViewDataSource, UIPickerViewDelegate, iOSComboboxPickerViewDelegate, BSKeyboardControlsDelegate {
    var active = false
    static let totalHeight: CGFloat = 264.0

    private var _values: [Any] = []
    var values: [Any] {
        get {
            return _values
        }
        set(values) {
            if let aValues = values {
                _values = aValues
            }
            pickerView?.reloadAllComponents()
            if (_values as NSArray).index(of: currentValue) != NSNotFound {
                pickerView?.selectRow((_values as NSArray).index(of: currentValue), inComponent: 0, animated: false)
            }
        }
    }
    var images: [AnyHashable] = []
    var pickerView: UIPickerView?

    private var _currentValue = ""
    var currentValue: String {
        get {
            return _currentValue
        }
        set(currentValue) {
            _currentValue = currentValue ?? ""
            setNeedsDisplay()
            if (values as NSArray).index(of: currentValue ?? "") != NSNotFound {
                pickerView?.selectRow((values as NSArray).index(of: currentValue ?? ""), inComponent: 0, animated: false)
            }
        }
    }
    var currentImage: UIImage?
    var checkPath = ""
    var object: SpriteObject?
    weak var delegate: iOSComboboxDelegate?
    var keyboard: BSKeyboardControls?
    var inputView: UIView?
    var inputAccessoryView: UIView?
    /***********************************************************
     **  INITIALIZATION
     **********************************************************/

    override class func initialize() {
        active = false
        backgroundColor = UIColor.clear
        let pickerY = CGFloat(Double(UIScreen.main.bounds.size.height) - PICKER_VIEW_HEIGHT)
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        pickerView = iOSComboboxPickerView(frame: CGRect(x: 0.0, y: pickerY, width: screenWidth, height: CGFloat(PICKER_VIEW_HEIGHT)))
        pickerView?.showsSelectionIndicator = true
        pickerView?.dataSource = self
        pickerView?.delegate = self
        pickerView?.selectRow((values as NSArray).index(of: currentValue), inComponent: 0, animated: false)
        keyboard = BSKeyboardControls(fields: [self])
        keyboard?.delegate = self

        inputView = pickerView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    
    }

    override init() {
        super.init()
        
        initialize()
    
    }
    /***********************************************************
     **  DRAWING
     **********************************************************/

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.clear(rect)
        var baseSpace = CGColorSpaceCreateDeviceRGB()
        baseSpace = nil

        // ============================
        // Background gradient
        // ============================
        let newRect = CGRect(x: rect.origin.x + CGFloat(BORDER_OFFSET), y: rect.origin.y + CGFloat(BORDER_OFFSET), width: CGFloat(Double(rect.size.width) - BORDER_WIDTH), height: CGFloat(Double(rect.size.height) - BORDER_WIDTH))
        let background = UIBezierPath(roundedRect: newRect, cornerRadius: 5.0).cgPath
        ctx?.saveGState()
        ctx?.addPath(background)
        ctx?.clip()
        ctx?.restoreGState()

        // ===========================
        // Background behind arrow
        // ===========================
        ctx?.saveGState()
        ctx?.addPath(background)
        ctx?.clip()
        ctx?.clip(to: CGRect(x: CGFloat(Double(rect.size.width) - ARROW_BOX_WIDTH), y: CGFloat(BORDER_OFFSET), width: CGFloat(ARROW_BOX_WIDTH - Double(BORDER_OFFSET)), height: CGFloat(Double(rect.size.height) - BORDER_WIDTH)))

        ctx?.restoreGState()

        // ===========================
        // Border around the combobox
        // ===========================
        ctx?.saveGState()
        ctx?.setLineWidth(CGFloat(BORDER_WIDTH))
        CGContextSetLineCap(ctx!, CGLineCap.butt)
        ctx?.addPath(background)
        if active {
            ctx?.setStrokeColor(UIColor.globalTint()!.cgColor)
        } else {
            ctx?.setStrokeColor(UIColor.white.cgColor)
        }
        ctx?.drawPath(using: .stroke)
        ctx?.restoreGState()

        // ============================
        // Line separating arrow / text
        // ============================
        ctx?.saveGState()
        ctx?.setLineWidth(CGFloat(BORDER_WIDTH))
        if active {
            ctx?.setStrokeColor(UIColor.globalTint()!.cgColor)
        } else {
            ctx?.setStrokeColor(UIColor.white.cgColor)
        }
        ctx?.beginPath()
        ctx?.move(to: CGPoint(x: CGFloat(Double(rect.size.width) - ARROW_BOX_WIDTH), y: CGFloat(BORDER_WIDTH)))
        ctx?.addLine(to: CGPoint(x: CGFloat(Double(rect.size.width) - ARROW_BOX_WIDTH), y: CGFloat(Double(rect.size.height) - BORDER_WIDTH)))
        ctx?.strokePath()
        ctx?.restoreGState()

        // ============================
        // Draw the arrow
        // ============================
        ctx?.saveGState()

        let path = CGMutablePath()

        // the height of the triangle should be probably be about 40% of the height
        // of the overall rectangle, based on the Safari dropdown
        let centerX = CGFloat(Double(rect.size.width) - (ARROW_BOX_WIDTH / 2) - Double(BORDER_OFFSET))
        let centerY = rect.size.height / 2 + CGFloat(BORDER_OFFSET)
        let arrowY = CGFloat(Double(centerY) - (ARROW_HEIGHT / 2))

        path.move(to: CGPoint(x: CGFloat(Double(centerX) - (ARROW_WIDTH / 2)), y: arrowY), transform: .identity)
        path.addLine(to: CGPoint(x: CGFloat(Double(centerX) + (ARROW_WIDTH / 2)), y: arrowY), transform: .identity)
        path.addLine(to: CGPoint(x: centerX, y: CGFloat(Double(arrowY) + ARROW_HEIGHT)), transform: .identity)
        CGPathCloseSubpath(path)

        if active {
            ctx?.setFillColor(UIColor.globalTint().cgColor)
        } else {
            ctx?.setFillColor(UIColor.white.cgColor)
        }

        ctx?.addPath(path)
        ctx?.fillPath()
        ctx?.restoreGState()
        // ==============================
        // Draw the image
        // ==============================
        if currentImage != nil {
            ctx?.saveGState()

            let path = CGMutablePath()

            // the height of the triangle should be probably be about 40% of the height
            // of the overall rectangle, based on the Safari dropdown
            let centerX = rect.size.width - CGFloat(-20 as? ARROW_BOX_WIDTH ?? 0.0) - CGFloat(BORDER_OFFSET)
            let centerY = rect.size.height / 2 + CGFloat(BORDER_OFFSET)

            var newHeight: Float = 20
            var newWidth: Float = 20
            if (currentImage?.size.height ?? 0.0) > (currentImage?.size.width ?? 0.0) {
                newWidth = Float((((currentImage?.size.width ?? 0.0) / (currentImage?.size.height ?? 0.0)) * 20))
            } else {
                newHeight = Float((((currentImage?.size.height ?? 0.0) / (currentImage?.size.width ?? 0.0)) * 20))
            }
            currentImage?.draw(in: CGRect(x: centerX - CGFloat((newWidth / 2)), y: centerY - CGFloat((newHeight / 2)), width: CGFloat(newWidth), height: CGFloat(newHeight)))

            ctx?.addPath(path)
            ctx?.fillPath()
            ctx?.restoreGState()
        }

        // ==============================
        // Draw the text
        // ==============================
        if currentValue == nil && values.count > 0 {
            currentValue = values[0] as? String
        }
        var attributes: [AnyHashable : Any]? = nil
        if let aHeight = UIFont(name: FONT_NAME, size: rect.size.height / 2) {
            attributes = [
            .font : aHeight,
            .foregroundColor : UIColor.white
        ]
        }
        var size: CGSize? = nil
        if let aHeight = UIFont(name: FONT_NAME, size: rect.size.height / 2) {
            size = currentValue.size(attributes: [NSAttributedString.Key.font: aHeight])
        }
        var drawString = currentValue
        if Double(size?.width ?? 0.0) > Double(rect.size.width) - ARROW_BOX_WIDTH - TEXT_LEFT - 30 {
            let clipLength: Int = 28
            if drawString.count > clipLength {
                drawString = "\((drawString as? NSString)?.substring(to: clipLength) ?? "")..."
            }
        }
        drawString.draw(in: CGRect(x: CGFloat(TEXT_LEFT), y: rect.size.height / 2 - rect.size.height / 3, width: CGFloat(Double(rect.size.width) - ARROW_BOX_WIDTH - TEXT_LEFT - 30), height: CGFloat(Double(rect.size.height) - BORDER_WIDTH)), withAttributes: attributes as? [NSAttributedStringKey : Any])
    }
    /***********************************************************
     **  DATA SOURCE FOR UIPICKERVIEW
     **********************************************************/
    func setCurrentImagee(_ image: UIImage?) {
        currentImage = image
        setNeedsDisplay()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row] as? String
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: Util.screenWidth(), height: 60))
        var imageOffset: CGFloat = 0.0
        let rowOffset: CGFloat = 30.0

        if images.count > 0 {
            imageOffset = 30.0
        }
        if images.count >= row {
            if row != 0 {
                let img = images[row - 1] as? UIImage
                let temp = UIImageView(image: img)
                temp.contentMode = .scaleAspectFit
                temp.frame = CGRect(x: rowOffset / 2, y: 15, width: imageOffset, height: imageOffset)
                tmpView.insertSubview(temp, at: 0)
            }
        }

        let channelLabel = UILabel(frame: CGRect(x: imageOffset + rowOffset, y: 0, width: Util.screenWidth() - imageOffset - (2 * rowOffset), height: 60))
        channelLabel.text = values[row] as? String
        channelLabel.textAlignment = .left
        channelLabel.backgroundColor = UIColor.clear

        tmpView.insertSubview(channelLabel, at: 1)

        return tmpView
    }
    /***********************************************************
     **  UIPICKERVIEW DELEGATE COMMANDS
     **********************************************************/

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentValue = (values[row] as? String)!
        if row > 0 {
            self.currentImage = images[row - 1] as? UIImage
        } else {
            setCurrentImagee(nil)
        }

        setNeedsDisplay()

        if delegate?.responds(to: #selector(iOSComboboxDelegate.comboboxChanged(_:toValue:))) ?? false {
            delegate?.comboboxChanged!(self, toValue: values[row] as? String)
        }
    }

    func pickerViewClosed(_ pickerView: UIPickerView?) {
        if delegate?.responds(to: #selector(iOSComboboxDelegate.comboboxClosed(_:withValue:))) ?? false {
            delegate?.comboboxClosed!(self, withValue: currentValue)
        }
    }
    /***********************************************************
     **  FIRST RESPONDER AND USER INTERFACE
     **********************************************************/

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        if currentImage != nil {
            addLookData()
        }

        becomeFirstResponder()
        return false
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var canResignFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        active = true
        keyboard?.activeField = self
        setNeedsDisplay()

        if delegate?.responds(to: #selector(iOSComboboxDelegate.comboboxOpened(_:))) ?? false {
            delegate?.comboboxOpened(self)
        }

        return true
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        images = nil
        active = false
        setNeedsDisplay()

        return true
    }

    @objc func keyboardControlsDonePressed(_ keyboardControls: BSKeyboardControls?) {
        if delegate?.responds(to: #selector(iOSComboboxDelegate.comboboxDonePressed(_:withValue:))) ?? false {
            delegate?.comboboxDonePressed(self, withValue: currentValue)
        }
        keyboardControls?.activeField.resignFirstResponder()
        resignFirstResponder()
    }

    func addLookData() {
        images = [AnyHashable](repeating: 0, count: object?.lookList.count ?? 0)
        let count: Int = 0
        for look: Look? in (object?.lookList)! {
            var path: String? = nil
            if let aPath = object?.projectPath(), let aName = look?.fileName {
                path = "\(aPath)\(kProgramImagesDirName)/\(aName)"
            }
            let imageCache = RuntimeImageCache.shared()
            let image: UIImage? = imageCache.cachedImage(forPath: path)
            if image == nil {
                imageCache.loadImageFromDisk(withPath: path, onCompletion: { image, path in
                    if self.checkPath == path {
                        self.addLookData()
                        self.setNeedsDisplay()
                        self.pickerView?.reloadAllComponents()
                        self.pickerView?.reloadInputViews()
                    }
                })
            }
            if image != nil {
                if let anImage = image {
                    images.append(anImage)
                }
            } else {
                checkPath = path ?? ""
                images.append(UIImage())
            }
            count += 1
        }
    }
}

