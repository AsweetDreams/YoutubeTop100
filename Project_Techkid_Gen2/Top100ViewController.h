//
//  Top100ViewController.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface Top100ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarBtn;
@property (weak, nonatomic) IBOutlet UITableView *categoryTbl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRegion;


- (IBAction)chooseRegion:(id)sender;
@end
