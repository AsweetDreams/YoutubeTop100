//
//  DetailTop100ViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/30/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "DetailTop100ViewController.h"
#import "ItemCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "ListCell.h"
#import "Constant.h"
#import "Song.h"
#import "Album.h"
#import "SWRevealViewController.h"
#import "UIImageView+WebCache.h"
#import "YoutubeAPI.h"
#import "AppDelegate.h"
#import "AlbumViewController.h"
#import "DisconnectCell.h"


@interface DetailTop100ViewController ()
{
    AppDelegate *ad;
}
@property (nonatomic,strong) NSMutableArray *songs;
@property (nonatomic,strong) NSMutableArray *albums;
@property (nonatomic,strong) NSMutableArray *genreList;
@property (nonatomic,strong) VideoViewController *ListVideo;
@property (nonatomic,assign) int countTap;

@end

@implementation DetailTop100ViewController
@synthesize smcControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ad = [[UIApplication sharedApplication]delegate];
    _ListVideo = [[VideoViewController alloc]init];
    _countTap = 0;
    
    self.songs = [[NSMutableArray alloc] init];
    self.albums = [[NSMutableArray alloc] init];
    
    NSString *pListCategoryVideo = [[NSBundle mainBundle] pathForResource:@"categoryVideos" ofType:@"plist"];
    NSDictionary *categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:pListCategoryVideo];
    for (NSDictionary *genre in categoryDictionary[@"categoryVideo"]) {
        if(self.genreList){
            [self.genreList addObject:genre[@"GenreId"]];
            
            
        }else{
            self.genreList = [[NSMutableArray alloc] initWithObjects:genre[@"GenreId"], nil];
        }
    }
    if(ad.internetActive){
        [self.tbvList100 setHidden:YES];
        [self.aivLoading startAnimating];
        [sYoutubeAPI exploreBlockWithGenne:[_genreList objectAtIndex:_genreIndex] andTrack:^(NSArray *tracks) {
            
            NSMutableArray *jsonArray = [NSMutableArray arrayWithArray:tracks];
            for (NSDictionary *jsonDict in jsonArray) {
                Song *newSong = [[Song alloc]initWithJsonDict:jsonDict];
                [_songs addObject:newSong];
            }
            [self.aivLoading stopAnimating];
            [self.tbvList100 setHidden:NO];
            [_tbvList100 reloadData];
        }];
    }
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

-(void)viewDidAppear:(BOOL)animated;
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma segment control


- (IBAction)selectType:(UISegmentedControl *)sender {
    if(ad.internetActive){
        if(self.smcControl.selectedSegmentIndex == 0){
            [_tbvList100 reloadData];
        }else{
            if(_countTap == 0){
                _countTap++;
                [self.tbvList100 setHidden:YES];
                [self.aivLoading startAnimating];
                [sYoutubeAPI exploreListAlbumWithGenne:[_genreList objectAtIndex:_genreIndex] withCompletionBlock:^(NSArray *array) {
                    NSMutableArray *jsonArray = [NSMutableArray arrayWithArray:array];
                    for (NSDictionary *jsonDict in jsonArray) {
                        Album *newAlbum = [[Album alloc]initWithJsonDict:jsonDict];
                        [_albums addObject:newAlbum];
                    }
                    [self.aivLoading stopAnimating];
                    [self.tbvList100 setHidden:NO];
                    [_tbvList100 reloadData];
                }];
            }else{
                [_tbvList100 reloadData];
            }
        }
    }
}


#pragma table data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(ad.internetActive){
        return 70.0f;
    }else{
        return 500.0f;
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(ad.internetActive){
        if(smcControl.selectedSegmentIndex == 0){
            return self.songs.count;
        }else{
            return self.albums.count;
        }
    }else{
        return 1;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //static NSString *cellId = [self.songs objectAtIndex:indexPath.row];
    if(ad.internetActive){
        static NSString *cellId = @"listCell";
        ListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"ListCell" bundle:nil] forCellReuseIdentifier:cellId];
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        }
        if(smcControl.selectedSegmentIndex == 0){
            Song *songInRow = [self.songs objectAtIndex:indexPath.row];
            cell.lblName.text = [[NSString stringWithFormat:@"%lu. ",indexPath.row + 1] stringByAppendingString:songInRow.songName];
            cell.lblSinger.text = songInRow.singerName;
            cell.lblAlbum.text = songInRow.albumName;
            
            _ListVideo.titleVideo = cell.lblName.text;
            UIImage *defaultImage = [UIImage imageNamed:@"missing_artwork.png"];
            [cell.imvArtwork sd_setImageWithURL:[NSURL URLWithString:songInRow.imgArtwork]
                               placeholderImage:defaultImage
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          if (error) {
                                              NSLog(@"error = %@",error);
                                          }
                                      }];
            
        }else{
            Album *albumInRow = [self.albums objectAtIndex:indexPath.row];
            cell.lblName.text = [[NSString stringWithFormat:@"%lu. ",indexPath.row + 1] stringByAppendingString:albumInRow.albumName];
            cell.lblSinger.text = albumInRow.artistName;
            cell.lblAlbum.text = albumInRow.dateRelease;
            
            // _ListVideo.titleVideo = cell.lblName.text;
            UIImage *defaultImage = [UIImage imageNamed:@"missing_artwork.png"];
            [cell.imvArtwork sd_setImageWithURL:[NSURL URLWithString:albumInRow.imgArtwork]
                               placeholderImage:defaultImage
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          if (error) {
                                              NSLog(@"error = %@",error);
                                          }
                                      }];
        }
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

#pragma mark - delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(smcControl.selectedSegmentIndex == 0){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        _ListVideo = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewControler"];
        
        [self.navigationController pushViewController:_ListVideo animated:YES];
        Song *songInRow = [self.songs objectAtIndex:indexPath.row];
        _ListVideo.titleVideo = songInRow.songName;
        ListCell *cell = [self.tbvList100 cellForRowAtIndexPath:indexPath];
        _ListVideo.navigationItem.title = [cell.lblName.text substringFromIndex:2];
        _ListVideo.navigationItem.backBarButtonItem.title = self.navigationItem.title;
        _ListVideo.keyword = [cell.lblSinger.text stringByAppendingString:[cell.lblName.text substringFromIndex:2]];
        
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        AlbumViewController *albumViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AlbumViewController"];
        ListCell *cell = [self.tbvList100 cellForRowAtIndexPath:indexPath];
        albumViewController.navigationItem.title = [cell.lblName.text substringFromIndex:2];
        albumViewController.navigationItem.backBarButtonItem.title = self.navigationItem.title;
        [self.navigationController pushViewController:albumViewController animated:YES];
        Album *album = [self.albums objectAtIndex:indexPath.row];
        albumViewController.album = album;
    }
}

@end
