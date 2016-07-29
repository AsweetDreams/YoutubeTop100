//
//  PlaylistSearch.m
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 4/9/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "PlaylistSearch.h"

@implementation PlaylistSearch

- (id) initWithYoutubeSearchResult:(GTLYouTubeSearchResult *)result {
    self = [super init];
    if (self) {
        GTLYouTubeSearchResultSnippet *resultSnippet = [result snippet];
        [self setPlaylistId:[[[result identifier] JSON] objectForKey:@"playlistId"]];
        [self setThumbnail:[[[resultSnippet thumbnails] medium] url]];
        [self setPlaylistTitle:resultSnippet.title];
    }
    
    return self;
}

@end
