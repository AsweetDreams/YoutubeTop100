//
//  PlayingViewController.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/1/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelPlaying.h"
#import "ContainerView.h"
#import "MarqueeLabel.h"
@class ModelPlaying;
@interface PlayingViewController : UIViewController<UIActionSheetDelegate>

typedef enum {
    
    PLAYER_STATE_HIDDEN = 0,
    PLAYER_STATE_FULLSCREEN = 1,
    PLAYER_STATE_HEADER,
    
} PLAYER_STATE;

@property (strong, nonatomic) IBOutlet UISlider *sliderVolumb;
@property(nonatomic, assign) NSInteger playerState;
@property (strong, nonatomic) IBOutlet UIButton *Frame;
 @property (weak, nonatomic) IBOutlet MarqueeLabel *lbltitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUser;
@property (strong, nonatomic) IBOutlet UIImageView *imvSong;
@property (strong, nonatomic) IBOutlet MarqueeLabel *lblName;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) IBOutlet UIView *viewSlider;

@property (strong, nonatomic) IBOutlet UIView *viewControl;
@property (strong, nonatomic) IBOutlet UIView *viewControlBotton;
@property (strong, nonatomic) IBOutlet UIView *viewGesture;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIView *viewPlaying;

@property(nonatomic,strong) ModelPlaying *modelPlaying;
@property (strong, nonatomic) IBOutlet ContainerView *videoContainerView;

-(void)playContinue;
-(void)streaming;
-(void)pauseNow;
-(void)resetUI;
-(void)checkplayerItemDidReachEnd;
-(void)checkNextorChange;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)setTimeProgress:(CGFloat )loadtime;
-(void)savingCoredata:(NSString *)title andAtwork:(NSData *)imageData andVideoid:(NSString *)videoId andDate:(NSDate *)date andVideoCount:(NSNumber *)viewcount andDuration:(NSNumber *)duration;
-(void)disabled;
-(void)enabled;
-(void)updateUI:(NSString *)title andSinger:(NSString *)singer andImage:(NSString *)thumbnails;
-(void)disableQuality;

@property (strong, nonatomic) IBOutlet UIProgressView *progressCustom1;
@property (strong, nonatomic) IBOutlet UISlider *sliderProgress;
@property (strong, nonatomic) IBOutlet UIProgressView *progressHidder;

@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (strong, nonatomic) IBOutlet UIButton *shuff;
@property (strong, nonatomic) IBOutlet UIButton *repeat;
@property (strong, nonatomic) IBOutlet UILabel *lblPlayedTime;
@property (strong, nonatomic) IBOutlet UILabel *lblRemainingTime;

@property (strong, nonatomic) IBOutlet UIButton *hiddenAndShow;
@property (strong, nonatomic) IBOutlet UIButton *btnFullScreen;
@property (strong, nonatomic) IBOutlet UIButton *btnDismiss;
@property (strong, nonatomic) IBOutlet UIButton *PlayPauseVIew;

@property (strong, nonatomic) IBOutlet UIButton *btnQuality;
@property (strong, nonatomic) IBOutlet UIView *viewQuality;
@property (strong, nonatomic) IBOutlet UIButton *btn720;
@property (strong, nonatomic) IBOutlet UIButton *btn360;
@property (strong, nonatomic) IBOutlet UIButton *btn240;

- (IBAction)btnMore:(id)sender;
-(void)animaeGoingUp;
-(void)animaeGoingDown;

@end
