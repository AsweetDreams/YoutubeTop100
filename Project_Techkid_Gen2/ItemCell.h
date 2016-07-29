//
//  ItemCell.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VYPlayIndicator.h"

@interface ItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImg;
@property (weak, nonatomic) IBOutlet UILabel *videoNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *viewLbl;
@property (weak, nonatomic) IBOutlet UILabel *channelLbl;
@property (weak, nonatomic) IBOutlet UILabel *durationLbl;
@property (weak, nonatomic) NSString *videoid;

@property (nonatomic, readonly, strong) VYPlayIndicator *playIndicator;
@end
