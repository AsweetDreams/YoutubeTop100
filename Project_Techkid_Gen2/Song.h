//
//  Song.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/30/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject
@property (nonatomic,strong) NSString *songName;
//@property (nonatomic,strong) NSString *songId;
@property (nonatomic,strong) NSString *imgArtwork;
@property (nonatomic,strong) NSString *singerName;
@property (nonatomic,strong) NSString *albumName;

-(instancetype)initWithJsonDict:(NSDictionary *)json;
@end
