//
//  PlaylistSearch.h
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 4/9/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

@interface PlaylistSearch : NSObject

@property (nonatomic, strong) NSString* playlistId;
@property (nonatomic, strong) NSString* thumbnail;
@property (nonatomic, strong) NSString* playlistTitle;
@property (nonatomic, strong) NSString* description;

- (id) initWithYoutubeSearchResult:(GTLYouTubeSearchResult *)result;

@end
