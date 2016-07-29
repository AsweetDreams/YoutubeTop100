//
//  MenuViewController.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuTbv;

@end
