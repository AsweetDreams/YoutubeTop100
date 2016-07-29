//
//  Channel.h
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 4/9/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

@interface Channel : NSObject

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelTitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *thumbnail;

- (id) initWithYoutubeSearchResult:(GTLYouTubeSearchResult *)result;

@end
