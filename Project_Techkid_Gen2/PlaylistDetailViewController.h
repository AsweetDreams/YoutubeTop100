//
//  PlaylistDetailViewController.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/5/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackPlaylist.h"
#import "Playlist.h"

@interface PlaylistDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) Playlist *selected;

@property (strong, nonatomic) IBOutlet UITableView *tbvDetail;





@end
