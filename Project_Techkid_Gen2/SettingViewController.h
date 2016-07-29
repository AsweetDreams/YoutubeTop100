//
//  SettingViewController.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/29/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tbvSetting;
@property( nonatomic,assign) NSInteger quality;

@end
