//
//  HistoryViewController.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarBtn;
@property (weak, nonatomic) IBOutlet UITableView *historyTbv;
@property(nonatomic,strong) NSString *playlistName;

@end
