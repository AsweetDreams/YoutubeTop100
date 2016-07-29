//
//  Song.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/30/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "Song.h"

@implementation Song
- (instancetype)initWithJsonDict:(NSDictionary *)json;
{
    self = [self init];
    if (self) {
        self.songName = json[@"im:name"][@"label"];
        self.imgArtwork = json[@"im:image"][2][@"label"];
        self.singerName = json[@"im:artist"][@"label"];
        self.albumName = json[@"im:collection"][@"im:name"][@"label"];
    }
    return self;
    
}
@end
