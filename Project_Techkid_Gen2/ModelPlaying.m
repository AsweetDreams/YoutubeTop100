//
//  ModelPlaying.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/8/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "ModelPlaying.h"
#import "Video.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "SelectPlaylistViewController.h"
#import "Track.h"


@implementation ModelPlaying
{
    id timeObserver;
    CGFloat percentage;
    CGFloat percentageBuffering;
    AppDelegate *ad;

}
static const NSString *ItemStatusContext;

+(instancetype)ShareInstance;
{
    static ModelPlaying *ShareInstance;
    static dispatch_once_t once_t;
    
    dispatch_once(&once_t, ^{
        ShareInstance = [[ModelPlaying alloc]init];
        
    });
    return ShareInstance;
}

-(void)setVideoID:(NSString *)videoId andCurrentPlay:(NSInteger )currentIndex andAllVideo:(NSMutableArray *)allVideo;
{
    self.streamurl = videoId;
    self.currentPlay = currentIndex;
    self.allVideo = allVideo;
}


-(void)changeVideo:(NSInteger )state andQualiy:(NSInteger )indexQuality{
    
    if (self.allVideo.count != 0) {
        [self.delegate resetUI];
        NSInteger count = [self.allVideo count];
        NSInteger Rewindcurrent = (self.currentPlay + state) % count;
        [self.delegate disableQuality];
        _currentPlay = Rewindcurrent;
        Video *newVideo = [self.allVideo objectAtIndex:_currentPlay];
        [self.delegate updateUI:newVideo.videoName andSinger:newVideo.channel andImage:newVideo.thumbnails];
        _streamurl = newVideo.videoId;
        [self getLinkStreamming:indexQuality];
    }
}


-(void)loadfromURLandQuality:(NSInteger )qualityIndex;
{
        NSString *url = [NSString stringWithFormat:@"%@",[self.LinkStreamming valueForKey:[NSString stringWithFormat:@"%ld",qualityIndex]]];
        if ([url isEqualToString:@"(null)"]) {
            url = [NSString stringWithFormat:@"%@",[self.LinkStreamming valueForKey:[NSString stringWithFormat:@"18"]]];
            if ([url isEqualToString:@"(null)"]) {
                url = [NSString stringWithFormat:@"%@",[self.LinkStreamming valueForKey:[NSString stringWithFormat:@"36"]]];
            }
        }
        NSURL *fileURL = [NSURL URLWithString:url];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
                       AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
                       NSString *tracksKey = @"tracks";
                       if (self.LinkStreamming.count != 0) {
                       [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
                        ^{
                            // The completion block goes here.
                            
                            // Completion handler block.
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               NSError *error;
                                               AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                                               
                                               if (status == AVKeyValueStatusLoaded) {
                                                   if (self.playerItem != nil && self.player != nil) {
                                                       [self.playerItem removeObserver:self forKeyPath:@"status"];
                                                       self.playerItem = nil;
                                                       [self.delegate resetUI];
                                                   }

                                                   self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                                                   
                                                   // ensure that this is done before the playerItem is associated with the player
                                                   
                                                   [self.playerItem addObserver:self forKeyPath:@"status"
                                                                        options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                                                   
                                                   [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                            selector:@selector(playerItemDidReachEnd:)
                                                                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                                                                              object:self.playerItem];
                                                   
                                                   self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                                                   [self.player setVolume:1.0];
                                                   [self.playerView setPlayer:self.player];
                                                    [self.delegate checkNextorChange];
                                                   // Update UI
                                                   __weak ModelPlaying *weakself = self;
                                                   
                                                   timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0f, 1.0f) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                                                       CGFloat currentTime = CMTimeGetSeconds(time);
                                                       if (weakself.playerItem) {
                                                           percentage = currentTime /CMTimeGetSeconds(self.playerItem.duration);
                                                           [weakself.delegate didPlayTime:currentTime duration:CMTimeGetSeconds(weakself.playerItem.duration)];
                                                           CGFloat A = [weakself availableDuration]/CMTimeGetSeconds(weakself.playerItem.duration);
                                                           [weakself.delegate setTimeProgress:A];
                                                       }
                                                   }];
                                                   [self.delegate playContinue];
                                               }
                                               else {
                                                   // You should deal with the error appropriately.
                                                   NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                                               }
                                           });
                        }];
                       }
                   });
       }

- (void)syncUI {
    if ((self.player.currentItem != nil) &&
        ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        [self.delegate enabled];
        [self.delegate stopActivityIndicator];
    }
    else {
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (context == &ItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}

- (void)play{
    [self.player play];
    
}

- (void)pause {
    [self.player pause];
}

#pragma mark - Repeat and Shuffle
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.delegate resetUI];
    [self.player seekToTime:kCMTimeZero];
    [self.delegate checkplayerItemDidReachEnd];
}

#pragma mark - Add to Playlist
-(void)addPlaylist:(SelectPlaylistViewController *)select;
{
        Video *video = [_allVideo objectAtIndex:_currentPlay];
         select.videoid = video.videoId;
         select.Name = video.videoName;
        NSData *imageData = UIImagePNGRepresentation(self.imageAtwork.image);
        select.imageData = imageData;
}

#pragma mark - Saving CoreData
-(void)savingCoreData;
{
    Video *newvideo = [self.allVideo objectAtIndex:_currentPlay];
    if(self.imageAtwork != nil){
        NSData *imageData = UIImagePNGRepresentation(self.imageAtwork.image);
        [self.delegate savingCoredata:newvideo.videoName andAtwork:imageData andVideoid:newvideo.videoId andDate:[NSDate new] andVideoCount:newvideo.viewCount andDuration:newvideo.duration];
    }
}

#pragma mark - Get Link streamming
-(void)getLinkStreamming:(NSInteger )indexQuality;
{
    [self.delegate stopActivityIndicator];
    [self pause];
    [self.delegate resetUI];
    [self.delegate disabled];
    Video *newVideo = [self.allVideo objectAtIndex:_currentPlay];
    [self.delegate updateUI:newVideo.videoName andSinger:newVideo.channel andImage:newVideo.thumbnails];
    [self.delegate startActivityIndicator];
    [sYoutubeAPI getLinkStreammingWithVideoid:self.streamurl completion:^(NSMutableDictionary *link) {
            self.LinkStreamming = link;
        [self loadfromURLandQuality:indexQuality];
        }];
}


-(NSString *)covertStringWithDurationNumber: (NSInteger)number;{
    
    NSInteger time = number;
    NSString *timeString = @"";
    NSInteger hours = time / 3600;
    NSInteger minutes = (time - hours * 3600) / 60;
    NSInteger seconds = time % 60;
    
    
    if (hours > 0) {
        timeString = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        timeString = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    }
    return timeString;
}
- (CGFloat) availableDuration;
{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
    Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
    CGFloat result = startSeconds + durationSeconds;
    return result;
}

-(void)changeVolubm:(CGFloat )value;
{
    if (self.player != nil && self.playerItem!= nil) {
        self.player.volume = value;
    }
}

@end
