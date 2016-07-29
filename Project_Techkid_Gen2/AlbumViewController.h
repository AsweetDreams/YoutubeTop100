//
//  AlbumViewController.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 4/13/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface AlbumViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tbvAlbum;
@property (nonatomic,strong) NSString *albumId;
@property (nonatomic,strong) Album *album;
@end
