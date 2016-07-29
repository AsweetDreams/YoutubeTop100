//
//  PlaylistDetailViewController.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/5/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "PlaylistDetailViewController.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "CoreDataManaged.h"
#import "TrackPlaylist.h"
#import "PLaylistTableViewCell.h"
#import "ModelPlaying.h"
#import "Video.h"

@interface PlaylistDetailViewController ()
{
    AppDelegate *ad;
    CoreDataManaged *core;
    ModelPlaying *modelPlay;
}
@property(nonatomic,strong) NSMutableArray *track;

@end

@implementation PlaylistDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tbvDetail.tableFooterView = [[UITableView alloc]init];
    self.title = _selected.title;
    _tbvDetail.delegate = self;
    _tbvDetail.dataSource = self;
    _track = [[NSMutableArray alloc]init];
    ad = [[UIApplication sharedApplication]delegate];
    core = Instance;
    modelPlay = InstanceModel;
    
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    
    [self reloadtrack:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadtrack:(BOOL)willreloadTableview;
{
    NSMutableArray *array = [core ReadingWithPlaylistTracksCoreData];
    for (TrackPlaylist *newtrack in array) {
        if ([newtrack.dbTrackId isEqualToString:_selected.title]) {
            [_track addObject:newtrack];
        }
    }
    [_tbvDetail reloadData];
}

-(void)present;
{
    [self presentViewController:ad.playing animated:YES completion:^{
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Will Appear");
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


#pragma mark - tabledatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _track.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellId = @"PLaylistTableViewCell";
    TrackPlaylist *playlist = [_track objectAtIndex:indexPath.row];
    PLaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PLaylistTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.imgPlaylist.image = [UIImage imageWithData:playlist.image];
    cell.lblName.text = playlist.title;
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 65.0f;
}

-(NSMutableArray *)covertVideo;
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (TrackPlaylist *newplaylist in _track) {
        Video *newvideo = [[Video alloc]init];
        newvideo.videoName = newplaylist.title;
        newvideo.videoId = newplaylist.videoid;
        newvideo.image = newplaylist.image;
        [array addObject:newvideo];
    }
    return array;
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *newPlaylistArray = [self covertVideo];
    Video *newvideo = [newPlaylistArray objectAtIndex:indexPath.row];
    
    [modelPlay setVideoID:newvideo.videoId andCurrentPlay:indexPath.row andAllVideo:newPlaylistArray];
    [ad.playing streaming];
}

#pragma mark - Editing
///editing state
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.tbvDetail setEditing:editing animated:animated];
    
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
    [_track removeObjectAtIndex:indexPath.row];
    [self.tbvDetail deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [core DeleteCoreDataWithPlaylist:indexPath.row];
    
}

@end
