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

// brick categories
enum BrickCategoryType : Int {
    case controlBrick = 1
    case motionBrick = 2
    case lookBrick = 3
    case soundBrick = 4
    case variableBrick = 5
    case arduinoBrick = 6
    case phiroBrick = 7
    case favouriteBricks = 0
}

// brick type identifiers
enum BrickType : Int {
    // invalid brick type
    case invalidBrick = 888888888888 // TODO: Convert NSIntegerMax
    // 0xx control bricks
    case programStartedBrick = 0
    case tappedBrick = 1
    case touchDownBrick = 2
    case waitBrick = 3
    case receiveBrick = 4
    case broadcastBrick = 5
    case broadcastWaitBrick = 6
    case noteBrick = 7
    case foreverBrick = 8
    case ifBrick = 9
    case ifThenBrick = 10
    case ifElseBrick = 11
    case ifEndBrick = 12
    case ifThenEndBrick = 13
    case waitUntilBrick = 14
    case repeatBrick = 15
    case repeatUntilBrick = 16
    case loopEndBrick = 17
    // 1xx motion bricks
    case placeAtBrick = 100
    case setXBrick = 101
    case setYBrick = 102
    case changeXByNBrick = 103
    case changeYByNBrick = 104
    case ifOnEdgeBounceBrick = 105
    case moveNStepsBrick = 106
    case turnLeftBrick = 107
    case turnRightBrick = 108
    case pointInDirectionBrick = 109
    case pointToBrick = 110
    case glideToBrick = 111
    case goNStepsBackBrick = 112
    case comeToFrontBrick = 113
    case vibrationBrick = 114
    // 2xx look bricks
    case setLookBrick = 200
    case setBackgroundBrick = 201
    case nextLookBrick = 202
    case previousLookBrick = 203
    case setSizeToBrick = 204
    case changeSizeByNBrick = 205
    case hideBrick = 206
    case showBrick = 207
    case setTransparencyBrick = 208
    case changeTransparencyByNBrick = 209
    case setBrightnessBrick = 210
    case changeBrightnessByNBrick = 211
    case setColorBrick = 212
    case changeColorByNBrick = 213
    case clearGraphicEffectBrick = 214
    case flashBrick = 215
    case cameraBrick = 216
    case chooseCameraBrick = 217
    case sayBubbleBrick = 218
    case sayForBubbleBrick = 219
    case thinkBubbleBrick = 220
    case thinkForBubbleBrick = 221
    // 3xx sound bricks
    case playSoundBrick = 300
    case stopAllSoundsBrick = 301
    case setVolumeToBrick = 302
    case changeVolumeByNBrick = 303
    case speakBrick = 304
    case speakAndWaitBrick = 305
    // 4xx variable and list bricks
    case setVariableBrick = 400
    case changeVariableBrick = 401
    case showTextBrick = 402
    case hideTextBrick = 403
    case addItemToUserListBrick = 404
    case deleteItemOfUserListBrick = 405
    case insertItemIntoUserListBrick = 406
    case replaceItemInUserListBrick = 407
    // 5xx arduino bricks
    case arduinoSendDigitalValueBrick = 500
    case arduinoSendPWMValueBrick = 501
    // 6xx phiro bricks
    case phiroMotorStopBrick = 600
    case phiroMotorMoveForwardBrick = 601
    case phiroMotorMoveBackwardBrick = 602
    case phiroPlayToneBrick = 603
    case phiroRGBLightBrick = 604
    case phiroIfLogicBeginBrick = 605
}

let kMinFavouriteBrickSize = 5
let kMaxFavouriteBrickSize = 10

let kDefaultFavouriteBricksStatisticArray: [String] = [String(BrickType.tappedBrick.rawValue),
                                                       String(BrickType.foreverBrick.rawValue),
                                                       String(BrickType.ifBrick.rawValue),
                                                       String(BrickType.placeAtBrick.rawValue),
                                                       String(BrickType.playSoundBrick.rawValue),
                                                       String(BrickType.speakBrick.rawValue),
                                                       String(BrickType.setLookBrick.rawValue),
                                                       String(BrickType.setVariableBrick.rawValue),
                                                       String(BrickType.changeVariableBrick.rawValue)]

// brick categories
let kBrickCategoryNames = [kLocalizedControl, kLocalizedMotion, kLocalizedLooks, kLocalizedSound, kLocalizedVariables, kLocalizedPhiro]

let kBrickCategoryColors = [UIColor.controlBrickOrange(), UIColor.motionBrickBlue(), UIColor.lookBrickGreen(), UIColor.soundBrickViolet(), UIColor.variableBrickRed(), UIColor.arduinoBrick(), UIColor.phiroBrick()]

let kBrickCategoryStrokeColors = [UIColor.controlBrickStroke(), UIColor.motionBrickStroke(), UIColor.lookBrickStroke(), UIColor.soundBrickStroke(), UIColor.variableBrickStroke(), UIColor.arduinoBrickStroke(), UIColor.phiroBrickStroke()]

let kWhenScriptDefaultAction = "Tapped"

// map brick classes to corresponding brick type identifiers
let kClassNameBrickTypeMap = ["StartScript": BrickType.programStartedBrick,
                              "WhenScript": BrickType.tappedBrick,
                              "WhenTouchDownScript": BrickType.touchDownBrick,
                              "WaitBrick": BrickType.waitBrick,
                              "BroadcastScript": BrickType.receiveBrick,
                              "BroadcastBrick": BrickType.broadcastBrick,
                              "BroadcastWaitBrick": BrickType.broadcastWaitBrick,
                              "NoteBrick": BrickType.noteBrick,
                              "ForeverBrick": BrickType.foreverBrick,
                              "IfLogicBeginBrick": BrickType.ifBrick,
                              "IfThenLogicBeginBrick": BrickType.ifThenBrick,
                              "IfLogicElseBrick": BrickType.ifElseBrick,
                              "IfLogicEndBrick": BrickType.ifEndBrick,
                              "IfThenLogicEndBrick": BrickType.ifThenEndBrick,
                              "WaitUntilBrick": BrickType.waitUntilBrick,
                              "RepeatBrick": BrickType.repeatBrick,
                              "RepeatUntilBrick": BrickType.repeatUntilBrick,
                              "LoopEndBrick": BrickType.loopEndBrick,
                              "PlaceAtBrick": BrickType.placeAtBrick,
                              "SetXBrick": BrickType.setXBrick,
                              "SetYBrick": BrickType.setYBrick,
                              "ChangeXByNBrick": BrickType.changeXByNBrick,
                              "ChangeYByNBrick": BrickType.changeYByNBrick,
                              "IfOnEdgeBounceBrick": BrickType.ifOnEdgeBounceBrick,
                              "MoveNStepsBrick": BrickType.moveNStepsBrick,
                              "TurnLeftBrick": BrickType.turnLeftBrick,
                              "TurnRightBrick": BrickType.turnRightBrick,
                              "PointInDirectionBrick": BrickType.pointInDirectionBrick,
                              "PointToBrick": BrickType.pointToBrick,
                              "GlideToBrick": BrickType.glideToBrick,
                              "GoNStepsBackBrick": BrickType.goNStepsBackBrick,
                              "ComeToFrontBrick": BrickType.comeToFrontBrick,
                              "VibrationBrick": BrickType.vibrationBrick,
                              "PlaySoundBrick": BrickType.playSoundBrick,
                              "StopAllSoundsBrick": BrickType.stopAllSoundsBrick,
                              "SetVolumeToBrick": BrickType.setVolumeToBrick,
                              "ChangeVolumeByNBrick": BrickType.changeVolumeByNBrick,
                              "SpeakBrick": BrickType.speakBrick,
                              "SpeakAndWaitBrick": BrickType.speakAndWaitBrick,
                              "SetLookBrick": BrickType.setLookBrick,
                              "SetBackgroundBrick": BrickType.setBackgroundBrick,
                              "NextLookBrick": BrickType.nextLookBrick,
                              "PreviousLookBrick": BrickType.previousLookBrick,
                              "SetSizeToBrick": BrickType.setSizeToBrick,
                              "ChangeSizeByNBrick": BrickType.changeSizeByNBrick,
                              "HideBrick": BrickType.hideBrick,
                              "ShowBrick": BrickType.showBrick,
                              "SetTransparencyBrick": BrickType.setTransparencyBrick,
                              "ChangeTransparencyByNBrick": BrickType.changeTransparencyByNBrick,
                              "SetBrightnessBrick": BrickType.setBrightnessBrick,
                              "ChangeBrightnessByNBrick": BrickType.changeBrightnessByNBrick,
                              "SetColorBrick": BrickType.setColorBrick,
                              "ChangeColorByNBrick": BrickType.changeColorByNBrick,
                              "ClearGraphicEffectBrick": BrickType.clearGraphicEffectBrick,
                              "FlashBrick": BrickType.flashBrick,
                              "CameraBrick": BrickType.cameraBrick,
                              "ChooseCameraBrick": BrickType.chooseCameraBrick,
                              "SayBubbleBrick": BrickType.sayBubbleBrick,
                              "SayForBubbleBrick": BrickType.sayForBubbleBrick,
                              "ThinkBubbleBrick": BrickType.thinkBubbleBrick,
                              "ThinkForBubbleBrick": BrickType.thinkForBubbleBrick,
                              "SetVariableBrick": BrickType.setVariableBrick,
                              "ChangeVariableBrick": BrickType.changeVariableBrick,
                              "ShowTextBrick": BrickType.showTextBrick,
                              "HideTextBrick": BrickType.hideTextBrick,
                              "AddItemToUserListBrick": BrickType.addItemToUserListBrick,
                              "DeleteItemOfUserListBrick": BrickType.deleteItemOfUserListBrick,
                              "InsertItemIntoUserListBrick": BrickType.insertItemIntoUserListBrick,
                              "ReplaceItemInUserListBrick": BrickType.replaceItemInUserListBrick,
                              "ArduinoSendDigitalValueBrick": BrickType.arduinoSendDigitalValueBrick,
                              "ArduinoSendPWMValueBrick": BrickType.arduinoSendPWMValueBrick,
                              "PhiroMotorStopBrick": BrickType.phiroMotorStopBrick,
                              "PhiroMotorMoveForwardBrick": BrickType.phiroMotorMoveForwardBrick,
                              "PhiroMotorMoveBackwardBrick": BrickType.phiroMotorMoveBackwardBrick,
                              "PhiroPlayToneBrick": BrickType.phiroPlayToneBrick,
                              "PhiroRGBLightBrick": BrickType.phiroRGBLightBrick,
                              "PhiroIfLogicBeginBrick": BrickType.phiroIfLogicBeginBrick]

// brick heights
enum BrickHeightType : CGFloat {
    case height1 = 48.9
    case height2 = 75.9
    case height3 = 98.9
    case control1 = 72.4
    case control2 = 99.4
};

@objc
enum BrickShapeType : Int {
    case brickShapeSquareSmall = 0
    case brickShapeRoundedSmall
    case brickShapeRoundedBig
}
// TODO: CONVERT Either remove this or cellheight functions
let kBrickHeightMap = ["StartScript": BrickHeightType.control1,
                       "WhenScript": BrickHeightType.control1,
                       "WhenTouchDownScript": BrickHeightType.control1,
                       "WaitBrick": BrickHeightType.height1,
                       "BroadcastScript": BrickHeightType.control2,
                       "BroadcastBrick": BrickHeightType.height2,
                       "BroadcastWaitBrick": BrickHeightType.height2,
                       "NoteBrick": BrickHeightType.height2,
                       "ForeverBrick": BrickHeightType.height1,
                       "IfLogicBeginBrick": BrickHeightType.height1,
                       "IfThenLogicBeginBrick": BrickHeightType.height1,
                       "IfLogicElseBrick": BrickHeightType.height1,
                       "IfLogicEndBrick": BrickHeightType.height1,
                       "IfThenLogicEndBrick": BrickHeightType.height1,
                       "WaitUntilBrick": BrickHeightType.height1,
                       "RepeatBrick": BrickHeightType.height1,
                       "RepeatUntilBrick": BrickHeightType.height1,
                       "LoopEndBrick": BrickHeightType.height1,
                       "PlaceAtBrick": BrickHeightType.height2,
                       "SetXBrick": BrickHeightType.height1,
                       "SetYBrick": BrickHeightType.height1,
                       "ChangeXByNBrick": BrickHeightType.height1,
                       "ChangeYByNBrick": BrickHeightType.height1,
                       "IfOnEdgeBounceBrick": BrickHeightType.height1,
                       "MoveNStepsBrick": BrickHeightType.height1,
                       "TurnLeftBrick": BrickHeightType.height1,
                       "TurnRightBrick": BrickHeightType.height1,
                       "PointInDirectionBrick": BrickHeightType.height1,
                       "PointToBrick": BrickHeightType.height2,
                       "GlideToBrick": BrickHeightType.height3,
                       "GoNStepsBackBrick": BrickHeightType.height1,
                       "ComeToFrontBrick": BrickHeightType.height1,
                       "VibrationBrick": BrickHeightType.height1,
                       "PlaySoundBrick": BrickHeightType.height2,
                       "StopAllSoundsBrick": BrickHeightType.height1,
                       "SetVolumeToBrick": BrickHeightType.height1,
                       "ChangeVolumeByNBrick": BrickHeightType.height1,
                       "SpeakBrick": BrickHeightType.height2,
                       "SpeakAndWaitBrick": BrickHeightType.height2,
                       "SetLookBrick": BrickHeightType.height2,
                       "SetBackgroundBrick": BrickHeightType.height2,
                       "NextLookBrick": BrickHeightType.height1,
                       "PreviousLookBrick": BrickHeightType.height1,
                       "SetSizeToBrick": BrickHeightType.height1,
                       "ChangeSizeByNBrick": BrickHeightType.height1,
                       "HideBrick": BrickHeightType.height1,
                       "ShowBrick": BrickHeightType.height1,
                       "SetTransparencyBrick": BrickHeightType.height2,
                       "ChangeTransparencyByNBrick": BrickHeightType.height2,
                       "SetBrightnessBrick": BrickHeightType.height2,
                       "ChangeBrightnessByNBrick": BrickHeightType.height2,
                       "ClearGraphicEffectBrick": BrickHeightType.height1,
                       "SetColorBrick": BrickHeightType.height1,
                       "ChangeColorByNBrick": BrickHeightType.height1,
                       "FlashBrick": BrickHeightType.height2,
                       "CameraBrick": BrickHeightType.height2,
                       "ChooseCameraBrick": BrickHeightType.height2,
                       "SayBubbleBrick": BrickHeightType.height2,
                       "SayForBubbleBrick": BrickHeightType.height2,
                       "ThinkBubbleBrick": BrickHeightType.height2,
                       "ThinkForBubbleBrick": BrickHeightType.height2,
                       "SetVariableBrick": BrickHeightType.height3,
                       "ChangeVariableBrick": BrickHeightType.height3,
                       "ShowTextBrick": BrickHeightType.height3,
                       "HideTextBrick": BrickHeightType.height2,
                       "AddItemToUserListBrick": BrickHeightType.height2,
                       "DeleteItemOfUserListBrick": BrickHeightType.height3,
                       "InsertItemIntoUserListBrick": BrickHeightType.height3,
                       "ReplaceItemInUserListBrick": BrickHeightType.height3,
                       "ArduinoSendDigitalValueBrick": BrickHeightType.height2,
                       "ArduinoSendPWMValueBrick": BrickHeightType.height2,
                       "PhiroMotorStopBrick": BrickHeightType.height2,
                       "PhiroMotorMoveForwardBrick": BrickHeightType.height3,
                       "PhiroMotorMoveBackwardBrick": BrickHeightType.height3,
                       "PhiroPlayToneBrick": BrickHeightType.height3,
                       "PhiroRGBLightBrick": BrickHeightType.height3,
                       "PhiroIfLogicBeginBrick": BrickHeightType.height1]

// brick subview const values
let kBrickInlineViewOffsetX: CGFloat = 54.0
let kBrickShapeNormalInlineViewOffsetY: CGFloat = 4.0
let kBrickShapeRoundedSmallInlineViewOffsetY: CGFloat = 20.7
let kBrickShapeRoundedBigInlineViewOffsetY: CGFloat = 37.0
let kBrickShapeNormalMarginHeightDeduction: CGFloat = 14.0
let kBrickShapeRoundedSmallMarginHeightDeduction: CGFloat = 27.0
let kBrickShapeRoundedBigMarginHeightDeduction: CGFloat = 47.0
let kBrickPatternImageViewOffsetX: CGFloat = 0.0
let kBrickPatternImageViewOffsetY: CGFloat = 0.0
let kBrickPatternBackgroundImageViewOffsetX: CGFloat = 54.0
let kBrickPatternBackgroundImageViewOffsetY: CGFloat = 0.0
let kBrickLabelOffsetX: CGFloat = 0.0
let kBrickLabelOffsetY: CGFloat = 5.0
let kBrickInlineViewCanvasOffsetX: CGFloat = 0.0
let kBrickInlineViewCanvasOffsetY: CGFloat = 0.0
let kBrickBackgroundImageNameSuffix = "_bg"

let kBrickLabelFontSize: CGFloat = 15.0
let kBrickTextFieldFontSize: CGFloat = 15.0
let kBrickInputFieldHeight: CGFloat = 28.0
let kBrickInputFieldMinWidth: CGFloat = 40.0
let kBrickInputFieldMaxWidth: CGFloat = Util.screenWidth() / 2.0
let kBrickComboBoxWidth: CGFloat = Util.screenWidth() - 65
let kBrickInputFieldTopMargin: CGFloat = 4.0
let kBrickInputFieldBottomMargin: CGFloat = 5.0
let kBrickInputFieldLeftMargin: CGFloat = 4.0
let kBrickInputFieldRightMargin: CGFloat = 4.0
let kBrickInputFieldMinRowHeight: CGFloat = kBrickInputFieldHeight
let kDefaultImageCellBorderWidth: CGFloat = 0.5
