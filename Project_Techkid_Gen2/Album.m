//
//  Album.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 4/13/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "Album.h"

@implementation Album
- (instancetype)initWithJsonDict:(NSDictionary *)json;
{
    self = [self init];
    if (self) {
        self.albumName = json[@"im:name"][@"label"];
        self.imgArtwork = json[@"im:image"][2][@"label"];
        self.artistName = json[@"im:artist"][@"label"];
        self.albumId = json[@"id"][@"attributes"][@"im:id"];
        self.genre = json[@"category"][@"atributes"][@"term"];
        self.dateRelease = json[@"im:releaseDate"][@"attributes"][@"label"];
    }
    return self;
    
}
@end
