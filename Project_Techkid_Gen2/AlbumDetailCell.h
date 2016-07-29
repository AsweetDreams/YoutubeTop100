//
//  AlbumDetailCell.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 4/13/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imvArtwork;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbumName;
@property (weak, nonatomic) IBOutlet UILabel *lblArtist;
@property (weak, nonatomic) IBOutlet UILabel *lblGenre;
@property (weak, nonatomic) IBOutlet UILabel *lblReleaseDate;

@end
