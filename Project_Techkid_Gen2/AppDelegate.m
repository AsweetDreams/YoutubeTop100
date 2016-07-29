//
//  AppDelegate.m
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "AppDelegate.h"
#import "YoutubeAPI.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    _reach = [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    
    [self checkNetworkStatus:nil];
    //_playing = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PlayingViewController class])];
    
    _playing = [[PlayingViewController alloc]initWithNibName:NSStringFromClass([PlayingViewController class]) bundle:nil];
    
    [self.window.rootViewController.view addSubview:self.playing.view];
    
    [self.window.rootViewController addChildViewController:self.playing];
    
    CGRect playerFrame = self.window.rootViewController.view.bounds;
    UIScreen *mainScreen = [UIScreen mainScreen];
    playerFrame.size.height = mainScreen.bounds.size.height + self.playing.viewHeader.frame.size.height + 20;
    playerFrame.origin.y = playerFrame.size.height;
    self.playing.view.frame = playerFrame;
    
    self.window.tintColor = [UIColor orangeColor];
        return YES;
}
- (void)checkNetworkStatus:(NSNotification *)notice
{
    _netStatus = [_reach currentReachabilityStatus];
    if (_netStatus == NotReachable)
    {
        _internetActive = NO;
        NSLog(@"The internet is down.");
        // do stuff when network gone.
    }
    else
    {
        _internetActive = YES;
        NSLog(@"The internet is working!");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
