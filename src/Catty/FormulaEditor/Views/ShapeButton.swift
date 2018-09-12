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

enum ShapeButtonType : Int {
    case backSpace = 0
}

@IBDesignable
class ShapeButton: UIButton {
    @IBInspectable private var _shapeType: Int = 0
    @IBInspectable var shapeType: Int {
        get {
            return _shapeType
        }
        set(shapeType) {
            if shapeType >= 0 {
                _shapeType = shapeType
                internalType = ShapeButtonType(rawValue: shapeType)
            }
        }
    }
    /* Adapter for IB shape enum */
    @IBInspectable private var _lineWidth: CGFloat = 0.0
    @IBInspectable var lineWidth: CGFloat {
        get {
            return _lineWidth
        }
        set(lineWidth) {
            _lineWidth = lineWidth
            
            if buttonShapeLayer != nil {
                buttonShapeLayer?.lineWidth = lineWidth
            }
        }
    }
    /* Default 1 */
    @IBInspectable private var _shapeStrokeColor: UIColor?
    @IBInspectable var shapeStrokeColor: UIColor? {
        get {
            return _shapeStrokeColor
        }
        set(shapeStrokeColor) {
            _shapeStrokeColor = shapeStrokeColor
            
            if buttonShapeLayer != nil {
                buttonShapeLayer?.strokeColor = shapeStrokeColor?.cgColor
            }
        }
    }
    /* Default white */
    @IBInspectable private var _buttonInsets: UIEdgeInsets = UIEdgeInsets.zero
    @IBInspectable var buttonInsets: UIEdgeInsets {
        get {
            return _buttonInsets
        }
        set(buttonInsets) {
            _buttonInsets = buttonInsets
            
            if buttonShapeLayer != nil {
                setup()
            }
        }
    }
    // Default top:10, left:28, bottom:10, right:24
    private var _internalType: ShapeButtonType?
    private var internalType: ShapeButtonType? {
        get {
            return _internalType
        }
        set(internalType) {
            _internalType = internalType
            setup()
        }
    }
    private var backGroundLayer: CALayer?
    private var buttonShapeLayer: CAShapeLayer?
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds: CGRect = self.bounds
        backGroundLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: NSObject
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultSetup()
    }
    
    // MARK: Private
    func setup() {
        var shapeLayer: CAShapeLayer? = nil
        
        switch internalType {
        case .backSpace?:
            shapeLayer = backSpaceShapeLayer()
        default:
            break
        }
        
        buttonShapeLayer = shapeLayer
        weak var weakself: ShapeButton? = self
        UIView.performWithoutAnimation({
            weakself?.backGroundLayer?.removeFromSuperlayer()
            weakself?.layer.sublayers = nil
            if let aLayer = weakself?.backGroundLayer {
                weakself?.layer.addSublayer(aLayer)
            }
            if let aLayer = weakself?.buttonShapeLayer {
                weakself?.backGroundLayer?.addSublayer(aLayer)
            }
            weakself?.layoutIfNeeded()
        })
    }
    
    func defaultSetup() {
        lineWidth = 1.0
        shapeStrokeColor = UIColor.white
        buttonInsets = UIEdgeInsetsMake(10.0, 28.0, 10.0, 24.0)
    }
    
    func backSpaceShapeLayer() -> CAShapeLayer? {
        backGroundLayer = CALayer()
        backGroundLayer?.frame = bounds
        backGroundLayer?.backgroundColor = UIColor.clear.cgColor
        if let aLayer = backGroundLayer {
            layer.addSublayer(aLayer)
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = shapeStrokeColor?.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.miterLimit = 2.0
        
        let pathOffsetX: CGFloat? = buttonInsets.right
        let pathOffsetY: CGFloat? = buttonInsets.top
        let shapeRect: CGRect = (backGroundLayer?.bounds.insetBy(dx: pathOffsetX ?? 0.0, dy: pathOffsetY ?? 0.0))!
        let diffLeftRight = abs((buttonInsets.left) - (buttonInsets.right))
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (buttonInsets.left) - diffLeftRight, y: shapeRect.height / 2 + (pathOffsetY ?? 0.0)))
        path.addLine(to: CGPoint(x: shapeRect.width / 2 + (pathOffsetX ?? 0.0) - diffLeftRight, y: pathOffsetY ?? 0.0))
        path.addLine(to: CGPoint(x: shapeRect.width + (pathOffsetX ?? 0.0), y: pathOffsetY ?? 0.0))
        path.addLine(to: CGPoint(x: shapeRect.width + (pathOffsetX ?? 0.0), y: shapeRect.height + (pathOffsetY ?? 0.0)))
        path.addLine(to: CGPoint(x: shapeRect.width / 2 + (pathOffsetX ?? 0.0) - diffLeftRight, y: shapeRect.height + (pathOffsetY ?? 0.0)))
        path.close()
        
        let leftLinePath = UIBezierPath()
        leftLinePath.move(to: CGPoint(x: shapeRect.midX - 4.0 + diffLeftRight, y: shapeRect.midY + 4.0))
        leftLinePath.addLine(to: CGPoint(x: shapeRect.midX + 4.0 + diffLeftRight, y: shapeRect.midY - 4.0))
        leftLinePath.close()
        path.append(leftLinePath)
        
        let rightLinePath: UIBezierPath = leftLinePath
        let mirror = CGAffineTransform(scaleX: 1.0, y: -1.0)
        let translate = CGAffineTransform(translationX: 0.0, y: bounds.height)
        rightLinePath.apply(mirror)
        rightLinePath.apply(translate)
        path.append(rightLinePath)
        
        shapeLayer.path = path.cgPath
        
        return shapeLayer
    }
}
