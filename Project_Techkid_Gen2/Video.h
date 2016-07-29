//
//  Video.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/30/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

@interface Video : GTLYouTubeVideo

@property (nonatomic,strong) NSString *videoName;
@property (nonatomic,strong) NSString *videoId;
@property (nonatomic,strong) NSString *thumbnails;
@property (nonatomic,strong) NSNumber *viewCount;
@property (nonatomic,strong) NSString *channel;
@property (nonatomic,strong) NSNumber *duration;
@property (nonatomic,strong) NSData *image;

- (instancetype)initWithJsonDict:(NSDictionary *)json;
- (id)initWithYoutubeSearchResult:(GTLYouTubeSearchResult *)result;

-(NSString *)covertStringWithDurationNumber: (NSInteger)number;

-(NSString *)covertStringWithViewNumber: (NSInteger)number;


@end
