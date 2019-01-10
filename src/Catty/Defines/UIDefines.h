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

// Screen Sizes in Points
#define kIphone4ScreenHeight 480.0f
#define kIphone5ScreenHeight 568.0f
#define kIphone6PScreenHeight 736.0f
#define kIpadScreenHeight 1028.0f

// Blocked characters for program names, object names, images names, sounds names and variable/list names
#define kTextFieldBlockedCharacters @""

#define kMenuImageNameContinue @"continue"
#define kMenuImageNameNew @"new"
#define kMenuImageNamePrograms @"programs"
#define kMenuImageNameHelp @"help"
#define kMenuImageNameExplore @"explore"
#define kMenuImageNameUpload @"upload"

// view tags
#define kPlaceHolderTag        99994
#define kLoadingViewTag        99995
#define kSavedViewTag          99996
#define kRegistrationViewTag   99997
#define kLoginViewTag          99998
#define kUploadViewTag         99999

#define kAddScriptCategoryTableViewBottomMargin 15.0f

// delete button bricks
#define kBrickCellDeleteButtonWidthHeight 22.0f
#define kSelectButtonnOffset 30.0f
#define kSelectButtonTranslationOffsetX 60.0f
#define kScriptCollectionViewTopInsets 10.0f
#define kScriptCollectionViewBottomInsets 5.0f

// Notifications
static NSString *const kBrickCellAddedNotification = @"BrickCellAddedNotification";
static NSString *const kSoundAddedNotification = @"SoundAddedNotification";
static NSString *const kRecordAddedNotification = @"RecordAddedNotification";
static NSString *const kBrickDetailViewDismissed = @"BrickDetailViewDismissed";
static NSString *const kProgramDownloadedNotification = @"ProgramDownloadedNotification";
static NSString *const kHideLoadingViewNotification = @"HideLoadingViewNotification";
static NSString *const kShowSavedViewNotification = @"ShowSavedViewNotification";
static NSString *const kReadyToUpload = @"ReadyToUploadProgram";
static NSString *const kLoggedInNotification = @"LoggedInNotification";

// Notification keys
static NSString *const kUserInfoKeyBrickCell = @"UserInfoKeyBrickCell";
static NSString *const kUserInfoSpriteObject = @"UserInfoSpriteObject";
static NSString *const kUserInfoSound = @"UserInfoSound";

// UI Elements
#define kNavigationbarHeight 64.0f
#define kToolbarHeight 44.0f
#define kHandleImageHeight 15.0f
#define kHandleImageWidth 40.0f
#define kOffsetTopBrickSelectionView 70.0f

//BDKNotifyHUD
#define kBDKNotifyHUDDestinationOpacity 0.3f
#define kBDKNotifyHUDCenterOffsetY (-20.0f)
#define kBDKNotifyHUDPresentationDuration 0.5f
#define kBDKNotifyHUDPresentationSpeed 0.1f
#define kBDKNotifyHUDPaddingTop 30.0f
static NSString *const kBDKNotifyHUDCheckmarkImageName = @"checkmark.png";

#define kFormulaEditorShowResultDuration 4.0f
#define kFormulaEditorTopOffset 64.0f
