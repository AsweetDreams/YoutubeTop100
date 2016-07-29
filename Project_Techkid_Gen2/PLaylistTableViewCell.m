//
//  PLaylistTableViewCell.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/4/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "PLaylistTableViewCell.h"

@implementation PLaylistTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayBtnNewPlaylist;
{
    _imgPlaylist.image = [UIImage imageNamed:@"bt_add"];
    _lblName.text = @"Add New Playlist";
}

//- (void)displayPlaylist:(PLaylistTableViewCell *)playlist;
//{
//    
//}
@end
