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

//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

//------------------------------------------------------------------------------------------------------------
// Extension classes
//------------------------------------------------------------------------------------------------------------

#import "UIImage+CatrobatUIImageExtensions.h"

//------------------------------------------------------------------------------------------------------------
// Util classes
//------------------------------------------------------------------------------------------------------------

#import "CBFileManager.h"
#import "AudioManager.h"
#import "FlashHelper.h"
#import "LanguageTranslationDefines.h"
#import "RuntimeImageCache.h"
#import "CBMutableCopyContext.h"
#import "CameraPreviewHandler.h"
#import "BubbleBrickHelper.h"

//------------------------------------------------------------------------------------------------------------
// ViewController classes
//------------------------------------------------------------------------------------------------------------

//AppDelegate
#import "CatrobatTableViewController.h"

#import "BaseTableViewController.h"
#import "FormulaEditorViewController.h"
#import "MyProgramsViewController.h"
#import "ProgramTableViewController.h"

//------------------------------------------------------------------------------------------------------------

// Defines
//------------------------------------------------------------------------------------------------------------

#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "KeychainUserDefaultsDefines.h"
#import "CatrobatLanguageDefines.h"

//-----------------------------------------------------------------------------------------------------------
// Headers to sort
//-----------------------------------------------------------------------------------------------------------
#import "CatrobatInformation.h"
#import "CatrobatProgram.h"
#import "CellTagDefines.h"
#import "SegueDefines.h"
#import "DarkBlueGradientFeaturedCell.h"
#import "Parser.h"
#import "OrderedMapTable.h"
#import "UIDefines.h"

// User
#import <CommonCrypto/CommonCrypto.h>
#import "JNKeychain.h"

//Conversion NEU

#import "Util.h"
#import "BrickCell.h"
#import "VariablesContainer.h"
#import "NSString+FastImageSize.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "OrderedMapTable.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "iOSCombobox.h"
#import "CBXMLParser.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializer.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLValidator.h"
#import "CBStack.h"
#import "GDataXMLNode.h"
#import "ButtonTags.h"
#import "BrickManager.h"
#import "AudioManager.h"
#import "LooksTableViewController.h"
#import "FormulaEditorTextView.h"
#import "BDKNotifyHUD.h"
#import "EVCircularProgressView.h"
#import "SpriteObject.h"
