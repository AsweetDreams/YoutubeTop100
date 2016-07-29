//
//  VideoViewController.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/1/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "VideoViewController.h"
#import "Video.h"
#import "UIImageView+WebCache.h"
#import "ModelPlaying.h"
#import "AppDelegate.h"
#import "CoreDataManaged.h"
#import "SWRevealViewController/SWRevealViewController.h"
#import "YoutubeAPI.h"
#import "ItemCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "DisconnectCell.h"


@import GoogleMobileAds;
@interface VideoViewController ()
{
    AppDelegate *ad;
    ModelPlaying *play;
    UIActionSheet *popup;
    NSString *videoId;
    UIImage *imageAtwork;
}

@property(nonatomic,strong)  NSMutableArray *ListVideowithTitle;
@property (nonatomic,strong) NSMutableArray *tmpVideos;
@property (nonatomic,strong) NSString *token;
@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.token = @"";
    _tbvVideo.delegate = self;
    _tbvVideo.dataSource = self;
    _ListVideowithTitle = [[NSMutableArray alloc]init];
    ad = [[UIApplication sharedApplication] delegate];
    play = InstanceModel;
    
    //ad
    self.interstitial = [self createAndLoadInterstitial];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(actionSheet:)
                                                name:@"btnMore"
                                              object:nil];
    if(ad.internetActive){
        __weak VideoViewController *weakSelf = self;
        
        // setup pull-to-refresh
        //    [self.tbvVideo addPullToRefreshWithActionHandler:^{
        //        [weakSelf insertRowAtTop];
        //    }];
        
        // setup infinite scrolling
        [self.tbvVideo addInfiniteScrollingWithActionHandler:^{
            [weakSelf loadNextResult];
        }];
        
        
        if(self.keyword){
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [self.tbvVideo setHidden:YES];
                [sYoutubeAPI exploreVideosWithKeyword:sYoutubeAPI.youTubeService keyWord:self.keyword withPageToken:self.token completionBlock:^(NSArray *videos,NSString *token){
                    self.token = token;
                    for(int i= 0;i< videos.count; i++){
                        
                        Video *newVideo = [[Video alloc] initWithJsonDict:videos[i]];
                        if (!_ListVideowithTitle){
                            _ListVideowithTitle = [[NSMutableArray alloc] initWithObjects:newVideo, nil];
                        }else{
                            [_ListVideowithTitle addObject:newVideo];
                        }
                    }
                    NSLog(@"%@",_ListVideowithTitle);
                    [self.tbvVideo setHidden:NO];
                    [_tbvVideo reloadData];
                }];
            });
        }else{
            // youtube video
            NSArray *data = [[NSArray alloc] initWithArray:[sYoutubeAPI readYoutubeDataWithRegion:sYoutubeAPI.currRegion]];
            for(int i= 0;i< data.count; i++){
                
                Video *newVideo = [[Video alloc] initWithJsonDict:data[i]];
                if (!_ListVideowithTitle){
                    _ListVideowithTitle = [[NSMutableArray alloc] initWithObjects:newVideo, nil];
                }else{
                    [_ListVideowithTitle addObject:newVideo];
                }
            }
            [_tbvVideo reloadData];
        }
    }
}

- (void)presentAds {
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}

-(void)adViewWillPresentScreen:(GADBannerView *)bannerView{
    
}

-(void)loadNextResult{
    if(ad.internetActive){
        if(self.keyword){
            [sYoutubeAPI exploreVideosWithKeyword:sYoutubeAPI.youTubeService keyWord:self.keyword withPageToken:self.token completionBlock:^(NSArray *videos,NSString *token){
                self.token = token;
                for(int i= 0;i< videos.count; i++){
                    
                    Video *newVideo = [[Video alloc] initWithJsonDict:videos[i]];
                    if (!_ListVideowithTitle){
                        _ListVideowithTitle = [[NSMutableArray alloc] initWithObjects:newVideo, nil];
                    }else{
                        [_ListVideowithTitle addObject:newVideo];
                    }
                }
                [_tbvVideo reloadData];
            }];
        }
        [self.tbvVideo.infiniteScrollingView stopAnimating];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}


#pragma mark - tableview datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(ad.internetActive){
        return self.ListVideowithTitle.count;
    }else{
        return 1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(ad.internetActive){
        static NSString *cellId = @"itemCell";
        ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:cellId];
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        }
        Video *videoInRow = [self.ListVideowithTitle objectAtIndex:indexPath.row];
        if(self.keyword){
            cell.videoNameLbl.text = videoInRow.videoName;
        }else{
            cell.videoNameLbl.text = [[NSString stringWithFormat:@"%lu. ",indexPath.row + 1] stringByAppendingString:videoInRow.videoName];
        }
        cell.channelLbl.text = videoInRow.channel;
        cell.viewLbl.text = [videoInRow covertStringWithViewNumber:[videoInRow.viewCount integerValue]];
        cell.durationLbl.text = [videoInRow covertStringWithDurationNumber:[videoInRow.duration integerValue]];
        cell.videoid = videoInRow.videoId;
        
        UIImage *defaultImage = [UIImage imageNamed:@"missing_artwork.png"];
        [cell.itemImg sd_setImageWithURL:[NSURL URLWithString:videoInRow.thumbnails]
                        placeholderImage:defaultImage
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   imageAtwork = cell.itemImg.image;
                                   if (error) {
                                       NSLog(@"error = %@",error);
                                   }
                               }];
        return cell;
    }else{
        static NSString *cellId = @"DisconnectCell";
        DisconnectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"DisconnectCell" bundle:nil] forCellReuseIdentifier:cellId];
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        }
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(ad.internetActive){
        return 70.0f;
    }else{
        return 500.0f;
    }
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
    int i = arc4random_uniform(10);
    if(!i%3){
        [self presentAds];
    }else{
        self.view.backgroundColor = [UIColor whiteColor];
        Video *newvideo = [_ListVideowithTitle objectAtIndex:indexPath.row];
        [play setVideoID:newvideo.videoId andCurrentPlay:indexPath.row andAllVideo:_ListVideowithTitle];
        [ad.playing streaming];
    }
}
-(void)actionSheet:(NSNotification *)notif;
{
    id object = [notif object];
    
    
    popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
             @"Add to Playlist",
             @"Share",
             nil];
    popup.tag = 1;
    [popup showInView:self.view];
    
    self.titleVideo = object;
    NSLog(@"name = %@",videoId);
    [popup showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self addPlaylist];
                    break;
                case 1:
                    [self shareObject];
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

-(void)addPlaylist
{
    SelectPlaylistViewController *select = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectPlaylistViewController"];
    [self presentViewController:select animated:YES completion:^{
    }];
    
    NSInteger index = [self Info];
    if (index >= 0) {
        Video *newvideo = [self.ListVideowithTitle objectAtIndex:index];
        UIImage *defaultImage = [UIImage imageNamed:@"missing_artwork.png"];
        UIImageView *image = [[UIImageView alloc]initWithImage:defaultImage];
        NSLog(@"%@",newvideo.thumbnails);
        NSData* pictureData;
        if (imageAtwork == nil) {
            pictureData = UIImagePNGRepresentation(image.image);
        }else{
            pictureData = UIImagePNGRepresentation(imageAtwork);
        }
        
        select.Name = newvideo.videoName;
        select.imageData = pictureData;
        select.videoid = newvideo.videoId;
    }
}

- (void)shareObject;
{
    NSInteger index = [self Info];
    Video *newVideo = [_ListVideowithTitle objectAtIndex:index];
    NSString *textToShare = @"your text";
    NSString *stringURL = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",newVideo.videoId];
    NSURL *url = [NSURL URLWithString:stringURL];
    NSArray *itemsToShare = @[url,textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    [self presentViewController:activityVC animated:YES completion:nil];
    
}


-(NSInteger )Info;
{
    for (int i = 0;i<self.ListVideowithTitle.count;i++) {
        Video *newvideo = [self.ListVideowithTitle objectAtIndex:i];
        NSString *name = [NSString stringWithFormat:@"%d. %@",i+1,newvideo.videoName];
        NSLog(@"%@",name);
        if ([name isEqualToString:self.titleVideo]) {
            return i;
        }
    }
    return -1;
}
@end
