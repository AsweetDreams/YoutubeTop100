//
//  PLaylistTableViewCell.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/4/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLaylistTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgPlaylist;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblcount;

- (void)displayBtnNewPlaylist;


@end
