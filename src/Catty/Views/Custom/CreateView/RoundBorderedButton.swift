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

class RoundBorderedButton: UIButton {
    func setPlusIconVisibility(_ show: Bool) {
        plusIconVisible = show
    }

    init(frame: CGRect, andBorder visibleBorder: Bool) {
        super.init(frame: frame)
        
        self.visibleBorder = visibleBorder
        setup()
    
    }
    private var plusIconVisible = false
    private var visibleBorder = false

    required init() {
        super.init(frame: .zero)
        
        visibleBorder = true
        setup()
    
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    
    }

    func setup() {
        setTitleColor(tintColor, for: .normal)
        setTitleColor(UIColor.white, for: .highlighted)
        setTitleColor(UIColor.gray, for: .disabled)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        if visibleBorder {
            layer.cornerRadius = 3.5
            layer.borderWidth = 1.0
        }
        refreshBorderColor()
    }

    override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set(tintColor) {
            super.tintColor = tintColor
            setTitleColor(tintColor, for: .normal)
            refreshBorderColor()
        }
    }

    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set(enabled) {
            super.isEnabled = enabled
    
            refreshBorderColor()
        }
    }

    func refreshBorderColor() {
        layer.borderColor = isEnabled ? tintColor.cgColor : UIColor.gray.cgColor
    }

    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set(highlighted) {
            super.isHighlighted = highlighted
    
            UIView.animate(withDuration: 0.05, animations: {
                self.layer.backgroundColor = highlighted ? self.tintColor.cgColor : UIColor.clear.cgColor
            })
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let org: CGSize = super.sizeThatFits(bounds.size)
        return CGSize(width: org.width + 20, height: org.height - 2)
    }
}
