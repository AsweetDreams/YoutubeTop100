//
//  DetailTop100ViewController.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/30/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoViewController.h"

@interface DetailTop100ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivLoading;
@property (strong, nonatomic) IBOutlet UISegmentedControl *smcControl;
@property (weak, nonatomic) IBOutlet UITableView *tbvList100;
@property (nonatomic,assign) NSInteger genreIndex;
- (IBAction)selectType:(UISegmentedControl *)sender;

@end
