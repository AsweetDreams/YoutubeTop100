//
//  VideoViewController.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/1/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YoutubeAPI.h"
#import "MarqueeLabel.h"



@interface VideoViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong) IBOutlet UITableView *tbvVideo;

@property(nonatomic,strong) NSString *titleVideo;
@property (nonatomic,strong) NSString *keyword;
@end
