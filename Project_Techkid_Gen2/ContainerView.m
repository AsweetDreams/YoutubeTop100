//
//  ContainerView.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/12/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "ContainerView.h"

@implementation ContainerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


@end
