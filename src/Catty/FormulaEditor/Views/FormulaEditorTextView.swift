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

class FormulaEditorTextView: UITextView, UITextViewDelegate {
    private weak var formulaEditorViewController: FormulaEditorViewController?
    private var backspaceButton: UIButton?
    private var _tapRecognizer: UITapGestureRecognizer?
    private var tapRecognizer: UITapGestureRecognizer? {
        if _tapRecognizer == nil {
            _tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FormulaEditorTextView.formulaTapped(_:)))
        }
        return _tapRecognizer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, andFormulaEditorViewController formulaEditorViewController: FormulaEditorViewController?) {
        let rect = CGRect(x: frame.origin.x + 5, y: frame.origin.y + 2, width: frame.size.width - 10, height: frame.size.height)
        super.init(frame: rect, textContainer:nil)
        self.formulaEditorViewController = formulaEditorViewController
        
        delegate = self
        gestureRecognizers = nil
        //self.selectable = NO;
        if let aRecognizer = tapRecognizer {
            addGestureRecognizer(aRecognizer)
        }
        tapRecognizer?.delegate = (self as! UIGestureRecognizerDelegate)
        tapRecognizer?.cancelsTouchesInView = false
        inputView = Bundle.main.loadNibNamed("FormulaEditor", owner: self.formulaEditorViewController, options: nil)?.last as? UIView
        inputView?.backgroundColor = UIColor.background()
        isUserInteractionEnabled = true
        autocorrectionType = .no
        backgroundColor = UIColor.white
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 1
        font = UIFont.boldSystemFont(ofSize: 20.0)
        
        contentInset = .zero
        textContainerInset = UIEdgeInsetsMake(CGFloat(TEXT_FIELD_PADDING_VERTICAL), CGFloat(TEXT_FIELD_PADDING_HORIZONTAL), CGFloat(TEXT_FIELD_PADDING_VERTICAL), CGFloat(TEXT_FIELD_PADDING_HORIZONTAL) + CGFloat(BACKSPACE_WIDTH))
        
        backspaceButton = UIButton()
        backspaceButton?.setImage(UIImage(named: "del_active"), for: .normal)
        backspaceButton?.setImage(UIImage(named: "del"), for: .disabled)
        backspaceButton?.tintColor = UIColor.globalTint()
        backspaceButton?.frame = CGRect(x: self.frame.size.width - CGFloat(BACKSPACE_WIDTH), y: 0, width: CGFloat(BACKSPACE_HEIGHT), height: CGFloat(BACKSPACE_WIDTH))
        backspaceButton?.addTarget(self, action: #selector(FormulaEditorTextView.clear), for: .touchUpInside)
        if let aButton = backspaceButton {
            addSubview(aButton)
        }
        
    }
    
    func update() {
        formulaEditorViewController?.internFormula?.generateExternFormulaStringAndInternExternMapping()
        formulaEditorViewController?.internFormula?.updateInternCursorPosition()
        let formulaString = NSMutableAttributedString(string: formulaEditorViewController?.internFormula?.getExternFormulaString() ?? "", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)])
        
        attributedText = formulaString
        //[self.formulaEditorViewController.internFormula setCursorAndSelection:(int)[self.formulaEditorViewController.internFormula getExternCursorPosition] selected:NO];
        
        let select:Int = (Int(formulaEditorViewController?.internFormula!.getExternCursorPosition() ?? 0));
        let startPos:Int = (Int(formulaEditorViewController?.internFormula!.getExternSelectionStartIndex() ?? 0));
        let endPos:Int = (Int(formulaEditorViewController?.internFormula!.getExternSelectionEndIndex() ?? 0));
        highlightSelection(select, start:startPos, end:endPos)
        
        if ((formulaEditorViewController?.internFormula?.isEmpty) != nil) {
            backspaceButton?.isHidden = true
            formulaEditorViewController?.updateDeleteButton(false)
        } else {
            backspaceButton?.isHidden = false
            formulaEditorViewController?.updateDeleteButton(true)
        }
    }
    
    func highlightSelection(_ cursorPostionIndex: Int, start startIndex: Int, end endIndex: Int) {
        let selectionType:TokenSelectionType = (formulaEditorViewController?.internFormula?.getExternSelectionType())!
        var selectionColor: UIColor?
        if selectionType.rawValue == PARSER_ERROR_SELECTION.rawValue {
            selectionColor = UIColor.red
        } else {
            selectionColor = UIColor.globalTint()
        }
        
        let formulaString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)])
        
        let beginning: UITextPosition = beginningOfDocument
        let cursorPositionStart: UITextPosition? = position(from: beginning, offset: startIndex)
        let cursorPositionEnd: UITextPosition? = position(from: beginning, offset: endIndex)
        
        var location: Int? = nil
        if let aStart = cursorPositionStart {
            location = offset(from: beginning, to: aStart)
        }
        var length: Int? = nil
        if let aStart = cursorPositionStart, let anEnd = cursorPositionEnd {
            length = offset(from: aStart, to: anEnd)
        }
        
        //NSDebug("tap from %d to %d!", startIndex, endIndex)
        
        if startIndex == endIndex {
            attributedText = formulaString
            let cursorPosition: UITextPosition? = position(from: beginningOfDocument, offset: cursorPostionIndex)
            if let aPosition = cursorPosition {
                selectedTextRange = textRange(from: aPosition, to: aPosition)
            }
        } else {
            if let aColor = selectionColor {
                formulaString.addAttribute(.backgroundColor, value: aColor, range: NSRange(location: location ?? 0, length: length ?? 0))
            }
            let cursorPosition: UITextPosition? = position(from: beginningOfDocument, offset: endIndex)
            attributedText = formulaString
            if let aPosition = cursorPosition {
                selectedTextRange = textRange(from: aPosition, to: aPosition)
            }
        }
    formulaEditorViewController?.history?.updateCurrentSelection(formulaEditorViewController?.internFormula?.getSelection())

    formulaEditorViewController?.history?.updateCurrentCursor(Int32(cursorPostionIndex))
    }
    
    func setParseErrorCursorAndSelection() {
        formulaEditorViewController?.internFormula?.selectParseErrorTokenAndSetCursor()
        let startIndex = (Int(formulaEditorViewController?.internFormula?.getExternSelectionStartIndex() ?? 0))
        let endIndex = (Int(formulaEditorViewController?.internFormula?.getExternSelectionEndIndex() ?? 0))
        let cursorPostionIndex:Int = (Int(formulaEditorViewController?.internFormula?.getExternCursorPosition() ?? 0))
        highlightSelection(cursorPostionIndex, start:startIndex, end:endIndex)
    }
    
    let TEXT_FIELD_PADDING_HORIZONTAL = 5.0
    let TEXT_FIELD_PADDING_VERTICAL = 10.0
    let TEXT_FIELD_MARGIN_BOTTOM = 2.0
    let BACKSPACE_HEIGHT = 28.0
    let BACKSPACE_WIDTH = 28.0
    
    // MARK: - TextField properties
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return false
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    func isTextSelectable() -> Bool {
        return false
    }
    
    func isHighlighted() -> Bool {
        return false
    }
    
    func isTracking() -> Bool {
        return false
    }
    
    @objc func clear() {
        while !text.isEqual("") {
            formulaEditorViewController?.backspace(nil)
        }
    }
    
    @objc func formulaTapped(_ recognizer: UITapGestureRecognizer?) {
        let formulaView = recognizer?.view as? UITextView
        var point: CGPoint? = recognizer?.location(in: formulaView)
        point?.x -= formulaView?.textContainerInset.left ?? 0.0
        point?.y -= formulaView?.textContainerInset.top ?? 0.0
        var fraction: CGFloat = 0.0
        
        
        let layoutManager: NSLayoutManager? = formulaView?.layoutManager
        var cursorPostionIndex: Int? = nil
        if let aContainer = formulaView?.textContainer {
            cursorPostionIndex = layoutManager?.characterIndex(for: point ?? CGPoint.zero, in: aContainer, fractionOfDistanceBetweenInsertionPoints:&fraction)
        }
        if fraction > 0.5 {
            cursorPostionIndex = (cursorPostionIndex ?? 0) + 1
        }
        formulaEditorViewController?.internFormula?.setCursorAndSelection(Int32(Int(cursorPostionIndex ?? 0)), selected: false)
        let startIndex = formulaEditorViewController?.internFormula?.getExternSelectionStartIndex()
        let endIndex = formulaEditorViewController?.internFormula?.getExternSelectionEndIndex()
        
        highlightSelection(cursorPostionIndex ?? 0, start: Int(startIndex ?? 0), end: Int(endIndex ?? 0))
    }
    
    func highlightAll() {
    }
    
    override var attributedText: NSAttributedString! {
        get {
            return super.attributedText
        }
        set(attributedText) {
            let attributedText = attributedText
            super.attributedText = attributedText
            layoutIfNeeded()
            
            var frame: CGRect = self.frame
            frame.size.height = contentSize.height
            
            /*float maxHeight = [[UIScreen mainScreen] bounds].size.height - self.frame.origin.y - self.inputView.frame.size.height - TEXT_FIELD_MARGIN_BOTTOM;
             if(frame.size.height > maxHeight)
             frame.size.height = maxHeight;*/
            
            self.frame = frame
            scrollRangeToVisible(NSRange(location: text.count - 1, length: 1))
            
            var backspaceFrame: CGRect? = backspaceButton?.frame
            backspaceFrame?.origin.y = 150
            //TODO: backspaceFrame?.origin.y = (contentSize.height - CGFloat(TEXT_FIELD_PADDING_VERTICAL) - (font?.lineHeight ?? 0.0) / 2 - (backspaceButton?.frame.size.height ?? 0.0) / 2)
            backspaceButton?.frame = backspaceFrame ?? CGRect.zero
        }
    }
    
    // MARK: Gesture delegates
    /*TODO override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }*/
}
