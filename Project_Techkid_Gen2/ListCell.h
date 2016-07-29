//
//  ListCell.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/30/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imvArtwork;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbum;
@property (weak, nonatomic) IBOutlet UILabel *lblSinger;

@end
