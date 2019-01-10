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

/**
 *  Available controls.
 */
enum BSKeyboardControl : Int {
    static let previousNext: BSKeyboardControl = 1 << 0
    static let done: BSKeyboardControl = 1 << 1
}

/**
 *  Directions in which the fields can be selected.
 *  These are relative to the active field.
 */
enum BSKeyboardControlsDirection : Int {
    case previous = 0
    case next
}

class BSKeyboardControls: UIView {
    /**
     *  Delegate to send callbacks to.
     */
    weak var delegate: BSKeyboardControlsDelegate?
    /**
     *  Visible controls. Use a bitmask to show multiple controls.
     */

    private var _visibleControls: BSKeyboardControl?
    var visibleControls: BSKeyboardControl? {
        get {
            return _visibleControls
        }
        set(visibleControls) {
            if visibleControls != _visibleControls {
                _visibleControls = visibleControls

                toolbar?.items = toolbarItems() as? [UIBarButtonItem]
            }
        }
    }
    /**
     *  Fields which the controls should handle.
     *  The order of the fields is important as this determines which text field
     *  is the previous and which is the next.
     *  All fields will automatically have the input accessory view set to
     *  the instance of the controls.
     */

    private var _fields: [Any] = []
    var fields: [Any] {
        get {
            return _fields
        }
        set(fields) {
            if fields != _fields {
                for field: UIView? in fields as? [UIView?] ?? [] {
                    if (field is UITextField) {
                        (field as? UITextField)?.inputAccessoryView = self
                    } else if (field is UITextView) {
                        (field as? UITextView)?.inputAccessoryView = self
                    } else if (field is iOSCombobox) {
                        (field as? iOSCombobox)?.inputAccessoryView = self
                    }
                }

                if let aFields = fields {
                    _fields = aFields
                }
            }
        }
    }
    /**
     *  The active text field.
     *  This should be set when the user begins editing a text field or a text view
     *  and it is automatically set when selecting the previous or the next field.
     */

    private var _activeField: UIView?
    var activeField: UIView? {
        get {
            return _activeField
        }
        set(activeField) {
            if (activeField as? UIView) != _activeField {
                if let aField = activeField {
                    if fields.contains(aField) {
                        _activeField = activeField as? UIView

                        if !(activeField?.isFirstResponder ?? false) {
                            activeField?.becomeFirstResponder()
                        }
                    }
                }
            }
        }
    }
    /**
     *  Style of the toolbar.
     */

    private var _barStyle: UIBarStyle?
    var barStyle: UIBarStyle? {
        get {
            return _barStyle
        }
        set(barStyle) {
            if barStyle != _barStyle {
                toolbar?.barStyle = barStyle!

                _barStyle = barStyle
            }
        }
    }
    /**
     *  Tint color of the toolbar.
     */

    private var _barTintColor: UIColor?
    var barTintColor: UIColor? {
        get {
            return _barTintColor
        }
        set(barTintColor) {
            if barTintColor != _barTintColor {
                if let aColor = barTintColor {
                    toolbar?.tintColor = aColor
                }

                _barTintColor = barTintColor
            }
        }
    }
    /**
     *  Tint color of the segmented control.
     */
    var segmentedControlTintControl: UIColor?
    /**
     *  Title of the previous button. If this is not set, a default localized title will be used.
     */
    var previousTitle = ""
    /**
     *  Title of the next button. If this is not set, a default localized title will be used.
     */
    var nextTitle = ""
    /**
     *  Title of the done button. If this is not set, a default localized title will be used.
     */

    private var _doneTitle = ""
    var doneTitle: String {
        get {
            return _doneTitle
        }
        set(doneTitle) {
            if !(doneTitle == _doneTitle) {
                doneButton?.title = doneTitle

                _doneTitle = doneTitle ?? ""
            }
        }
    }
    /**
     *  Tint color of the done button.
     */

    private var _doneTintColor: UIColor?
    var doneTintColor: UIColor? {
        get {
            return _doneTintColor
        }
        set(doneTintColor) {
            if doneTintColor != _doneTintColor {
                doneButton?.tintColor = doneTintColor

                _doneTintColor = doneTintColor
            }
        }
    }
    /**
     *  Initialize keyboard controls.
     *  @param fields Fields which the controls should handle.
     *  @return Initialized keyboard controls.
     */

    init(fields: [Any]?) {
        //if super.init(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 44.0))

        self.toolbar = UIToolbar(frame: frame)
        toolbar?.barStyle = .default
        toolbar?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        if let aToolbar = toolbar {
            addSubview(aToolbar)
        }

        // TODO: CONVERT NSLocaliz3edString("Done", tableName: "BSKeyboardControls", bundle: Bundle.main, value: "", comment: "Done button title.")
        self.doneButton = UIBarButtonItem(title: "Done",
                                          style: .done,
                                          target: self,
                                          action: #selector(BSKeyboardControls.doneButtonPressed(_:)))
        doneButton?.tintColor = UIColor.globalTint()

        setVisible([.previousNext, .done])

        self.fields = fields

    }
    private var toolbar: UIToolbar?
    private var doneButton: UIBarButtonItem?
    private var segmentedControlItem: UIBarButtonItem?

    // MARK: -

    // MARK: Lifecycle

    convenience override init() {
        self.init(fields: nil)
    }

    convenience override init(frame: CGRect) {
        self.init(fields: nil)
    }

    deinit {
        fields = nil
        self.segmentedControlTintControl = nil
        self.previousTitle = nil
        barTintColor = nil
        self.nextTitle = nil
        doneTitle = nil
        doneTintColor = nil
        activeField = nil
        self.toolbar = nil
        self.segmentedControlItem = nil
        self.doneButton = nil
    }

    // MARK: -

    // MARK: Public Methods

    // MARK: -

    // MARK: Private Methods

    func doneButtonPressed(_ sender: Any?) {
        if delegate?.responds(to: #selector(BSKeyboardControlsDelegate.keyboardControlsDonePressed(_:))) ?? false {
            delegate?.keyboardControlsDonePressed(self)
        }
    }

    func selectPreviousField() {
        var index: Int? = nil
        if let aField = activeField {
            index = (fields as NSArray).index(of: aField)
        }
        if (index ?? 0) > 0 {
            index -= 1
            let field = fields[index ?? 0] as? UIView
            activeField = field

            if delegate?.responds(to: #selector(BSKeyboardControlsDelegate.keyboardControls(_:selectedField:in:))) ?? false {
                delegate?.keyboardControls(self, selectedField: field, in: .previous)
            }
        }
    }

    func selectNextField() {
        var index: Int? = nil
        if let aField = activeField {
            index = (fields as NSArray).index(of: aField)
        }
        if (index ?? 0) < fields.count - 1 {
            index += 1
            let field = fields[index ?? 0] as? UIView
            activeField = field

            if delegate?.responds(to: #selector(BSKeyboardControlsDelegate.keyboardControls(_:selectedField:in:))) ?? false {
                delegate?.keyboardControls(self,
                                           selectedField: field, in: .next)
            }
        }
    }

    func toolbarItems() -> [Any]? {
        var items = [AnyHashable](repeating: 0, count: 1)


        if visibleControls.rawValue & BSKeyboardControl.done.rawValue != 0 {
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                         target: nil,
                                         action: nil))
            if let aButton = doneButton {
                items.append(aButton)
            }
        }

        return items
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol BSKeyboardControlsDelegate: NSObjectProtocol {
    /**
     *  Called when a field was selected by going to the previous or the next field.
     *  The implementation of this method should scroll to the view.
     *  @param keyboardControls The instance of keyboard controls.
     *  @param field The selected field.
     *  @param direction Direction in which the field was selected.
     */
    optional func keyboardControls(_ keyboardControls: BSKeyboardControls?,
                                         selectedField field: UIView?,
                                         in direction: BSKeyboardControlsDirection)
    /**
     *  Called when the done button was pressed.
     *  @param keyboardControls The instance of keyboard controls.
     */
    optional func keyboardControlsDonePressed(_ keyboardControls: BSKeyboardControls?)
}
