//
//  ModelPlaying.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/8/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "XCDYouTubeKit/XCDYouTubeKit.h"
#import "CoreDataManaged.h"
#import "SelectPlaylistViewController.h"
#import "AppDelegate.h"
#import "YoutubeAPI.h"
#import <AVFoundation/AVFoundation.h>
#import "ContainerView.h"
#import "PlayingViewController.h"

#define InstanceModel [ModelPlaying ShareInstance]

@protocol ModelPlayingDelegate

- (void)didPlayTime:(CGFloat)playedTime duration:(CGFloat)totalTime;
-(void)playContinue;
-(void)resetUI;
-(void)pauseNow;
-(void)checkplayerItemDidReachEnd;
-(void)checkNextorChange;
-(void)stopActivityIndicator;
-(void)startActivityIndicator;
-(void)setTimeProgress:(CGFloat )loadtime;
-(void)savingCoredata:(NSString *)title andAtwork:(NSData *)imageData andVideoid:(NSString *)videoId andDate:(NSDate *)date andVideoCount:(NSNumber *)viewcount andDuration:(NSNumber *)duration;
-(void)updateUI:(NSString *)title andSinger:(NSString *)singer andImage:(NSString *)thumbnails;
-(void)disableQuality;

@end


@interface ModelPlaying : NSObject

@property (assign) id delegate;

@property(nonatomic) AVPlayer *player;
@property(nonatomic) AVPlayerItem *playerItem;
@property (nonatomic, weak) ContainerView *playerView;

@property (nonatomic,strong) NSMutableDictionary *LinkStreamming;

@property (nonatomic,strong) UIImageView *imageAtwork;
@property(nonatomic,strong) NSString *streamurl;
@property(nonatomic,assign) NSInteger currentPlay;
@property(nonatomic,strong) NSMutableArray *allVideo;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *singger;


+(instancetype)ShareInstance;

-(void)savingCoreData;
-(void)setVideoID:(NSString *)videoId andCurrentPlay:(NSInteger )currentIndex andAllVideo:(NSMutableArray *)allVideo;
-(void)changeVideo:(NSInteger )state andQualiy:(NSInteger )indexQuality;
-(void)play;
-(void)pause;
-(void)addPlaylist:(SelectPlaylistViewController *)select;
-(void)loadfromURLandQuality:(NSInteger )qualityIndex;
-(void)getLinkStreamming:(NSInteger )indexQuality;
-(NSString *)covertStringWithDurationNumber: (NSInteger)number;
-(void)changeVolubm:(CGFloat )value;
@end
