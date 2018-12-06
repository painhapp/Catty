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

#import "ScenePresenterViewController.h"
#import "Util.h"
#import "Script.h"
#import "AudioManager.h"
#import "FlashHelper.h"
#import "CameraPreviewHandler.h"
#import "CatrobatLanguageDefines.h"
#import "Pocket_Code-Swift.h"
#import "RuntimeImageCache.h"

#define kSlidingStartArea 40
#define kMenuAnimationDuration 0.25

@interface ScenePresenterViewController() <UIActionSheetDelegate>
@property (nonatomic, strong) CBScene *scene;
@property (nonatomic, strong) SKView *skView;

@property (nonatomic) BOOL menuOpen;
@property (nonatomic) CGPoint firstGestureTouchPoint;
@property (nonatomic) UIImage *snapshotImage;
@property (nonatomic, strong) UIView *gridView;
@end

@implementation ScenePresenterViewController

- (void)stopProgram
{
    [self.scene stopProgram];
    
    // TODO remove Singletons
    [[AudioManager sharedAudioManager] stopAllSounds];
    [[AudioManager sharedAudioManager] stopSpeechSynth];
    [[CameraPreviewHandler shared] stopCamera];
    
    [[FlashHelper sharedFlashHandler] reset];
    [[FlashHelper sharedFlashHandler] turnOff]; // always turn off flash light when Scene is stopped
    
    [[BluetoothService sharedInstance] setScenePresenter:nil];
    [[BluetoothService sharedInstance] resetBluetoothDevice];
}

#pragma mark - View Event Handling
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    self.skView.backgroundColor = UIColor.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    UIApplication.sharedApplication.statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.toolbarHidden = YES;
    // disable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.menuOpen = NO;
    
    [self.view addSubview:self.skView];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"SceneMenuView" owner:self options:nil];
    self.menuView = [subviewArray objectAtIndex:0];
    [self.view insertSubview:self.menuView aboveSubview:self.skView];
    self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.menuView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    self.menuViewLeadingConstraint = [self.menuView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor];
    self.menuViewLeadingConstraint.active = YES;
    [self.view layoutIfNeeded];

    [self setUpMenuButtons];
    [self setUpLabels];
    [self setUpGridView];
    [self checkAspectRatio];
    
    [self setupSceneAndStart];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.menuView removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.toolbarHidden = NO;
    UIApplication.sharedApplication.statusBarHidden = NO;
    UIApplication.sharedApplication.idleTimerDisabled = NO;
    
    // reenable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.skView.bounds = self.view.bounds;
}

#pragma mark - Initialization & Setup & Dealloc
#pragma mark Dealloc
- (void)dealloc
{
    [self freeRessources];
}

- (void)freeRessources
{
    self.program = nil;
    self.scene = nil;
    
    // Delete sound rec for loudness sensor
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *soundfile = [documentsPath stringByAppendingPathComponent:@"loudness_handler.m4a"];
    if ([fileMgr removeItemAtPath:soundfile error:&error] != YES)
        NSDebug(@"No Sound file available or unable to delete file: %@", [error localizedDescription]);
}

#pragma mark View Setup
- (void)setUpLabels
{
    NSArray *labelTextArray = [[NSArray alloc] initWithObjects:kLocalizedBack,
                               kLocalizedRestart,
                               kLocalizedContinue,
                               kLocalizedPreview,
                               kLocalizedAxes, nil];
    NSArray* labelArray = [[NSArray alloc] initWithObjects:self.menuBackLabel, self.menuRestartLabel, self.menuContinueLabel, self.menuScreenshotLabel, self.menuAxisLabel, nil];
    for (int i = 0; i < [labelTextArray count]; ++i) {
        [self setupLabel:labelTextArray[i]
                 andView:labelArray[i]];
    }
    [self.menuBackLabel addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContinueLabel addTarget:self action:@selector(continueAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuScreenshotLabel addTarget:self action:@selector(takeScreenshotAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuRestartLabel addTarget:self action:@selector(restartAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuAxisLabel addTarget:self action:@selector(showHideAxisAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupLabel:(NSString*)name andView:(UIButton*)label
{
    [label setTitle:name forState:UIControlStateNormal];
    label.tintColor = [UIColor navTintColor];
    label.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:(14.0)];
    label.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setUpMenuButtons
{
    [self setupButtonWithButton:self.menuBackButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_back"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_back_pressed"]
                    andSelector:@selector(stopAction:)];
    [self setupButtonWithButton:self.menuContinueButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_continue"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_continue_pressed"]
                    andSelector:@selector(continueAction:)];
    [self setupButtonWithButton:self.menuScreenshotButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_screenshot"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_screenshot_pressed"]
                    andSelector:@selector(takeScreenshotAction:)];
    [self setupButtonWithButton:self.menuRestartButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_restart"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_restart_pressed"]
                    andSelector:@selector(restartAction:)];
    [self setupButtonWithButton:self.menuAxisButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_toggle_axis"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_toggle_axis_pressed"]
                    andSelector:@selector(showHideAxisAction:)];
    [self setupButtonWithButton:self.menuAspectRatioButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_aspect_ratio"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_aspect_ratio_pressed"]
                    andSelector:@selector(manageAspectRatioAction:)];
}

- (void)setupButtonWithButton:(UIButton*)button ImageNameNormal:(UIImage*)stateNormal
      andImageNameHighlighted:(UIImage*)stateHighlighted andSelector:(SEL)myAction
{
    [button setBackgroundImage:stateNormal forState:UIControlStateNormal];
    [button setBackgroundImage:stateHighlighted forState:UIControlStateHighlighted];
    [button setBackgroundImage:stateHighlighted forState:UIControlStateSelected];
    [button addTarget:self action:myAction forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUpGridView
{
    self.gridView.backgroundColor = [UIColor clearColor];
    UIView *xArrow = [[UIView alloc] initWithFrame:CGRectMake(0,[Util screenHeight]/2,[Util screenWidth],1)];
    xArrow.backgroundColor = [UIColor redColor];
    [self.gridView addSubview:xArrow];
    UIView *yArrow = [[UIView alloc] initWithFrame:CGRectMake([Util screenWidth]/2,0,1,[Util screenHeight])];
    yArrow.backgroundColor = [UIColor redColor];
    [self.gridView addSubview:yArrow];
    // nullLabel
    UILabel *nullLabel = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight]/2 + 5, 10, 15)];
    nullLabel.text = @"0";
    nullLabel.textColor = [UIColor redColor];
    [self.gridView addSubview:nullLabel];
    // positveWidth
    UILabel *positiveWidth = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]- 40, [Util screenHeight]/2 + 5, 30, 15)];
    positiveWidth.text = [NSString stringWithFormat:@"%d",(int)self.program.header.screenWidth.floatValue/2];
    positiveWidth.textColor = [UIColor redColor];
    [positiveWidth sizeToFit];
    positiveWidth.frame = CGRectMake([Util screenWidth] - positiveWidth.frame.size.width - 5, [Util screenHeight]/2 + 5, positiveWidth.frame.size.width, positiveWidth.frame.size.height);
    [self.gridView addSubview:positiveWidth];
    // negativeWidth
    UILabel *negativeWidth = [[UILabel alloc] initWithFrame:CGRectMake(5, [Util screenHeight]/2 + 5, 40, 15)];
    negativeWidth.text = [NSString stringWithFormat:@"-%d",(int)self.program.header.screenWidth.floatValue/2];
    negativeWidth.textColor = [UIColor redColor];
    [negativeWidth sizeToFit];
    [self.gridView addSubview:negativeWidth];
    // positveHeight
    UILabel *positiveHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight] - 20, 40, 15)];
    positiveHeight.text = [NSString stringWithFormat:@"-%d",(int)self.program.header.screenHeight.floatValue/2];
    positiveHeight.textColor = [UIColor redColor];
    [positiveHeight sizeToFit];
    [self.gridView addSubview:positiveHeight];
    // negativeHeight
    UILabel *negativeHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5,5, 40, 15)];
    negativeHeight.text = [NSString stringWithFormat:@"%d",(int)self.program.header.screenHeight.floatValue/2];
    negativeHeight.textColor = [UIColor redColor];
    [negativeHeight sizeToFit];
    [self.gridView addSubview:negativeHeight];
    
    [self.view insertSubview:self.gridView aboveSubview:self.skView];
}

- (void)checkAspectRatio
{
    if (self.program.header.screenWidth.floatValue == [Util screenWidth:true] && self.program.header.screenHeight.floatValue == [Util screenHeight:true]) {
        self.menuAspectRatioButton.hidden = YES;
    }
}

- (void)setupSceneAndStart
{
    // Initialize scene
    CBScene *scene = [[[[SceneBuilder alloc] initWithProgram:self.program] andFormulaManager:self.formulaManager] build];
    
    if ([self.program.header.screenMode isEqualToString: kCatrobatHeaderScreenModeMaximize]) {
        scene.scaleMode = SKSceneScaleModeFill;
    } else if ([self.program.header.screenMode isEqualToString: kCatrobatHeaderScreenModeStretch]){
        scene.scaleMode = SKSceneScaleModeAspectFit;
    } else {
        scene.scaleMode = SKSceneScaleModeFill;
    }
    self.skView.paused = NO;
    self.scene = scene;
    
    [[BluetoothService sharedInstance] setScenePresenter:self];
    [[CameraPreviewHandler shared] setCamView:self.view];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self.skView presentScene:self.scene];
    [self.scene startProgram];
    
    self.menuView.userInteractionEnabled = YES;

    [self hideLoadingView];
    [self hideMenuView];
}

-(void)resaveLooks
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        for (SpriteObject *object in self.program.objectList) {
            for (Look *look in object.lookList) {
                [[RuntimeImageCache sharedImageCache] loadImageFromDiskWithPath:look.fileName];
            }
        }
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Game Event Handling
- (void)pauseAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[AudioManager sharedAudioManager] pauseAllSounds];
        [[AudioManager sharedAudioManager] pauseSpeechSynth];
        [[FlashHelper sharedFlashHandler] pause];
        [[BluetoothService sharedInstance] pauseBluetoothDevice];
    });
    
    [self.scene pauseScheduler];
}

- (void)resumeAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[AudioManager sharedAudioManager] resumeAllSounds];
        [[AudioManager sharedAudioManager] resumeSpeechSynth];
        [[BluetoothService sharedInstance] continueBluetoothDevice];
        if ([FlashHelper sharedFlashHandler].wasTurnedOn == FlashON) {
            [[FlashHelper sharedFlashHandler] resume];
        }
    });
    
    [self.scene resumeScheduler];
}

- (void)continueAction:(UIButton*)sender
{
    [self resumeAction];
    [self hideMenuView];
}

- (void)stopAction:(UIButton*)sender
{
    CBScene *previousScene = self.scene;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        self.menuView.userInteractionEnabled = NO;
        previousScene.userInteractionEnabled = NO;
        [self stopProgram];
        previousScene.userInteractionEnabled = YES;
    });
    
    
    [self.parentViewController.navigationController setToolbarHidden:NO];
    [self.parentViewController.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restartAction:(UIButton*)sender
{
    [self showLoadingView];
    
    self.menuView.userInteractionEnabled = NO;
    self.scene.userInteractionEnabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self stopProgram];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            self.program = [Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]];
            [self setupSceneAndStart];
        });
    });
}

#pragma mark - Bluetooth Event Handling
-(void)connectionLost
{
    [self showLoadingView];
    self.menuView.userInteractionEnabled = NO;
    CBScene *previousScene = self.scene;
    previousScene.userInteractionEnabled = NO;
    [self stopProgram];
    previousScene.userInteractionEnabled = YES;
    [self hideLoadingView];
    
    [[[[AlertControllerBuilder alertWithTitle:@"Lost Bluetooth Connection" message:kLocalizedPocketCode]
       addCancelActionWithTitle:kLocalizedOK handler:^{
           [self.parentViewController.navigationController setToolbarHidden:NO];
           [self.parentViewController.navigationController setNavigationBarHidden:NO];
           [self.navigationController popViewControllerAnimated:YES];
       }] build]
     showWithController:self];
}

#pragma mark - User Event Handling

- (void)showHideAxisAction:(UIButton*)sender
{
    if (self.gridView.hidden == NO) {
        self.gridView.hidden = YES;
    } else {
        self.gridView.hidden = NO;
    }
}

- (void)manageAspectRatioAction:(UIButton *)sender
{
    self.scene.scaleMode = self.scene.scaleMode == SKSceneScaleModeAspectFit ? SKSceneScaleModeFill : SKSceneScaleModeAspectFit;
    self.program.header.screenMode = [self.program.header.screenMode isEqualToString:kCatrobatHeaderScreenModeStretch] ? kCatrobatHeaderScreenModeMaximize :kCatrobatHeaderScreenModeStretch;
    [self.skView setNeedsLayout];
}

- (void)takeScreenshotAction:(UIButton*)sender
{
    [self takeManualScreenshotForSKView:self.skView andProgram:self.program];
}

#pragma mark - Pan Gesture Handler

- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    CGPoint translate = [gesture translationInView:gesture.view];
    translate.y = 0.0;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.firstGestureTouchPoint = [gesture locationInView:gesture.view];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (translate.x > 0.0 &&
            translate.x < self.menuView.frame.size.width &&
            self.firstGestureTouchPoint.x < kSlidingStartArea &&
            self.menuOpen == NO) {
            [self handlePositvePan:translate];
        } else if (translate.x < 0.0 &&
                   translate.x > -self.menuView.frame.size.width &&
                   self.menuOpen == YES) {
            [self handleNegativePan:translate];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed) {
        if (translate.x > (self.menuView.frame.size.width/4) &&
            self.firstGestureTouchPoint.x < kSlidingStartArea &&
            self.menuOpen == NO) {
            //user opened at least 1/4 of the menu -> show
            [self showMenuView];
        } else if(translate.x > 0.0 &&
                  translate.x < (self.menuView.frame.size.width/4) &&
                  self.firstGestureTouchPoint.x < kSlidingStartArea &&
                  self.menuOpen == NO) {
            //user did not open at least 1/4 of the menu -> abort/hide
            [self hideMenuView];
        } else if (translate.x < (-self.menuView.frame.size.width/4) &&
                   self.menuOpen == YES) {
            //user closed at least 1/4 of the opened menu -> hide
            [self hideMenuView];
        } else if (translate.x < 0.0 &&
                   translate.x > (-self.menuView.frame.size.width/4) &&
                   self.menuOpen == YES) {
            //user did not close at least 1/4 of the menu -> abort/show
            [self showMenuView];
        } else {
            //if anything goes wrong, hide the menu view
            [self hideMenuView];
        }
    }
}

- (void)handlePositvePan:(CGPoint)translate
{
    [UIView animateWithDuration:kMenuAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view bringSubviewToFront:self.menuView];
                         self.menuViewLeadingConstraint.constant = -self.menuView.frame.size.width + translate.x;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)handleNegativePan:(CGPoint)translate
{
    [UIView animateWithDuration:kMenuAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.menuViewLeadingConstraint.constant = translate.x;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)showMenuView
{
    [UIView animateWithDuration:kMenuAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view bringSubviewToFront:self.menuView];
                         self.menuViewLeadingConstraint.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.menuOpen = YES;
                         self.skView.paused=YES;
                         [self pauseAction];
                     }];
}

- (void)hideMenuView
{
    [UIView animateWithDuration:kMenuAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.menuViewLeadingConstraint.constant = -self.menuView.frame.size.width;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.menuOpen = NO;
                         if (self.skView.paused) {
                             self.skView.paused = NO;
                             [self resumeAction];
                         } else {
                             [self takeAutomaticScreenshotForSKView:self.skView andProgram:self.program];
                         }
                     }];
}

#pragma mark - Getters & Setters
- (UIView*)gridView
{
    // lazy instantiation
    if (! _gridView) {
        _gridView = [[UIView alloc]initWithFrame:self.view.bounds];
        _gridView.hidden = YES;
    }
    return _gridView;
}

- (LoadingView*)loadingView
{
    // lazy instantiation
    if (! _loadingView) {
        _loadingView = [LoadingView new];
        [self.view addSubview:_loadingView];
        [self.view bringSubviewToFront:_loadingView];
    }
    return _loadingView;
}

- (void)showLoadingView
{
    [self.loadingView show];
}

- (void)hideLoadingView
{
    [self.loadingView hide];
}

- (SKView*)skView
{
    if (!_skView) {
        _skView = [[SKView alloc] initWithFrame:self.view.bounds];
#if DEBUG == 1
        _skView.showsFPS = YES;
        _skView.showsNodeCount = YES;
        _skView.showsDrawCount = YES;
#endif
    }
    return _skView;
}

#pragma mark - Helpers
- (UIImage*)brightnessBackground:(UIImage*)startImage {
    CGImageRef image = startImage.CGImage;
    CIImage *ciImage =[ CIImage imageWithCGImage:image];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                  keysAndValues:kCIInputImageKey, ciImage, @"inputBrightness",
                        @(-0.5), nil];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *output = [UIImage imageWithCGImage:cgimg];
    CFRelease(cgimg);
    return output;
}

@end
