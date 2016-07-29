//
//  SelectPlaylistViewController.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/5/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"

@interface SelectPlaylistViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tbvSelect;
@property(strong,nonatomic) NSData *imageData;
@property(nonatomic,strong) NSString *Name;
@property(nonatomic,strong) NSString *videoid;

- (IBAction)dismiss:(id)sender;

@end
