//
//  PlaylistsViewController.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/29/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistsViewController : UIViewController <UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sideBar;

@property (strong, nonatomic) IBOutlet UITableView *tbvPlaylist;


@end
