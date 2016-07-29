//
//  ItemCell.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "ItemCell.h"
#import "Video.h"
@interface ItemCell()

@property (nonatomic, readwrite, strong) VYPlayIndicator *playIndicator;

@end

@implementation ItemCell

- (void)awakeFromNib {
}

- (IBAction)btnMore:(id)sender {
    NSString *videoName = self.videoNameLbl.text;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"btnMore" object:videoName];
}


@end
