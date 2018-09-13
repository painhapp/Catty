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

enum ButtonIndex : Int {
    case kButtonIndexDelete = 0
    case kButtonIndexCopyOrCancel = 1
    case kButtonIndexAnimate = 2
    case kButtonIndexEdit = 3
    case kButtonIndexCancel = 4
}

@objc protocol FormulaEditorViewControllerDelegate: NSObjectProtocol {
    func save(_ formula: Formula?)
}

@objc class FormulaEditorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    private var _internFormula: InternFormula?
    var internFormula: InternFormula? {
        set { _internFormula = newValue }
        get {
            if _internFormula == nil {
            _internFormula = InternFormula()
            }
            return _internFormula
        }
    }
    var history: FormulaEditorHistory?
    var variableSourceProgram: [AnyHashable] = []
    var variableSourceObject: [AnyHashable] = []
    var variableSource: [AnyHashable] = []
    var listSourceProgram: [AnyHashable] = []
    var listSourceObject: [AnyHashable] = []
    var listSource: [AnyHashable] = []
    @objc weak var object: SpriteObject?
    var formulaManager: FormulaManager?
    @objc weak var delegate: FormulaEditorViewControllerDelegate?

    private weak var formula: Formula?
    private weak var brickCellData: BrickCellFormulaData?
    private var recognizer: UITapGestureRecognizer?
    private var pickerGesture: UITapGestureRecognizer?
    private var formulaEditorTextView: FormulaEditorTextView?
    @IBOutlet private var orangeTypeButton: [UIButton]!
    @IBOutlet private var toolTypeButton: [UIButton]!
    @IBOutlet private var normalTypeButton: [UIButton]!
    @IBOutlet private var highlightedButtons: [UIButton]!
    @IBOutlet private weak var calcScrollView: UIScrollView!
    @IBOutlet private weak var mathScrollView: UIScrollView!
    @IBOutlet private weak var logicScrollView: UIScrollView!
    @IBOutlet private weak var objectScrollView: UIScrollView!
    @IBOutlet private weak var sensorScrollView: UIScrollView!
    @IBOutlet private weak var variableScrollView: UIScrollView!
    @IBOutlet private weak var variablePicker: UIPickerView!
    @IBOutlet private weak var variableSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var varOrListSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var calcButton: UIButton!
    @IBOutlet private weak var mathbutton: UIButton!
    @IBOutlet private weak var logicButton: UIButton!
    @IBOutlet private weak var objectButton: UIButton!
    @IBOutlet private weak var sensorButton: UIButton!
    @IBOutlet private weak var deleteButton: ShapeButton!
    @IBOutlet private weak var variableButton: UIButton!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var undoButton: UIButton!
    @IBOutlet private weak var redoButton: UIButton!
    @IBOutlet private weak var computeButton: UIButton!
    @IBOutlet private weak var divisionButton: UIButton!
    @IBOutlet private weak var multiplicationButton: UIButton!
    @IBOutlet private weak var substractionButton: UIButton!
    @IBOutlet private weak var additionButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var variable: UIButton!
    @IBOutlet private weak var takeVar: UIButton!
    @IBOutlet private weak var deleteVar: UIButton!
    @IBOutlet private weak var bottomConstraintVarButton: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraintDoneButton: NSLayoutConstraint!
    private var isProgramVariable = false
    private var notficicationHud: BDKNotifyHUD?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var brickSuperView: UIView?
    var brickFrame = CGRect.zero
    static var blockedCharSet: CharacterSet? = nil

    @objc init(brickCellFormulaData brickCellData: BrickCellFormulaData?) {
        super.init(nibName: nil, bundle: nil)

        setBrickCellFormulaData(brickCellData)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    
    }

    @objc func setBrickCellFormulaData(_ brickCellData: BrickCellFormulaData?) {
        self.brickCellData = brickCellData
        delegate = brickCellData
        formula = brickCellData?.formula()
        internFormula = InternFormula(internTokenList: formula?.formulaTree.getInternTokenList())
        history = FormulaEditorHistory(internFormulaState: internFormula?.getState())

        setCursorPositionToEndOfFormula()
        update()

        formulaEditorTextView?.highlightSelection((internFormula?.getExternFormulaString().count)!, start: 0, end: Int(internFormula?.getExternFormulaString().count ?? 0))
        internFormula?.selectWholeFormula()
    }

    func update() {
        formulaEditorTextView?.update()
        updateFormula()
        undoButton?.isEnabled = history?.undoIsPossible() != nil
        redoButton?.isEnabled = history?.redoIsPossible() != nil
    }

    func updateDeleteButton(_ enabled: Bool) {
        deleteButton?.shapeStrokeColor = enabled ? UIColor.navTint() : UIColor.gray
    }

    func backspace(_ sender: Any?) {
        formula?.displayString = nil
        handleInput(withTitle: "Backspace", andButtonType: Int(CLEAR.rawValue))
    }

    func change(_ brickCellData: BrickCellFormulaData?, andForce forceChange: Bool) -> Bool {
        let internFormulaParser = InternFormulaParser(tokens: internFormula?.getInternTokenList(), andFormulaManager: (formulaManager)!)

        let brick = self.brickCellData?.brickCell.scriptOrBrick as? Brick // must be a brick!
        //TODO: Check if following line is necessary
        internFormulaParser?.parseFormula(for: brick?.script.object)
        let formulaParserStatus: FormulaParserStatus = FormulaParserStatus(rawValue: internFormulaParser!.getErrorTokenIndex())

        if formulaParserStatus == FORMULA_PARSER_OK {
            var saved = false
            if history?.undoIsPossible() != nil || history?.redoIsPossible() != nil {
                saved = saveIfPossible()
                saved = true
            }
            setBrickCellFormulaData(brickCellData)
            if saved {
                showChangesSavedView()
            }
            return saved
        } else if formulaParserStatus == FORMULA_PARSER_STACK_OVERFLOW {
            showFormulaTooLongView()
        } else {
            if forceChange {
                setBrickCellFormulaData(brickCellData)
                showChangesDiscardedView()
                return true
            } else {
                showSyntaxErrorView()
            }
        }

        return false
    }

    func handleInput() {
        print("InternFormulaString: ", internFormula?.getExternFormulaString() ?? "")
        history?.push(internFormula?.getState())
        update()
        switchBack()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UITextViewTextDidChange, object: formulaEditorTextView)
        formulaManager = nil
    }

    func setCursorPositionToEndOfFormula() {
        internFormula?.setCursorAndSelection(0, selected: false)
        internFormula?.generateExternFormulaStringAndInternExternMapping()
        internFormula?.setExternCursorPositionRightTo(INT_MAX)
        internFormula?.updateInternCursorPosition()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background()
        formulaManager = FormulaManager()
        showFormulaEditor()

        for newButton in initMathSection(scrollView: mathScrollView, buttonHeight:(calcButton?.frame.size.height)!) {
            normalTypeButton.append(newButton)
        }
        for newButton in initObjectSection(scrollView: objectScrollView, buttonHeight:(calcButton?.frame.size.height)!) {
            normalTypeButton.append(newButton)
        }
        for newButton in initSensorSection(scrollView: sensorScrollView, buttonHeight:(calcButton?.frame.size.height)!) {
            normalTypeButton.append(newButton)
        }

        initSegmentedControls()
        colorFormulaEditor()
        hideScrollViews()
        calcScrollView.isHidden = false
        calcButton.isSelected = true
        mathScrollView.indicatorStyle = .white
        logicScrollView.indicatorStyle = .white
        objectScrollView.indicatorStyle = .white
        sensorScrollView.indicatorStyle = .white
        calcScrollView.contentSize = CGSize(width: calcScrollView.frame.size.width, height: calcScrollView.frame.size.height)

        localizeView()

        let item = UIBarButtonItem(title: kLocalizedCancel, style: .plain, target: self, action: #selector(dismissFormulaEditorView))
        item.tintColor = UIColor.navTint()
        navigationItem.leftBarButtonItem = item

        deleteButton?.shapeStrokeColor = UIColor.navTint()

        edgesForExtendedLayout = [.top, .left, .right, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        brickSuperView = brickCellData?.brickCell.superview
        brickFrame = brickCellData?.brickCell.frame ?? CGRect.zero
        if let aCell = brickCellData?.brickCell {
            view.addSubview(aCell)
            var navTopAnchor = view.safeTopAnchor;
            if (self.navigationController != nil) {
                navTopAnchor = topLayoutGuide.bottomAnchor
            }
            aCell.setAnchors(top: navTopAnchor, left: view.safeLeftAnchor, right: view.safeRightAnchor, bottom: nil, topPadding:0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: aCell.frame.height)
            formulaEditorTextView?.setAnchors(top: aCell.bottomAnchor, left: view.safeLeftAnchor, right: view.safeRightAnchor, bottom: nil, topPadding: 10, leftPadding: 10, rightPadding: 10)
            formulaEditorTextView?.isScrollEnabled = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(FormulaEditorViewController.formulaTextViewTextDidChange(_:)), name: .UITextViewTextDidChange, object: formulaEditorTextView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.pickerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chosenVariable:)];
        //self.pickerGesture.numberOfTapsRequired = 1;
        //[self.variablePicker addGestureRecognizer:self.pickerGesture];

        update()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let aRecognizer = recognizer {
            if view.window?.gestureRecognizers?.contains(aRecognizer) ?? false {
                view.window?.removeGestureRecognizer(aRecognizer)
            }
        }

        brickCellData?.brickCell.frame = brickFrame
        if let aCell = brickCellData?.brickCell {
            aCell.unsetAnchors()
            brickSuperView?.addSubview(aCell)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // enable userinteraction for all subviews
        for subview in (brickCellData?.brickCell.dataSubviews())! {
            if (subview is UIView) {
                (subview as? UIView)?.isUserInteractionEnabled = true
            }
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if history?.undoIsPossible() != nil {
            formulaEditorTextView?.resignFirstResponder()

            AlertControllerBuilder.alert(title: nil, message: kLocalizedUndoTypingDescription).addCancelAction(title: kLocalizedCancel, handler: {
                self.formulaEditorTextView?.becomeFirstResponder()
            }).addDefaultAction(title: kLocalizedUndo, handler: {
                self.undo()
                self.formulaEditorTextView?.becomeFirstResponder()
            }).build().showWithController(self)
        }
    }

    // MARK: initPickerView
    func initSegmentedControls() {
        variablePicker.delegate = self
        variablePicker.dataSource = self
        variablePicker.tintColor = UIColor.globalTint()
        variableSourceProgram = [AnyHashable]()
        variableSourceObject = [AnyHashable]()
        variableSource = [AnyHashable]()
        listSourceProgram = [AnyHashable]()
        listSourceObject = [AnyHashable]()
        listSource = [AnyHashable]()
        updateVariablePickerData()
        variableSegmentedControl.setTitle(kLocalizedObject, forSegmentAt: 1)
        variableSegmentedControl.setTitle(kLocalizedProgram, forSegmentAt: 0)
        variableSegmentedControl.tintColor = UIColor.globalTint()

        varOrListSegmentedControl.setTitle(kLocalizedVariables, forSegmentAt: 0)
        varOrListSegmentedControl.setTitle(kLocalizedLists, forSegmentAt: 1)
        varOrListSegmentedControl.tintColor = UIColor.globalTint()
    }

    // MARK: localizeView
    func localizeView() {
        for button: UIButton in normalTypeButton {
            let name = Operators.getExternName(Operators.getName(Operator(rawValue: button.tag)!))
            if name?.count != 0 {
                button.setTitle(name, for: .normal)
            }
        }

        calcButton.setTitle(kUIFENumbers, for: .normal)
        mathbutton.setTitle(kUIFEMath, for: .normal)
        logicButton.setTitle(kUIFELogic, for: .normal)
        objectButton.setTitle(kUIFEObject, for: .normal)
        sensorButton.setTitle(kUIFESensor, for: .normal)
        variableButton.setTitle(kUIFEVariableList, for: .normal)
        computeButton.setTitle(kUIFECompute, for: .normal)
        doneButton.setTitle(kUIFEDone, for: .normal)
        variable.setTitle(kUIFEVar, for: .normal)
        takeVar.setTitle(kUIFETake, for: .normal)
        deleteVar.setTitle(kUIFEDelete, for: .normal)
    }

// MARK: helper methods
    @objc func dismissFormulaEditorView() {
        if presentingViewController?.isBeingDismissed == false {
            brickCellData?.drawBorder(false)
            setBrickCellFormulaData(brickCellData)
            formulaEditorTextView?.removeFromSuperview()
            presentingViewController?.dismiss(animated: true)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

// MARK: TextField Actions
    @IBAction func buttonPressed(_ sender: Any) {
        if (sender is UIButton) {
            let button = sender as? UIButton
            let title = button?.titleLabel?.text

            handleInput(withTitle: title, andButtonType:(button?.tag)!)
        }
    }

    func handleInput(withTitle title: String?, andButtonType buttonType: Int) {
        internFormula?.handleKeyInput(withName: title, butttonType: Int32(buttonType))
        handleInput()
    }

    func switchBack() {
        if calcScrollView.isHidden == true {
            showCalc(UIButton())
        }
    }

    @IBAction func undo() {
        if history?.undoIsPossible() == nil {
            return
        }

        let lastStep: InternFormulaState? = history?.backward()
        if lastStep != nil {
            internFormula = lastStep?.createInternFormulaFromState()
            update()
            setCursorPositionToEndOfFormula()
        }
    }

    @IBAction func redo(_ sender: Any) {
        if history?.redoIsPossible() == nil {
            return
        }

        let nextStep: InternFormulaState? = history?.forward()
        if nextStep != nil {
            internFormula = nextStep?.createInternFormulaFromState()
            update()
            setCursorPositionToEndOfFormula()
        }
    }

    @IBAction func backspaceButtonAction(_ sender: Any) {
        backspace(nil)
    }

    @IBAction func done(_ sender: Any) {
        if saveIfPossible() {
            dismissFormulaEditorView()
        }
    }

    @IBAction func compute(_ sender: Any) {
        if internFormula != nil {
            let internFormulaParser = InternFormulaParser(tokens: internFormula?.getInternTokenList(), andFormulaManager: (formulaManager)!)

            let brick = brickCellData?.brickCell.scriptOrBrick as? Brick // must be a brick!
            let formula = Formula(formulaElement: internFormulaParser!.parseFormula(for: brick?.script.object))

            switch internFormulaParser?.getErrorTokenIndex() {
                case FORMULA_PARSER_OK.rawValue:
                    showComputeDialog(formula, andSpriteObject: brick?.script.object)
                case FORMULA_PARSER_STACK_OVERFLOW.rawValue:
                    showFormulaTooLongView()
                case FORMULA_PARSER_STRING.rawValue:
                    if brickCellData?.brickCell.isScriptBrick == nil {
                        let brick = brickCellData?.brickCell.scriptOrBrick as? (Brick & BrickFormulaProtocol)
                        if brick?.allowsStringFormula() == nil {
                            showSyntaxErrorView()
                        } else {
                            showComputeDialog(formula, andSpriteObject: brick?.script.object)
                        }
                    }
                default:
                    showSyntaxErrorView()
            }
        }
    }

    func showComputeDialog(_ formula: Formula?, andSpriteObject spriteObject: SpriteObject?) {
        formulaManager?.setup(for: formula!)

        let computedString = interpretFormula(formula, for: spriteObject)
        showNotification(computedString, andDuration: CGFloat(kFormulaEditorShowResultDuration))

        formulaManager?.stop()
    }

    func interpretFormula(_ formula: Formula?, for spriteObject: SpriteObject?) -> String? {
        let result = formulaManager?.interpret(formula!, for: spriteObject!)

        if (result is String) {
            return result as? String
        }
        if (result is NSNumber) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if let aResult = result as? NSNumber {
                return formatter.string(from: aResult)
            }
            return nil
        }

        return ""
    }

    // MARK: UI
    func showFormulaEditor() {
        formulaEditorTextView = FormulaEditorTextView(formulaEditorViewController: self)
        if let aView = formulaEditorTextView {
            view.addSubview(aView)
        }

        update()

        formulaEditorTextView?.becomeFirstResponder()

        //Safe Area Padding for Formula Editor Input
        if #available(iOS 11.0, *) {
            let window: UIWindow? = UIApplication.shared.keyWindow
            let bottomPadding: CGFloat? = window?.safeAreaInsets.bottom
            bottomConstraintVarButton.constant = bottomPadding ?? 0.0
            bottomConstraintDoneButton.constant = bottomPadding ?? 0.0
        }
    }

    func colorFormulaEditor() {
        for case let button: UIButton in orangeTypeButton {
            button.setTitleColor(UIColor.formulaButtonText(), for: .normal)
            button.backgroundColor = UIColor.formulaEditorOperator()
            button.setBackgroundImage(UIImage(color: UIColor.formulaEditorOperand()), for: .highlighted)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.formulaEditorBorder().cgColor
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.01
        }

        for case let button: UIButton in normalTypeButton {
            button.setTitleColor(UIColor.formulaEditorOperand(), for: .normal)
            button.setTitleColor(UIColor.background(), for: .highlighted)
            
            button.backgroundColor = UIColor.background()
            button.setBackgroundImage(UIImage(color: UIColor.formulaEditorOperand()), for: .highlighted)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.formulaEditorBorder().cgColor
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.01
            //    if([[self.normalTypeButton objectAtIndex:i] tag] == 3011)
            //    {
            //        if(![self.brickCellData.brickCell.scriptOrBrick isKindOfClass:[SpeakBrick class]])
            //       {
            //            [[self.normalTypeButton objectAtIndex:i] setEnabled:NO];
            //           [[self.normalTypeButton objectAtIndex:i] setTitleColor:[UIColor navTintColor] forState:UIControlStateNormal];
            //            }
            //        }
        }
        //    for(UIButton *button in self.toolTypeButton) {
        //        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [button setTitleColor:[UIColor formulaEditorHighlightColor] forState:UIControlStateHighlighted];
        //        [button setTitleColor:[UIColor utilityTintColor] forState:UIControlStateSelected];
        //        [button setBackgroundColor:[UIColor backgroundColor]];
        //        [[button layer] setBorderWidth:1.0f];
        //        [[button layer] setBorderColor:[UIColor formulaEditorBorderColor].CGColor];
        //        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        //        button.titleLabel.minimumScaleFactor = 0.01f;
        //    }

        for case let button: UIButton in toolTypeButton {
            button.setTitleColor(UIColor.formulaButtonText(), for: .normal)
            button.setTitleColor(UIColor.formulaEditorOperator(), for: .selected)
            button.setBackgroundImage(UIImage(color: UIColor.formulaEditorOperator()), for: .normal)
            button.setBackgroundImage(UIImage(color: UIColor.formulaButtonText()), for: .selected)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.formulaEditorBorder().cgColor
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.01
        }

        for case let button: UIButton in highlightedButtons {
            button.setTitleColor(UIColor.formulaButtonText(), for: .normal)
            button.setTitleColor(UIColor.gray, for: .disabled)
            button.backgroundColor = UIColor.formulaEditorOperator()
            button.setBackgroundImage(UIImage(color: UIColor.formulaEditorOperand()), for: .selected)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.formulaEditorBorder().cgColor
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.01
        }
        variableScrollView.backgroundColor = UIColor.background()

    }

    func updateFormula() {
        if formula != nil && internFormula != nil {
            formula?.displayString = internFormula?.getExternFormulaString() as NSString?
        }

        let brickCell: BrickCell? = brickCellData?.brickCell
        let line = brickCellData?.lineNumber
        let parameter = brickCellData?.parameterNumber
        brickCellData?.brickCell.setupBrickCellinSelectionView(false, inBackground: ((object?.isBackground) != nil))
        brickCellData = (brickCell?.dataSubview(forLineNumber:line!, andParameterNumber: parameter!)) as? BrickCellFormulaData
        brickCellData?.drawBorder(true)

        // disable userinteraction for all subviews different than BrickCellFormulaData
        for subview in (brickCellData?.brickCell.dataSubviews())! {
            if (subview is UIView) && !(subview is BrickCellFormulaData) {
                (subview as? UIView)?.isUserInteractionEnabled = false
            }
        }
    }

    func saveIfPossible() -> Bool {
        if internFormula != nil {
            let internFormulaParser = InternFormulaParser(tokens: internFormula?.getInternTokenList(), andFormulaManager:formulaManager!)

            let brick = brickCellData?.brickCell.scriptOrBrick as? Brick // must be a brick!
            let formulaElement: FormulaElement? = internFormulaParser?.parseFormula(for: brick?.script.object)
            let formula = Formula(formulaElement: formulaElement)
            switch internFormulaParser?.getErrorTokenIndex() {
                case FORMULA_PARSER_OK.rawValue:
                    if delegate != nil {
                        delegate?.save(formula)
                    }
                    return true
                case FORMULA_PARSER_STACK_OVERFLOW.rawValue:
                    showFormulaTooLongView()
                case FORMULA_PARSER_STRING.rawValue:
                    if brickCellData?.brickCell.isScriptBrick == nil {
                        let brick = brickCellData?.brickCell.scriptOrBrick as? (Brick & BrickFormulaProtocol)
                        if brick?.allowsStringFormula() == nil {
                            showSyntaxErrorView()
                        } else {
                            if delegate != nil {
                                delegate?.save(formula)
                            }
                            return true
                        }
                    }
                default:
                    showSyntaxErrorView()
            }
        }

        return false
    }

    //- (IBAction)showMathFunctionsMenu:(id)sender
    //{
    //    [self.formulaEditorTextView resignFirstResponder];
    //    [self.mathFunctionsMenu show];
    //    [self.mathFunctionsMenu becomeFirstResponder];
    //}
    //
    //- (IBAction)showLogicalOperatorsMenu:(id)sender
    //{
    //    [self.formulaEditorTextView resignFirstResponder];
    //    [self.logicalOperatorsMenu show];
    //    [self.logicalOperatorsMenu becomeFirstResponder];
    //}
    @IBAction func showCalc(_ sender: UIButton) {
        hideScrollViews()
        calcScrollView.isHidden = false
        calcButton.isSelected = true
        calcScrollView.setContentOffset(CGPoint.zero, animated:false)
    }

    @IBAction func showFunction(_ sender: UIButton) {
        hideScrollViews()
        mathScrollView.isHidden = false
        mathbutton.isSelected = true
        mathScrollView.setContentOffset(CGPoint.zero, animated:false)
        mathScrollView.flashScrollIndicators()
    }

    @IBAction func showLogic(_ sender: UIButton) {
        hideScrollViews()
        logicScrollView.isHidden = false
        logicButton.isSelected = true
        logicScrollView.setContentOffset(CGPoint.zero, animated:false)
        logicScrollView.flashScrollIndicators()
    }

    @IBAction func showObject(_ sender: UIButton) {
        hideScrollViews()
        objectScrollView.isHidden = false
        objectButton.isSelected = true
        objectScrollView.setContentOffset(CGPoint.zero, animated:false)
        objectScrollView.flashScrollIndicators()
    }

    @IBAction func showSensor(_ sender: UIButton) {
        hideScrollViews()
        sensorScrollView.isHidden = false
        sensorButton.isSelected = true
        sensorScrollView.setContentOffset(CGPoint.zero, animated:false)
        sensorScrollView.flashScrollIndicators()
    }

    @IBAction func showVariable(_ sender: UIButton) {
        hideScrollViews()
        variableScrollView.isHidden = false
        variableButton.isSelected = true
        variableScrollView.setContentOffset(CGPoint.zero, animated:false)
        variableScrollView.flashScrollIndicators()
    }

    func hideScrollViews() {
        mathScrollView.isHidden = true
        calcScrollView.isHidden = true
        logicScrollView.isHidden = true
        objectScrollView.isHidden = true
        sensorScrollView.isHidden = true
        variableScrollView.isHidden = true
        calcButton.isSelected = false
        mathbutton.isSelected = false
        objectButton.isSelected = false
        logicButton.isSelected = false
        sensorButton.isSelected = false
        variableButton.isSelected = false
    }

    func addNewVarOrList(_ isProgramVarOrList: Bool, isList: Bool) {

        let promptTitle = isList ? kUIFENewList : kUIFENewVar
        let promptMessage = isList ? kUIFEListName : kUIFEVarName
        isProgramVariable = isProgramVarOrList
        variableSegmentedControl.selectedSegmentIndex = isProgramVarOrList ? 0 : 1
        variableSegmentedControl.setNeedsDisplay()

        Util.askUser(forVariableNameAndPerformAction: #selector(FormulaEditorViewController.saveVariable(_:isList:)), target: self, promptTitle: promptTitle, promptMessage: promptMessage, minInputLength: UInt(kMinNumOfVariableNameCharacters), maxInputLength: UInt(kMaxNumOfVariableNameCharacters), isList: isList, blockedCharacterSet: blockedCharacterSet(), andTextField: formulaEditorTextView)
    }

    func askObjectOrProgram(_ isList: Bool) {
        let promptTitle = isList ? kUIFEActionList : kUIFEActionVar
        AlertControllerBuilder.actionSheet(title: promptTitle).addCancelAction(title: kLocalizedCancel, handler: {
            self.formulaEditorTextView?.becomeFirstResponder()
        }).addDefaultAction(title: kUIFEActionVarPro, handler: {
            self.addNewVarOrList(true, isList: isList)
        }).addDefaultAction(title: kUIFEActionVarObj, handler: {
            self.addNewVarOrList(false, isList: isList)
        }).build().showWithController(self)
    }

    @IBAction func askVarOrList(_ sender: UIButton) {
        formulaEditorTextView?.resignFirstResponder()
        AlertControllerBuilder.actionSheet(title: kUIFEVarOrList).addCancelAction(title: kLocalizedCancel, handler: {
            self.formulaEditorTextView?.becomeFirstResponder()
        }).addDefaultAction(title: kUIFENewVar, handler: {
            self.askObjectOrProgram(false)
        }).addDefaultAction(title: kUIFENewList, handler: {
            self.askObjectOrProgram(true)
        }).build().showWithController(self)
    }

    func blockedCharacterSet() -> CharacterSet? {
        if FormulaEditorViewController.blockedCharSet == nil {
            FormulaEditorViewController.blockedCharSet = CharacterSet(charactersIn: kTextFieldAllowedCharacters).inverted
        }
        return FormulaEditorViewController.blockedCharSet
    }

    func updateVariablePickerData() {
        let variables: VariablesContainer? = object?.program.variables
        variableSource.removeAll()
        variableSourceProgram.removeAll()
        variableSourceObject.removeAll()
        listSource.removeAll()
        listSourceProgram.removeAll()
        listSourceObject.removeAll()

        // ------------------
        // Program Variables
        // ------------------
        if variables?.programVariableList.count ?? 0 > 0 {
            variableSource.append(VariablePickerData(title: kUIFEProgramVars))
        }

        var myArray:[UserVariable] = variables?.programVariableList as! [UserVariable]
        for userVariable: UserVariable in myArray {
            let pickerData = VariablePickerData(title: userVariable.name, andVariable: userVariable)
            pickerData?.isProgramVariable = true
            variableSource.append(pickerData!)
            variableSourceProgram.append(pickerData!)
        }


        // ------------------
        // Program Lists
        // ------------------
        if variables?.programListOfLists.count ?? 0 > 0 {
            listSource.append(VariablePickerData(title: kUIFEProgramLists))
        }

        myArray = (variables?.programListOfLists) as! [UserVariable]
        for userVariable: UserVariable in myArray {
            let pickerData = VariablePickerData(title: userVariable.name, andVariable: userVariable)
            pickerData?.isProgramVariable = true
            listSource.append(pickerData!)
            listSourceProgram.append(pickerData!)
        }


        // ------------------
        // Object Variables
        // ------------------
        myArray = (variables?.objectVariables(for: self.object)) as! [UserVariable]
        if (myArray.count) > 0 {
            variableSource.append(VariablePickerData(title: kUIFEObjectVars))
        }
        for userVar: UserVariable in myArray {
            let pickerData = VariablePickerData(title: userVar.name, andVariable: userVar)
            pickerData?.isProgramVariable = false
            variableSource.append(pickerData!)
            variableSourceObject.append(pickerData!)
        }


        // ------------------
        // Object Lists
        // ------------------
        myArray = (variables?.objectLists(for: self.object)) as! [UserVariable]
        if (myArray.count) > 0 {
            listSource.append(VariablePickerData(title: kUIFEObjectLists))
        }
        for userVar: UserVariable in myArray {
            let pickerData = VariablePickerData(title: userVar.name, andVariable: userVar)
            pickerData?.isProgramVariable = false
            listSource.append(pickerData!)
            listSourceObject.append(pickerData!)
        }

        variablePicker.reloadAllComponents()
        if variableSource.count > 0 {
            variablePicker.selectRow(0, inComponent: 0, animated: false)
        }
    }

    func ask(forVariableName isList: Bool) {
        Util.askUser(forVariableNameAndPerformAction: #selector(FormulaEditorViewController.saveVariable(_:isList:)), target: self, promptTitle: kUIFENewVarExists, promptMessage: kUIFEOtherName, minInputLength: UInt(kMinNumOfVariableNameCharacters), maxInputLength: UInt(kMaxNumOfVariableNameCharacters), isList: isList, blockedCharacterSet: blockedCharacterSet(), andTextField: formulaEditorTextView)
    }

    @objc func saveVariable(_ name: String?, isList: Bool) {
        if isProgramVariable && !isList {
            let myArray=object?.program?.variables.allVariables()
            for variable in myArray! {
                if (variable is UserVariable && (variable as! UserVariable).name == name)  {
                    ask(forVariableName: isList)
                    return
                }
            }
        } else if !isProgramVariable && !isList {
            let myArray=object?.program?.variables.allVariables(for: object)
            for variable in myArray! {
                if (variable is UserVariable && (variable as! UserVariable).name == name) {
                    ask(forVariableName: isList)
                    return
                }
            }
        } else if isProgramVariable && isList {
            let myArray=object?.program?.variables.allLists()
            for variable in myArray! {
                if (variable is UserVariable && (variable as! UserVariable).name == name) {
                    ask(forVariableName: isList)
                    return
                }
            }
        } else if !isProgramVariable && isList {
            let myArray=object?.program?.variables.allLists(for: object)
            for variable in myArray! {
                if (variable is UserVariable && (variable as! UserVariable).name == name)  {
                    ask(forVariableName: isList)
                    return
                }
            }
        }

        formulaEditorTextView?.becomeFirstResponder()
        let userVar = UserVariable()
        userVar.name = name

        if isList {
            userVar.value = [AnyHashable]()
        } else {
            userVar.value = 0
        }
        userVar.isList = isList

        if isProgramVariable && !isList {
            object?.program.variables.programVariableList.add(userVar)
        } else if isProgramVariable && isList {
            object?.program.variables.programListOfLists.add(userVar)
        } else if !isProgramVariable && !isList {
            var array: [UserVariable]? = nil
            if let anObject = object {
                array = object?.program.variables.objectVariables(for: anObject) as? [UserVariable]
            }
            if array == nil {
                array = [UserVariable]()
            }
            array?.append(userVar)
            //TODO FIX object?.program?.variables.objectVariables(for: object) = array
        } else if !isProgramVariable && isList {
            var array: [UserVariable]? = nil
            if let anObject = object {
                array = object?.program?.variables.objectLists(for: anObject) as? [UserVariable]
            }
            if array == nil {
                array = [UserVariable]()
            }
            array?.append(userVar)
            //TODO FIX object?.program?.variables.objectLists(for: object) = array
        }

        object?.program.saveToDisk(withNotification: true)
        updateVariablePickerData()
    }

    func closeMenu() {
        formulaEditorTextView?.becomeFirstResponder()
    }

    @IBAction func addNewText(_ sender: Any) {
        formulaEditorTextView?.resignFirstResponder()

        Util.askUser(forVariableNameAndPerformAction: #selector(FormulaEditorViewController.handleNewTextInput(_:)), target: self, promptTitle: kUIFENewText, promptMessage: kUIFETextMessage, minInputLength: UInt(kMinNumOfProgramNameCharacters), maxInputLength: UInt(kMaxNumOfProgramNameCharacters), isList: false, blockedCharacterSet: blockedCharacterSet(), andTextField: formulaEditorTextView)
    }

    @objc func handleNewTextInput(_ text: String?) {
        debugPrint("Text: %@" + text!)
        handleInput(withTitle: text, andButtonType: Int(TOKEN_TYPE_STRING.rawValue))
        formulaEditorTextView?.becomeFirstResponder()
    }

    // MARK: pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 && variableSegmentedControl.selectedSegmentIndex == 0 && varOrListSegmentedControl.selectedSegmentIndex == 0 {
            return variableSourceProgram.count
        } else if component == 0 && variableSegmentedControl.selectedSegmentIndex == 1 && varOrListSegmentedControl.selectedSegmentIndex == 0 {
            return variableSourceObject.count
        } else if component == 0 && variableSegmentedControl.selectedSegmentIndex == 0 && varOrListSegmentedControl.selectedSegmentIndex == 1 {
            return listSourceProgram.count
        } else if component == 0 && variableSegmentedControl.selectedSegmentIndex == 1 && varOrListSegmentedControl.selectedSegmentIndex == 1 {
            return listSourceObject.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        /*TDOO let forObjectOnly = Bool(variableSegmentedControl.selectedSegmentIndex)
        let isList = Bool(varOrListSegmentedControl.selectedSegmentIndex)



        if component == 0 && !forObjectOnly && !isList {
            if row < variableSourceProgram.count {
                return variableSourceProgram[row].title()
            }
        } else if component == 0 && forObjectOnly && !isList {
            if row < variableSourceObject.count {
                return variableSourceObject[row].title()
            }
        } else if component == 0 && !forObjectOnly && isList {
            if row < listSourceProgram.count {
                return listSourceProgram[row].title()
            }
        } else if component == 0 && forObjectOnly && isList {
            if row < listSourceObject.count {
                return listSourceObject[row].title()
            }
        }*/

        return ""
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        let color = UIColor.globalTint()
        let attString = NSAttributedString(string: title ?? "", attributes: [NSAttributedStringKey.foregroundColor: color!])
        return attString
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    @IBAction func choseVariableOrList(_ sender: UIButton) {

        let row: Int = variablePicker.selectedRow(inComponent: 0)
        if row >= 0 {
            var buttonType: Int = 0
            var pickerData: VariablePickerData?
            if variableSegmentedControl.selectedSegmentIndex == 0 && varOrListSegmentedControl.selectedSegmentIndex == 0 {
                if row < variableSourceProgram.count {
                    pickerData = variableSourceProgram[row] as? VariablePickerData
                }
            } else if variableSegmentedControl.selectedSegmentIndex == 1 && varOrListSegmentedControl.selectedSegmentIndex == 0 {
                if row < variableSourceObject.count {
                    pickerData = variableSourceObject[row] as? VariablePickerData
                }
            } else if variableSegmentedControl.selectedSegmentIndex == 0 && varOrListSegmentedControl.selectedSegmentIndex == 1 {
                if row < listSourceProgram.count {
                    pickerData = listSourceProgram[row] as? VariablePickerData
                    buttonType = 11
                }
            } else if variableSegmentedControl.selectedSegmentIndex == 1 && varOrListSegmentedControl.selectedSegmentIndex == 1 {
                if row < listSourceObject.count {
                    pickerData = listSourceObject[row] as? VariablePickerData
                    buttonType = 11
                }
            }
            if pickerData != nil {
                handleInput(withTitle: pickerData?.userVariable.name, andButtonType: buttonType)
            }
        }
    }

    @IBAction func deleteVariable(_ sender: UIButton) {
        let row: Int = variablePicker.selectedRow(inComponent: 0)
        if row >= 0 {
            var pickerData: VariablePickerData?
            if (variableSegmentedControl.selectedSegmentIndex == 0) && (varOrListSegmentedControl.selectedSegmentIndex == 0) {
                if row < variableSourceProgram.count {
                    pickerData = variableSourceProgram[row] as? VariablePickerData
                }
            } else if (variableSegmentedControl.selectedSegmentIndex == 1) && (varOrListSegmentedControl.selectedSegmentIndex == 0) {
                if row < variableSourceObject.count {
                    pickerData = variableSourceObject[row] as? VariablePickerData
                }
            } else if (variableSegmentedControl.selectedSegmentIndex == 0) && (varOrListSegmentedControl.selectedSegmentIndex == 1) {
                if row < listSourceProgram.count {
                    pickerData = listSourceProgram[row] as? VariablePickerData
                }
            } else if (variableSegmentedControl.selectedSegmentIndex == 1) && (varOrListSegmentedControl.selectedSegmentIndex == 1) {
                if row < listSourceObject.count {
                    pickerData = listSourceObject[row] as? VariablePickerData
                }
            }
            if pickerData != nil {
                if !isVarOrListBeingUsed(pickerData?.userVariable) {

                    var removed = false
                    let isList = pickerData?.userVariable.isList
                    if !(isList ?? false) {
                        removed = object?.program.variables.removeUserVariableNamed(pickerData?.userVariable.name, for: object) ?? false
                    } else {
                        removed = object?.program.variables.removeUserListNamed(pickerData?.userVariable.name, for: object) ?? false
                    }
                    if removed {
                        if !(isList ?? false) {
                            variableSource.remove(at: row)
                        } else {
                            listSource.remove(at: row)
                        }
                        object?.program.saveToDisk(withNotification: true)
                        updateVariablePickerData()
                    }
                } else {
                    showNotification(kUIFEDeleteVarBeingUsed, andDuration: 1.5)
                }
            }
        }
    }

    func isVarOrListBeingUsed(_ variable: UserVariable?) -> Bool {
        //TODO: Make it work for lists
        if object?.program.variables.isProgramVariableOrList(variable) != nil {
            let objList:[SpriteObject] = (object?.program?.objectList)! as! [SpriteObject]
            for spriteObject: SpriteObject in objList {
                let scriptList:[Script] = (spriteObject.scriptList)! as! [Script]
                for script: Script in scriptList {
                    for brick in (script.brickList)! {
                        if (brick is Brick) && (brick as! Brick).isVarOrListBeingUsed(variable) {
                            return true
                        }
                    }
                }
            }
        } else {
            let scrList:[Script] = (object?.scriptList)! as! [Script]
            for script: Script in scrList {
                for brick: Any in (script.brickList)! {
                    if (brick is Brick) && (brick as! Brick).isVarOrListBeingUsed(variable) {
                        return true
                    }
                }
            }
        }

        return false
    }

    @IBAction func changeVariablePickerView(_ sender: Any) {
        variablePicker.reloadAllComponents()
    }

    func showNotification(_ text: String?, andDuration duration: CGFloat) {
        if notficicationHud != nil {
            notficicationHud?.removeFromSuperview()
        }

        let offset1 = ((navigationController?.navigationBar.frame.size.height)! + (brickCellData?.brickCell.frame.size.height)!)
        let brickAndInputHeight: CGFloat = offset1 + (formulaEditorTextView?.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height + 10
        let keyboardHeight = formulaEditorTextView?.inputView?.frame.size.height
        let spacerHeight: CGFloat = view.frame.size.height - brickAndInputHeight - (keyboardHeight ?? 0.0)
        var offset: CGFloat

        notficicationHud = BDKNotifyHUD(image: nil, text: text)
        notficicationHud?.destinationOpacity = CGFloat(kBDKNotifyHUDDestinationOpacity)

        if spacerHeight < notficicationHud?.frame.size.height ?? 0.0 {
            offset = brickAndInputHeight / 2 + (notficicationHud?.frame.size.height)! / 2
        } else {
            offset = brickAndInputHeight + (notficicationHud?.frame.size.height)! / 2 + CGFloat(kBDKNotifyHUDPaddingTop)
        }

        notficicationHud?.center = CGPoint(x: view.center.x, y: offset)

        if let aHud = notficicationHud {
            view.addSubview(aHud)
        }
        notficicationHud?.present(withDuration: duration, speed: CGFloat(kBDKNotifyHUDPresentationSpeed), in: view) {
            self.notficicationHud?.removeFromSuperview()
        }
    }

    func showChangesSavedView() {
        showNotification(kUIFEChangesSaved, andDuration: CGFloat(kBDKNotifyHUDPresentationDuration))
    }

    func showChangesDiscardedView() {
        showNotification(kUIFEChangesDiscarded, andDuration: CGFloat(kBDKNotifyHUDPresentationDuration))
    }

    func showSyntaxErrorView() {
        showNotification(kUIFESyntaxError, andDuration: CGFloat(kBDKNotifyHUDPresentationDuration))
        formulaEditorTextView?.setParseErrorCursorAndSelection()
    }

    func showFormulaTooLongView() {
        showNotification(kUIFEtooLongFormula, andDuration: CGFloat(kBDKNotifyHUDPresentationDuration))
    }

    // MARK: NotificationCenter
    @objc func formulaTextViewTextDidChange(_ note: Notification?) {
        if note?.object != nil {
            let textView = note?.object as? FormulaEditorTextView
            let containsText: Bool = textView?.text.count ?? 0 > 0
            deleteButton.shapeStrokeColor = containsText ? UIColor.navTint() : UIColor.gray
            deleteButton.isEnabled = containsText
        }
    }
    
    // MARK: Section
    func initMathSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager?.formulaEditorItemsForMathSection(spriteObject: object!)
        return initWithItems(formulaEditorItems: items!, scrollView: scrollView, buttonHeight: buttonHeight)
    }
    
    func initObjectSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager?.formulaEditorItemsForObjectSection(spriteObject: object!)
         return initWithItems(formulaEditorItems: items!, scrollView: scrollView, buttonHeight: buttonHeight)
    }
    
    func initSensorSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager?.formulaEditorItemsForDeviceSection(spriteObject: object!)
         return initWithItems(formulaEditorItems: items!, scrollView: scrollView, buttonHeight: buttonHeight)
    }
    
    private func initWithItems(formulaEditorItems: [FormulaEditorItem], scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        var topAnchorView: UIView?
        var buttons = [UIButton]()
        
        for item in formulaEditorItems {
            let button = FormulaEditorButton(formulaEditorItem: item)
            topAnchorView = addButtonToScrollView(button: button, scrollView: scrollView, topAnchorView: topAnchorView, buttonHeight: buttonHeight)
            buttons.append(topAnchorView as! UIButton)
        }
        
        resizeSection(scrollView: scrollView, for: buttons, with: buttonHeight)
        return buttons
    }
    
    @objc func buttonPressed(sender: UIButton) {
        if let button = sender as? FormulaEditorButton {
            if let sensor = button.sensor {
                self.handleInput(for: sensor)
            } else if let function = button.function {
                self.handleInput(for: function)
            }
        }
    }
    
    private func addButtonToScrollView(button: FormulaEditorButton, scrollView: UIScrollView, topAnchorView: UIView?, buttonHeight: CGFloat) -> UIButton {
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        scrollView.addSubview(button)
        if (topAnchorView == nil) {
            button.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        } else {
            button.topAnchor.constraint(equalTo: (topAnchorView?.bottomAnchor)!, constant: 0).isActive = true
        }
        
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        
        return button;
    }
    
    private func resizeSection(scrollView: UIScrollView, for buttons: [UIButton], with buttonHeight: CGFloat) {
        scrollView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y, width: scrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
    }
    
    private func handleInput(for sensor: Sensor) {
        self.internFormula?.handleKeyInput(for: sensor)
        self.handleInput()
    }
    
    private func handleInput(for function: Function) {
        self.internFormula?.handleKeyInput(for: function)
        self.handleInput()
    }
}
