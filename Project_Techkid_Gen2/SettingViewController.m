//
//  SettingViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/29/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "SettingViewController.h"
#import "SWRevealViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tbvSetting.delegate = self;
    _tbvSetting.dataSource = self;
    self.quality = 720;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:YES];
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 70.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:@"setting_video"];
        cell.textLabel.text = [NSString stringWithFormat:@"Video Quality:  %ldp",self.quality];
    }
    else{
        cell.imageView.image = [UIImage imageNamed:@"setting_share"];
        cell.textLabel.text = @"Share App";

    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        [self AcctionSheet];
    }else{
        NSString *textToShare = @"your text";
        UIImage *imageToShare = [UIImage imageNamed:@"musical"];
        NSArray *itemsToShare = @[textToShare, imageToShare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeMessage, UIActivityTypeMail,
                                        UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        [self presentViewController:activityVC animated:YES completion:nil];

    }
}

-(void)AcctionSheet;
{
    UIActionSheet *pop = [[UIActionSheet alloc]initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"240",@"360",@"720", nil];
    
    pop.tag = 1;
    [pop showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 0:
            self.quality = 240;
            [_tbvSetting reloadData];
            break;
        case 1:
            self.quality = 360;
            [_tbvSetting reloadData];
            break;
        case 2:
            self.quality = 720;
            [_tbvSetting reloadData];
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Quality" object:[NSString stringWithFormat:@"%ld",self.quality]];
}
@end
