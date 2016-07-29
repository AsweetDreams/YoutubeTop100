//
//  Channel.m
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 4/9/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "Channel.h"
#import "GTLYouTube.h"

@implementation Channel

- (id) initWithJSONDictInfo:(NSDictionary *)info;
{
    self = [super init];
    if (self) {
        [self setChannelId:[info objectForKey:@"channelId"]];
        [self setChannelTitle:[info objectForKey:@"channelTitle"]];
        [self setTitle:[info objectForKey:@"title"]];
        
        NSString *stringURLThumbnail = [[[info objectForKey:@"thumbnails"] objectForKey:@"default"] objectForKey:@"url"];
        [self setThumbnail:stringURLThumbnail];
    }
    
    return self;
}

- (id) initWithYoutubeSearchResult:(GTLYouTubeSearchResult *)result
{
    self = [super init];
    if (self) {
        GTLYouTubeSearchResultSnippet *resultSnippet = [result snippet];
        
        [self setChannelId:resultSnippet.channelId];
        [self setChannelTitle:resultSnippet.channelTitle];
        [self setTitle:resultSnippet.title];
        
        [self setThumbnail:[[[resultSnippet thumbnails] medium] url]];
    }
    
    return self;
}

@end
