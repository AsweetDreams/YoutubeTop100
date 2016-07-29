//
//  HistoryViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "HistoryViewController.h"
#import "SWRevealViewController.h"
#import "CoreDataManaged.h"
#import "Track.h"
#import "AppDelegate.h"
#import "Video.h"
#import "SelectPlaylistViewController.h"
#import "ModelPlaying.h"
#import "Video.h"
#import "ItemCell.h"

@interface HistoryViewController ()

{
    CoreDataManaged *core;
    AppDelegate *ad;
    UIActionSheet *popup;
    NSString *name;
    ModelPlaying *modelPlay;
    Video *newvideo;
}

@property (nonatomic,strong) NSMutableArray *history;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    core = Instance;
    ad = [[UIApplication sharedApplication]delegate];
    _history = [core ReadingCoreData];
    [_historyTbv registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:@"itemCell"];
    
    //    UIBarButtonItem *barItem  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"musical"] style:UIBarButtonItemStylePlain target:self action:@selector(present)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(actionSheet:)
                                                name:@"btnMore"
                                              object:nil];
    modelPlay = InstanceModel;
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if ( revealViewController )
    {
        [self.sidebarBtn setTarget: self.revealViewController];
        [self.sidebarBtn setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma table data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _history.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"itemCell";
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    newvideo = [[Video alloc]init];
    
    Track *newTrack = [self.history objectAtIndex:indexPath.row];
    
    cell.videoNameLbl.text = newTrack.title;
    cell.itemImg.image = [UIImage imageWithData:newTrack.atwork];
    NSString *viewcount = [newvideo covertStringWithViewNumber:[newTrack.viewcount integerValue]];
    cell.viewLbl.text = viewcount;
    NSString *duration = [newvideo covertStringWithDurationNumber:[newTrack.duration integerValue]];
    cell.durationLbl.text = duration;
    return cell;
}

-(NSMutableArray *)covertToVideo;
{
    NSMutableArray *videoHistory = [[NSMutableArray alloc]init];
    for (Track *newTrack in _history) {
        Video *newvideo2 = [[Video alloc]init];
        newvideo2.videoName = newTrack.title;
        newvideo2.videoId = newTrack.videoid;
        newvideo2.thumbnails = @"";
        newvideo2.image = newTrack.atwork;
        [videoHistory addObject:newvideo2];
    }
    return videoHistory;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *Array = [self covertToVideo];
    Video *newvideo = [Array objectAtIndex:indexPath.row];
    
    [modelPlay setVideoID:newvideo.videoId andCurrentPlay:indexPath.row andAllVideo:Array];
    [ad.playing streaming];
    
}

-(void)actionSheet:(NSNotification *)notif;
{
    id object = [notif object];
    
    
    popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
             @"Remove Link From History",
             @"Add to Playlist",
             @"Share",
             nil];
    popup.tag = 1;
    [popup showInView:self.view];
    
    name = object;
    
}


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self Remove];
                    break;
                case 1:
                    [self addPlaylist];
                    break;
                case 2:
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
        Track *newtrack = [_history objectAtIndex:index];
        select.Name = newtrack.title;
        select.imageData = newtrack.atwork;
        select.videoid = newtrack.videoid;
    }
}

- (void)shareObject;
{
    NSInteger index = [self Info];
    Track *newtrack = [_history objectAtIndex:index];
    NSString *textToShare = @"your text";
    UIImage *imageToShare = [UIImage imageNamed:@"Icon1"];
    NSString *stringURL = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",newtrack.videoid];
    NSURL *url = [NSURL URLWithString:stringURL];
    NSArray *itemsToShare = @[url,textToShare, imageToShare];
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
    for (int i = 0;i<_history.count;i++) {
        Track *newvideo = [_history objectAtIndex:i];
        if ([newvideo.title isEqualToString:name]) {
            return i;
        }
    }
    return -1;
}
-(void)Remove;
{
    NSInteger index = [self Info];
    if (index >= 0) {
        [self.history removeObjectAtIndex:index];
        [core DeleteCoreDataWithTrack:index];
        [_historyTbv reloadData];
    }else{
        return;
    }
    
}

///editing state
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.historyTbv setEditing:editing animated:animated];
}

//editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        return NO;
    }
    return YES;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self.history removeObjectAtIndex:indexPath.row];
    [self.historyTbv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [core DeleteCoreDataWithTrack:indexPath.row];
    
}
@end
