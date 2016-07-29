//
//  Album.h
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 4/13/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject
@property (nonatomic,strong) NSString *albumName;
@property (nonatomic,strong) NSString *albumId;
@property (nonatomic,strong) NSString *imgArtwork;
@property (nonatomic,strong) NSString *artistName;
@property (nonatomic,strong) NSString *dateRelease;
@property (nonatomic,strong) NSString *genre;


-(instancetype)initWithJsonDict:(NSDictionary *)json;
@end
