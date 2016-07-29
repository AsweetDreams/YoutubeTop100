//
//  AlbumViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 4/13/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "AlbumViewController.h"
#import "AlbumItemCell.h"
#import "AlbumDetailCell.h"
#import "YoutubeAPI.h"
#import "UIImageView+WebCache.h"
#import "VideoViewController.h"

@interface AlbumViewController ()
@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _items = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    [sYoutubeAPI exploreListSongFromAlbumWithId:_album.albumId withCompletionBlock:^(NSDictionary *array) {

        for(int i = 1;i< [array[@"results"] count];i++){
            NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] init];
            [itemInfo setObject:array[@"results"][i][@"trackName"] forKey:@"trackName"];
            [itemInfo setObject:array[@"results"][i][@"trackTimeMillis"] forKey:@"duration"];
            [_items addObject:itemInfo];
        }
        [_tbvAlbum reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return 70.0f;
    }else{
        return 35.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count +1.0f;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Cell1 = @"AlbumDetailCell";
    static NSString *Cell2 = @"AlbumItemCell";
    
    UINib *nib = [UINib nibWithNibName:@"AlbumDetailCell" bundle:nil];
    [self.tbvAlbum registerNib:nib forCellReuseIdentifier:Cell1];
    
    nib = [UINib nibWithNibName:@"AlbumItemCell" bundle:nil];
    [self.tbvAlbum registerNib:nib forCellReuseIdentifier:Cell2];
    
    if (indexPath.row == 0) {
        AlbumDetailCell *cell = (AlbumDetailCell *)[tableView dequeueReusableCellWithIdentifier:Cell1];
        cell.lblAlbumName.text = _album.albumName;
        cell.lblArtist.text = _album.artistName;
        cell.lblGenre.text = _album.genre;
        cell.lblReleaseDate.text = _album.dateRelease;
        UIImage *defaultImage = [UIImage imageNamed:_album.imgArtwork];
        [cell.imvArtwork sd_setImageWithURL:_album.imgArtwork
                            placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (error) {
                                    NSLog(@"error = %@",error);
                                }
                            }];
        
        return cell;
    }else{
        AlbumItemCell *cell = (AlbumItemCell *)[tableView dequeueReusableCellWithIdentifier:Cell2];
        // Configure cell
        cell.lblIndex.text = [NSString stringWithFormat:@"%lu",indexPath.row];
        cell.lblName.text = _items[indexPath.row - 1][@"trackName"];
        cell.lblDuration.text = [_items[indexPath.row - 1][@"duration"] stringValue];
        return cell;
    }
}

#pragma mark - delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    VideoViewController *vvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewControler"];
    
    [self.navigationController pushViewController:vvc animated:YES];
    AlbumItemCell *cell = [self.tbvAlbum cellForRowAtIndexPath:indexPath];
    vvc.navigationItem.title = cell.lblName.text;
    vvc.keyword = [cell.lblName.text stringByAppendingString:[NSString stringWithFormat:@" - %@",_album.artistName]];
}

@end
