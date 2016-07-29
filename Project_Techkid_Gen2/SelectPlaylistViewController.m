//
//  SelectPlaylistViewController.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/5/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "SelectPlaylistViewController.h"
#import "CoreDataManaged.h"
#import "PLaylistTableViewCell.h"
#import "PlaylistsViewController.h"
#import "DetailTop100ViewController.h"
#import "UIImageView+WebCache.h"
#import "HistoryViewController.h"
#import "TrackPlaylist.h"

@interface SelectPlaylistViewController ()
{
    CoreDataManaged *core;
}

@property(nonatomic,strong) NSMutableArray *playlists;

@end

@implementation SelectPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tbvSelect.delegate = self;
    _tbvSelect.dataSource = self;
    core = Instance;
    
    [self reloadPlaylist:YES];
    
}


-(void)reloadPlaylist:(BOOL)willReloadTable;
{
    _playlists = [core ReadingWithPlaylistCoreData];
    if (willReloadTable) {
        [_tbvSelect reloadData];
    }
    
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
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:cellId owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        [cell displayBtnNewPlaylist];
        
        return cell;
    } else {
        static NSString *cellId = @"PLaylistTableViewCell";
        PlaylistsViewController *playlist = [_playlists objectAtIndex:indexPath.row];
        PLaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PLaylistTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        int count = 0;
        NSMutableArray *array = [core ReadingWithPlaylistTracksCoreData];
        for (TrackPlaylist *newtrack in array) {
            if ([newtrack.dbTrackId isEqualToString:playlist.title]) {
                count++;
                if (count == 1) {
                    cell.imageView.image = [UIImage imageWithData:newtrack.image];
                }
            }
        }
        cell.lblcount.text = [NSString stringWithFormat:@"%d videos",count];
        if(cell.imageView.image == nil){
            cell.imageView.image = [UIImage imageNamed:@"AppIcon60x60"];
        }
        cell.lblName.text = playlist.title;
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    else {
        return 55;
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
        
        PlaylistsViewController *playlist = [_playlists objectAtIndex:indexPath.row];
        [core SavingCoreDataWithPlaylistTracks:_Name andImage:_imageData andTrackid:playlist.title andVideoid:_videoid];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
        {
            NSString *newItem = [[alertView textFieldAtIndex:0]text];
            [core SavingCoreDataWithPLaylist:newItem andImage:@"" andIndex:(_playlists.count + 1) andDate: [NSDate date]];
            [self reloadPlaylist:YES];
        }
            break;
        default:
            break;
    }
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
