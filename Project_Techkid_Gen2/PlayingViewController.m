//
//  PlayingViewController.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/1/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "PlayingViewController.h"
#import "XCDYouTubeKit/XCDYouTubeKit.h"
#import "Video.h"
#import "CoreDataManaged.h"
#import "UIImageView+WebCache.h"
#import "SelectPlaylistViewController.h"
#import "AppDelegate.h"
#import "SettingViewController.h"


#define kDurationAnimateSliding 0.5f
@interface PlayingViewController ()<UIGestureRecognizerDelegate>
{
    CoreDataManaged *core;
    Boolean sliderProgressEditing;
    Boolean requesting;
    CGFloat savingCureentTime;
    BOOL check;
    NSInteger indexQuality;
    UIActivityIndicatorView *loadview;
    NSArray *repeat;
    NSInteger index;
    NSInteger quality;
    NSString *qualityString;
    BOOL *fullScreen;
    CGRect portraitFrame;
}

@property(nonatomic,assign) CGPoint startpoint;

@end

@implementation PlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fullScreen = NO;
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Do any additional setup after loading the view.
    _btnPlayPause.selected = YES;
    self.PlayPauseVIew.selected = YES;
    core = Instance;
    self.modelPlaying = InstanceModel;
    self.modelPlaying.playerView = self.videoContainerView;
    
    repeat = @[@"repeat_none",@"repeat_one",@"repeat_all"];
    index = 0;
    
    
    //save frame of portrait for later come back
    portraitFrame = self.viewPlaying.frame;
    
    
    self.lbltitle.marqueeType = MLContinuous;
    self.lbltitle.animationDelay = 2.0f;
    self.lblName.marqueeType = MLContinuous;
    self.lblName.animationDelay = 2.0f;

    self.lblName.textColor = [UIColor orangeColor];
    self.lbltitle.textColor = [UIColor orangeColor];
    // change color
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor redColor]};
    
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    
    //get orientation
    [[UIDevice currentDevice]orientation];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(deviceDidchangeOrientation:)
                                                name:UIDeviceOrientationDidChangeNotification
                                              object:nil];
    self.viewQuality.hidden = YES;
    indexQuality = 22;
    check = false;
    [self initWithMax:CMTimeGetSeconds(self.modelPlaying.playerItem.duration)
               andMin:0
            andSlider:self.sliderProgress
          andProgress:self.progressCustom1];
            self.PlayPauseVIew.selected = NO;
    self.playerState = PLAYER_STATE_HIDDEN;
    // Do any additional setup after loading the view.
    [self configGesture];
    self.modelPlaying.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(setQuality:)
                                                name:@"Quality"
                                              object:nil];
    
    self.sliderVolumb.maximumValue = 1;
    self.sliderVolumb.minimumValue = 0;
}

-(void)setQuality:(NSNotification *)notifi;
{
    id object = [notifi object];
    NSString *A = object;
    if ([A isEqualToString:@""]) {
        
    }else{
        if ([A isEqualToString:@"720"]) {
            indexQuality = 22;
        }else if([A isEqualToString:@"360"]){
            indexQuality = 18;
        }else{
            indexQuality = 36;
        }
        qualityString = A;
    }
}

-(void)configGesture;
{
    // Pan -> move
    UIGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didpan:)];
    panGesture.delegate = self;
    [self.viewGesture addGestureRecognizer:panGesture];
    
    //swipe to next/ previous
    UISwipeGestureRecognizer *swipRightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didswip:)];
    swipRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipLeftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didswip:)];
    swipLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    swipLeftGesture.delegate = self;
    swipRightGesture.delegate = self;
    
    [self.viewGesture addGestureRecognizer:swipRightGesture];
    [self.viewGesture addGestureRecognizer:swipLeftGesture];
    
    // pig -> scale
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didpig:)];
    pinchGesture.delegate = self;
    [self.viewPlaying addGestureRecognizer:pinchGesture];
    
}

-(void)didpig:(UIPinchGestureRecognizer *)gesture;
{
    if (gesture.scale >= 1.2) {
        [self toggleFullscreen:YES  orientation:UIInterfaceOrientationLandscapeRight];
    }else if(gesture.scale <= 0.8){
        [self toggleFullscreen:NO  orientation:UIInterfaceOrientationPortrait];
    }
}

-(void)didpan:(UIPanGestureRecognizer *)gesture;
{
    
    CGPoint translationPoint = [gesture translationInView:gesture.view];
    
    CGFloat distanceY = translationPoint.y - self.startpoint.y;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.startpoint = translationPoint;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self movePlayerByDistance:distanceY];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [gesture setTranslation:CGPointZero inView:gesture.view];
            
            self.startpoint = CGPointZero;
            
            if (self.view.frame.origin.y > self.view.frame.size.height / 3) {
                [self animaeGoingDown];
            }else{
                [self animaeGoingUp];
            }
        }
            break;
        default:
            break;
    }

}

-(void)didswip:(UISwipeGestureRecognizer *)gesture;
{
    check = false;
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        [self pauseNow];
        NSInteger count = [self.modelPlaying.allVideo count];
        [self.modelPlaying changeVideo:(count-1) andQualiy:indexQuality];
    }else{
        [self pauseNow];
        [self.modelPlaying changeVideo:1 andQualiy:indexQuality];
    }
}

-(void)movePlayerByDistance:(CGFloat )distanceY;
{
    CGRect playerFrame = self.view.frame;
    if (self.playerState == PLAYER_STATE_FULLSCREEN) {
        
        playerFrame.origin.y = [self originYFullscreen] + distanceY;
        
    }else if(self.playerState == PLAYER_STATE_HEADER)
    {
        playerFrame.origin.y = [self originYHeader] + distanceY;
    }
    [self.viewHeader setAlpha:1*((self.view.frame.origin.y + self.viewHeader.frame.size.height)/self.view.frame.size.height)];
    self.view.frame = playerFrame;
}

-(CGFloat)originYFullscreen;
{
    //    NSLog(@"%f",self.Viewheader.frame.size.height);
    return -self.viewHeader.frame.size.height;
}

-(CGFloat)originYHeader;
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    //    NSLog(@"%f",mainScreen.bounds.size.height);
    return mainScreen.bounds.size.height + [self originYFullscreen];
}

-(void)animaeGoingUp;
{
    [UIView animateWithDuration:kDurationAnimateSliding animations:^{
        CGRect playFrame = self.view.frame;
        
        playFrame.origin.y = [self originYFullscreen];
        self.view.frame = playFrame;
        [self.viewHeader setAlpha:0];
    } completion:^(BOOL finished) {
        self.playerState = PLAYER_STATE_FULLSCREEN;
    }];
}

-(void)animaeGoingDown;
{
    [UIView animateWithDuration:kDurationAnimateSliding animations:^{
        CGRect playFrame = self.view.frame;
        playFrame.origin.y = [self originYHeader];
        self.view.frame = playFrame;
        [self.viewHeader setAlpha:1];
    } completion:^(BOOL finished) {
        self.playerState = PLAYER_STATE_HEADER;
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)PlayendPause:(id)sender {
    if (!_btnPlayPause.selected) {
        [self playContinue];
        self.PlayPauseVIew.selected = YES;
        _btnPlayPause.selected = YES;
    }else{
        [self pauseNow];
        self.PlayPauseVIew.selected = NO;
        _btnPlayPause.selected = NO;
    }
}

- (IBAction)Appear:(id)sender {
    if (self.Frame.selected) {
                        self.viewControlBotton.hidden = NO;
        [self toggleFullscreen:NO orientation:UIInterfaceOrientationPortrait];
    }
    else{
        [self toggleFullscreen:YES orientation:UIInterfaceOrientationLandscapeRight];
        self.viewControlBotton.hidden = YES;
    }
    self.Frame.selected = !self.Frame.selected;
}

- (IBAction)rewind:(id)sender {
    [self pauseNow];
    NSInteger count = [self.modelPlaying.allVideo count];
    [self.modelPlaying changeVideo:(count - 1) andQualiy:indexQuality];
}


- (IBAction)forward:(id)sender {
    [self pauseNow];
    [self.modelPlaying changeVideo:1 andQualiy:indexQuality];
    }

- (IBAction)repeat:(id)sender {
            [self.repeat setImage:[UIImage imageNamed:[repeat objectAtIndex:index]] forState:UIControlStateNormal];
    if (index <2) {
        index++;
    }else{
        index = 0;
    }
    NSLog(@"%ld",(long)index);
}
- (IBAction)shuffle4:(id)sender {

    if (_shuff.selected) {
        _shuff.selected = NO;
        }
    else{
        _shuff.selected = YES;
    }
}

-(void)checkplayerItemDidReachEnd;
{
    if (index == 1) {
    }else if(index == 2){
        [self.modelPlaying loadfromURLandQuality:indexQuality];
    }else if(index == 0){
        if (!self.shuff.selected) {
            [self.modelPlaying changeVideo:1 andQualiy:indexQuality];
        }else{
            NSInteger random = arc4random() % [self.modelPlaying.allVideo count];
            [self.modelPlaying changeVideo:random andQualiy:indexQuality];
        }
    }
}

- (CGFloat)degreeForOrientation:(UIInterfaceOrientation)orientation;
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return 0;
            return 0.0f;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 0;
            return 0.0f;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return M_PI_2;
            return 90.0f;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return -M_PI_2;
            return 270.0f;
            break;
        default:
            break;
    }
    
    return 0;
}

-(void)toggleFullscreen:(BOOL)fullscreen orientation:(UIInterfaceOrientation)orientation;
{
    if (fullscreen) {
        [[UIApplication sharedApplication]setStatusBarHidden:fullscreen];
    }
    [UIView animateWithDuration:0.5f
     
                          delay:0.0f
     
                        options:UIViewAnimationOptionCurveEaseInOut
     
                     animations:^{
    
                         CGFloat degree = [self degreeForOrientation:orientation];
                         self.viewPlaying.transform = CGAffineTransformMakeRotation(degree);
                         
                         if (fullscreen) {
                             fullScreen = YES;
                             CGRect screenBounds = [[UIScreen mainScreen]bounds];
                             //for landscape
                             CGFloat width = MAX(screenBounds.size.width, screenBounds.size.height);
                             CGFloat height = MIN(screenBounds.size.width, screenBounds.size.height);
                             
                             CGRect newBounds = CGRectMake(0.0f, 0.0f, width, height);
                             
                             self.viewPlaying.bounds = newBounds;
                             
                             //TODO: check frame
                             CGRect frameViewPlaying = self.viewPlaying.frame;
                             frameViewPlaying.origin.x = 0;
                             frameViewPlaying.origin.y = self.viewHeader.frame.size.height;
                             self.viewPlaying.frame = frameViewPlaying;
                         } else {
                             fullScreen = NO;
                             CGRect bounds = CGRectMake(0.0f, 0.0f, portraitFrame.size.width, portraitFrame.size.height);
                             self.viewPlaying.bounds = bounds;
                             self.viewPlaying.frame = portraitFrame;
                             
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         if (fullscreen) {
                             [[UIApplication sharedApplication]setStatusBarHidden:fullscreen];
                         }
                     }];
    
    
}


- (IBAction)btnMore:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
             @"Add to Playlist",
             @"Share",
             nil];
    popup.tag = 1;
    [popup showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                {
//                    SelectPlaylistViewController *select = [[SelectPlaylistViewController alloc]initWithNibName:@"SelectPlaylistViewController" bundle:nil];
//                    
//                    [self presentViewController:select animated:YES completion:^{
//                        [self.modelPlaying addPlaylist:select];
//                    }];
                }
                    break;
                case 1:
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)deviceDidchangeOrientation:(NSNotification *)notify;
{
    
//    UIInterfaceOrientation oldIO = [[UIApplication sharedApplication]statusBarOrientation];
    UIDevice *device = [notify object];
    UIInterfaceOrientation interfaceOrientation = [self interfaceOrientationForDeviceOrientation:device.orientation];
    
    if (interfaceOrientation != UIInterfaceOrientationUnknown) {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            self.viewControlBotton.hidden = YES;
            [self toggleFullscreen:YES orientation:interfaceOrientation];
        }else{
            self.viewControlBotton.hidden = NO;
            [self toggleFullscreen:NO orientation:UIInterfaceOrientationPortrait];
        }
    }
    
}

- (UIInterfaceOrientation)interfaceOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
{
   switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            return UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationLandscapeRight;
            break;
        default:
            return UIInterfaceOrientationUnknown;
            break;
    }
}

-(void)streaming;
{
    NSLog(@"%@",self.btnQuality.titleLabel.text);
    check = false;
    [self animaeGoingUp];
    [self.modelPlaying getLinkStreamming:index];
    
}

#pragma mark - Update UI


- (IBAction)sliderDidChange:(id)sender {
    CGFloat newProgress;

        newProgress = self.sliderProgress.value;

    CGFloat newPercentage = newProgress / (self.sliderProgress.maximumValue - self.sliderProgress.minimumValue);
    
    CGFloat currentTime = newPercentage * CMTimeGetSeconds(self.modelPlaying.playerItem.duration);
    
    [self.modelPlaying.player seekToTime:CMTimeMakeWithSeconds(currentTime, 1.0f)];
    

}
- (IBAction)sliderDidTouchDown:(id)sender {
    sliderProgressEditing = YES;
    [self pauseNow];
    
}

- (IBAction)sliderDidTouchUp:(id)sender {
    sliderProgressEditing = NO;
    [self playContinue];

}

-(void)pauseNow;
{
    [self.modelPlaying pause];
    self.btnPlay.selected = false;
    self.btnPlayPause.selected = false;
    self.PlayPauseVIew.selected = false;
}
-(void)playContinue;
{
    [self.modelPlaying play];
    _btnPlayPause.selected = true;
    _btnPlay.selected = true;
    self.PlayPauseVIew.selected = true;
    self.PlayPauseVIew.enabled = YES;
}

- (void)didPlayTime:(CGFloat)playedTime duration:(CGFloat)totalTime;
{
    CGFloat percentage = playedTime / totalTime;
    savingCureentTime = playedTime;
    
    if (!sliderProgressEditing) {
        _sliderProgress.enabled = YES;
        
        requesting = NO;
        
        //update slider progress
        self.sliderProgress.value = percentage;
        
        [self.progressHidder setProgress:playedTime/totalTime animated:YES];
        
        //Update Time text
        CGFloat playedTime = percentage * CMTimeGetSeconds(self.modelPlaying.playerItem.duration);
        
        self.lblPlayedTime.text = [self.modelPlaying covertStringWithDurationNumber:playedTime];
        
        CGFloat remainingTime = CMTimeGetSeconds(self.modelPlaying.playerItem.duration) - playedTime;
        self.lblRemainingTime.text = [NSString stringWithFormat:@"-%@",[self.modelPlaying covertStringWithDurationNumber:remainingTime]];
    }
    
    if(!self.modelPlaying.playerItem){
        self.sliderProgress.value = 0;
        self.lblRemainingTime.text = @"--:--";
        self.lblPlayedTime.text = @"--:--";
    }

}

-(void)disableQuality;
{
    if (qualityString) {
        [self.btnQuality setTitle:qualityString forState:UIControlStateNormal];
    }else{
        [self.btnQuality setTitle:@"720" forState:UIControlStateNormal];
    }
}

-(void)updateUI:(NSString *)title andSinger:(NSString *)singer andImage:(NSString *)thumbnails;
{
    if ([self.btnQuality.titleLabel.text isEqualToString:@"720"]) {
        self.btn720.selected = YES;
        self.btn360.selected = NO;
        self.btn240.selected = NO;
        self.btnQuality.titleLabel.text = @"720";
    }else if([self.btnQuality.titleLabel.text isEqualToString:@"360"]){
        self.btn720.selected = NO;
        self.btn360.selected = YES;
        self.btn240.selected = NO;
        self.btnQuality.titleLabel.text = @"360";
    }else if([self.btnQuality.titleLabel.text isEqualToString:@"240"]){
        self.btn720.selected = NO;
        self.btn360.selected = NO;
        self.btn240.selected = YES;
        self.btnQuality.titleLabel.text = @"240";
    }
    
    
    self.lbltitle.text = title;
    self.lblUser.text = singer;
    self.lblName.text = title;
    UIImage *defaultImage = [UIImage imageNamed:@"missing_artwork.png"];
    [self.imvSong sd_setImageWithURL:[NSURL URLWithString:thumbnails]
                        placeholderImage:defaultImage
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   if (!error) {
                                       self.modelPlaying.imageAtwork = self.imvSong;
                                       [self.modelPlaying savingCoreData];
                                   }
                                   else {
                                       NSLog(@"error = %@",error);
                                   }
                               }];
}
-(void)resetUI;
{
    self.sliderProgress.value = 0.0f;
    self.btnPlayPause.selected = false;
    
    [self.progressCustom1 setProgress:0 animated:NO];
    [self.progressHidder setProgress:0 animated:NO];
    
    self.lblPlayedTime.text = @"--:--";
    self.lblRemainingTime.text = @"--:--";
    requesting = YES;
}

-(void)disabled;
{
    self.btnPlay.enabled = NO;
    self.btnPlayPause.enabled = NO;
    self.PlayPauseVIew.enabled = NO;
    self.repeat.enabled = NO;
    self.shuff.enabled = NO;
    self.PlayPauseVIew.enabled = NO;
    self.btnDismiss.enabled = NO;
    _sliderProgress.enabled = NO;
}

-(void)enabled;
{
    self.btnPlay.enabled = YES;
    self.btnPlayPause.enabled = YES;
    self.repeat.enabled = YES;
    self.shuff.enabled = YES;
        self.PlayPauseVIew.enabled = YES;
    _sliderProgress.enabled = YES;
    self.PlayPauseVIew.enabled = YES;
    self.btnDismiss.enabled = YES;
}

- (IBAction)dismiss:(id)sender {
    [self animaeGoingDown];
}


- (IBAction)hiddenAndShow:(id)sender {
    if (!self.hiddenAndShow.selected) {
        [self hidden];
    }else{
        [self Nothidden];
    }
}

-(void)hidden;
{
    self.btnDismiss.hidden = YES;
    self.btnQuality.hidden = YES;
    self.viewQuality.hidden = YES;
    self.viewSlider.hidden = YES;
    self.PlayPauseVIew.hidden = YES;
    self.btnDismiss.hidden = YES;
    self.hiddenAndShow.selected = true;
}

-(void)Nothidden;
{
    self.btnDismiss.hidden = NO;
    self.btnQuality.hidden = NO;
    self.viewSlider.hidden = NO;
    self.PlayPauseVIew.hidden = NO;
    self.btnDismiss.hidden = NO;
    self.hiddenAndShow.selected = false;
}

#pragma mark - Quality
- (IBAction)showQuality:(id)sender {
    if (!self.btnQuality.selected) {
        CGRect playFrame = self.viewQuality.frame;
        playFrame.origin.x = self.view.frame.size.width;
        self.viewQuality.frame = playFrame;
        [UIView animateWithDuration:0.2f animations:^{
            self.viewQuality.hidden = NO;
            CGRect playFrame = self.viewQuality.frame;
            playFrame.origin.x = self.view.frame.size.width - self.viewQuality.frame.size.width;
            self.viewQuality.frame = playFrame;
            self.btnQuality.selected = YES;
        }];
    }else{
        self.btnQuality.selected = NO;
        self.viewQuality.hidden = YES;
    }
   
}
- (IBAction)chooseQuality:(id)sender {
    UIButton *test = sender;
    if ([test.titleLabel.text isEqualToString:self.btnQuality.titleLabel.text]) {
        self.viewQuality.hidden = YES;
    }else{
        [self pauseNow];
        if (test == self.btn240) {
            indexQuality = 36;
            [self.modelPlaying getLinkStreamming:indexQuality];
            self.viewQuality.hidden  = YES;
            check = true;
        }
        if (test == self.btn360) {
            indexQuality = 18;
            [self.modelPlaying getLinkStreamming:indexQuality];
            self.viewQuality.hidden  = YES;
            check = true;
        }
        if (test == self.btn720) {
            indexQuality = 22;
            [self.modelPlaying getLinkStreamming:indexQuality];
            self.viewQuality.hidden  = YES;
            check = true;
        }
    }
}
-(void)checkNextorChange;
{
    if (check) {
        self.sliderProgress.value = savingCureentTime;
        CGFloat newPercentage = savingCureentTime / (self.sliderProgress.maximumValue - self.sliderProgress.minimumValue);
        [self.modelPlaying.player seekToTime:CMTimeMakeWithSeconds(newPercentage, 1.0f)];
    }
}

#pragma mark - activity indicator
-(void)startActivityIndicator;
{
    loadview = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if (fullScreen) {
        loadview.center = self.view.center;
    }else{
        loadview.center = self.viewControl.center;
    }

    [loadview startAnimating];
    [self.viewPlaying addSubview:loadview];
}
-(void)stopActivityIndicator;
{
    if ([loadview isAnimating] == true) {
        [loadview stopAnimating];
        [loadview removeFromSuperview];
    }
}

#pragma mark - Custom slider and progress
-(void)initWithMax:(CGFloat )duration andMin:(CGFloat )played andSlider:(UISlider *)slider andProgress:(UIProgressView *)customProgress;
{
    UIImage *thumbImage = [UIImage imageNamed:@"VN"];
    slider.maximumTrackTintColor = [UIColor clearColor];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    customProgress.trackTintColor = [UIColor orangeColor];
    customProgress.progressTintColor = [UIColor grayColor];
    [customProgress setProgress:0 animated:YES];
}

-(void)setTimeProgress:(CGFloat )loadtime;
{
    [self.progressCustom1 setProgress:loadtime animated:YES];
}

-(void)savingCoredata:(NSString *)title andAtwork:(NSData *)imageData andVideoid:(NSString *)videoId andDate:(NSDate *)date andVideoCount:(NSNumber *)viewcount andDuration:(NSNumber *)duration;
{
    [core SavingCoreDataWithtitle:title andData:imageData andVideoID:videoId andDate:[NSDate new] andVideoCount:viewcount andDuration:duration];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    UITouch *aTouch = [touches anyObject];
    CGPoint loc = [aTouch locationInView:self.view];
    
    if (CGRectContainsPoint(self.viewHeader.frame, loc)) {
        [self animaeGoingUp];
    }
    if (CGRectContainsPoint(self.viewControlBotton.frame, loc)) {
        if (fullScreen) {
            if (!self.hiddenAndShow.selected) {
                [self hidden];
                self.hiddenAndShow.selected = YES;
            }else{
                [self Nothidden];
                self.hiddenAndShow.selected = NO;
            }
        }
    }
    
}
- (IBAction)changeValueVolumb:(id)sender {
    [self.modelPlaying changeVolubm:self.sliderVolumb.value];
}

- (BOOL)shouldAutorotate {
    return NO;
}
@end
