//
//  PlaylistsViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/29/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "PlaylistsViewController.h"
#import "SWRevealViewController.h"
#import "PLaylistTableViewCell.h"
#import "CoreDataManaged.h"
#import "AppDelegate.h"
#import "PlaylistDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface PlaylistsViewController ()
{
    NSString *name;
    NSInteger count;
    NSString *thumnais;
    CoreDataManaged *core;
    AppDelegate *ad;
}
@property(nonatomic,strong) NSMutableArray *playlists;
@property(nonatomic,strong) NSMutableArray *allVideoPlaylist;

@end

@implementation PlaylistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    core = Instance;
    ad = [[UIApplication sharedApplication]delegate];
    
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    
    self.allVideoPlaylist = [[NSMutableArray alloc]init];
    
    _tbvPlaylist.delegate = self;
    _tbvPlaylist.dataSource = self;
    
    _tbvPlaylist.tableFooterView = [[UITableView alloc]init];
    // Do any additional setup after loading the view.
    
    [self reloadPlaylist:YES];
    
}


-(void)reloadPlaylist:(BOOL)willReloadTable;
{
    _playlists = [core ReadingWithPlaylistCoreData];
    if (willReloadTable) {
        [_tbvPlaylist reloadData];
    }
    
}

-(void)present;
{
    [self presentViewController:ad.playing animated:YES completion:^{
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else {
        return _playlists.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        static NSString *cellId = @"PLaylistTableViewCell";
        
        PLaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PLaylistTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        [cell displayBtnNewPlaylist];
        
        return cell;
    } else {
        count = 0;
        static NSString *cellId = @"PLaylistTableViewCell";
        PlaylistsViewController *playlist = [_playlists objectAtIndex:indexPath.row];
        PLaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PLaylistTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSMutableArray *array = [core ReadingWithPlaylistTracksCoreData];
        for (TrackPlaylist *newtrack in array) {
            if ([newtrack.dbTrackId isEqualToString:playlist.title]) {
                count++;
                if (count == 1) {
                    cell.imgPlaylist.image = [UIImage imageWithData:newtrack.image];
                }
            }
        }
        if (cell.imgPlaylist.image == nil) {
            cell.imgPlaylist.image = [UIImage imageNamed:@"BH.png"];
        }
        cell.lblName.text = playlist.title;
        cell.lblcount.text = [NSString stringWithFormat:@"%ld videos",count];
        
        return cell;
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        return 60.0f;
    }else{
        return 70.0f;
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"New Playlist"
                                                       message:@"Enter a name for this playlist"
                                                      delegate:self
                                             cancelButtonTitle:@"cancel"
                                             otherButtonTitles:@"Save", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        
    } else {
        PlaylistDetailViewController *detailPlaylist = [self.storyboard instantiateViewControllerWithIdentifier:@"PlaylistDetailViewController"];
        [self.navigationController pushViewController:detailPlaylist animated:YES];
        detailPlaylist.selected = [_playlists objectAtIndex:indexPath.row];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 0:
            break;
        default:
        {
            NSString *newItem = [[alertView textFieldAtIndex:0]text];
            [core SavingCoreDataWithPLaylist:newItem andImage:@"" andIndex:(_playlists.count + 1) andDate: [NSDate date]];
            [self reloadPlaylist:YES];
        }
            break;
    }
}

#pragma mark - Editing
///editing state
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.tbvPlaylist setEditing:editing animated:animated];
    
    
}

//editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing || indexPath.section == 0) {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [_playlists removeObjectAtIndex:indexPath.row];
    [self.tbvPlaylist deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [core DeleteCoreDataWithPlaylist:indexPath.row];
    
}
@end
