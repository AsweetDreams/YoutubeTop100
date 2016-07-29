
//
//  Video.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/30/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "Video.h"

@implementation Video

- (id)initWithYoutubeSearchResult:(GTLYouTubeSearchResult *)result;
{
    self = [self init];
    
    if (self) {

        NSDictionary *identifier = result.identifier.JSON;
        GTLYouTubeSearchResultSnippet *resultSnippet = result.snippet;
        
        [self setVideoId:[identifier objectForKey:@"videoId"]];
        [self setVideoName:[resultSnippet title]];
        [self setThumbnails:[[[resultSnippet thumbnails] medium] url]];
    }
    return self;
}

- (instancetype)initWithJsonDict:(NSDictionary *)json;
{
    self = [self init];
    if (self) {
        self.videoName = json[@"title"];
        self.videoId = json[@"videoId"];
        self.thumbnails = json[@"thumbnail"];
        self.viewCount = json[@"viewCount"];
        self.channel = json[@"channel"];
        self.duration = json[@"videoDuration"];
    }
    return self;
    
}

-(NSString *)covertStringWithDurationNumber: (NSInteger)number;{
    
    NSInteger time = number;
    NSString *timeString = @"";
    NSInteger hours = time / 3600;
    NSInteger minutes = (time - hours * 3600) / 60;
    NSInteger seconds = time % 60;
    
    
    if (hours > 0) {
        timeString = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        timeString = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    }
    return timeString;
}

-(NSString *)covertStringWithViewNumber: (NSInteger)number;
{
    NSString *ViewCountString = @"";
    NSInteger viewcount = number;
    NSInteger million = viewcount / 1000000;
    CGFloat thousand = (viewcount - million*1000000) / 10000;
    
    if (million > 0) {
        ViewCountString = [NSString stringWithFormat:@"%ldM,%02ld views",(long)million,(long)thousand];
    }else{
        ViewCountString = [NSString stringWithFormat:@"%ldM views",(long)thousand];
    }
    return ViewCountString;
}
@end
