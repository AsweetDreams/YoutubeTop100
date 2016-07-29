//
//  AppDelegate.h
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingViewController.h"
#import "Reachability.h"


@class PlayingViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL internetActive;
@property (strong,nonatomic)Reachability *reach;
@property(nonatomic) NetworkStatus netStatus;

@property(nonatomic) BOOL isOrientationOn;
@property (nonatomic,strong) PlayingViewController *playing;

@end

