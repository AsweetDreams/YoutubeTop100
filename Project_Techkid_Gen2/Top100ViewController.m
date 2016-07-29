//
//  Top100ViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//


#import "Top100ViewController.h"
#import "DetailTop100ViewController.h"
#import "SWRevealViewController.h"
#import "CategoryCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "YoutubeAPI.h"
#import "Song.h"
#import "RegionViewController.h"

@interface Top100ViewController ()
{
    AppDelegate *ad;
}
@property(nonatomic,strong) NSArray *categoryList;
@property (nonatomic,strong) NSMutableDictionary *imageURLList;

@end

@implementation Top100ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ad = [[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view.
    NSString *pListCategoryVideo = [[NSBundle mainBundle] pathForResource:@"categoryVideos" ofType:@"plist"];
    NSDictionary *categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:pListCategoryVideo];
    self.categoryList = categoryDictionary[@"categoryVideo"];
    self.imageURLList = [[NSMutableDictionary alloc] init];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
// sidebar
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarBtn setTarget: self.revealViewController];
        [self.sidebarBtn setAction: @selector( revealToggle: )];
        // Custom
        // Example sidebar is width 200
        self.revealViewController.rearViewRevealWidth = 250;
        // Cannot drag and see beyond width 200
        self.revealViewController.rearViewRevealOverdraw = 0;
        // Faster slide animation
        self.revealViewController.toggleAnimationDuration = 0.5;
        // Simply ease out. No Spring animation.
        self.revealViewController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;
        // More shadow
        self.revealViewController.frontViewShadowRadius = 5;
        //[revealViewController panGestureRecognizer];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
        [sYoutubeAPI exploreVideosInPlaylistWithCompletionBlock:^(NSArray *listId) {
        }];
        
        //image button
        NSString *pListCountry = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"plist"];
        NSArray *temp = [[NSArray alloc] initWithContentsOfFile:pListCountry];
        NSString *imgName;
        for (int i = 0;i < temp.count;i++) {
            if([temp[i][@"store"] isEqualToString:sYoutubeAPI.currRegion]){
                imgName = temp[i][@"image"];
                break;
            }
        }
        UIImage *myImage = [[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _btnRegion.image = myImage;
        NSString *tmpDirectoryPath = NSTemporaryDirectory();
        NSString *folderPath = [tmpDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/",sYoutubeAPI.currRegion]];
        NSLog(@"%@",sYoutubeAPI.currRegion);
        BOOL folderExist = [sYoutubeAPI checkFolderExistWithRegion:sYoutubeAPI.currRegion];
        if (folderExist) {
            //exist check update
            BOOL needUpdate = [sYoutubeAPI checkFolderNeedUpdate:folderPath];
            if(needUpdate){
                for(int i = 0;i< _categoryList.count;i++){
                    if(i !=1){
                        [sYoutubeAPI loadDataWithRegion:sYoutubeAPI.currRegion andCategory:_categoryList[i] withCompletionBlock:^(NSDictionary *json){
                            [sYoutubeAPI saveJson:json toFileAtFolderPath:folderPath andCategory:_categoryList[i]];
                            [self downloadImageWithJson:json andCategory:_categoryList[i] atIndex:i];
                        }];
                    }else{
                        //case Youtube Top 100
                        // need save top1 image with key in cache
                        [sYoutubeAPI loadYoutubeDataWithRegion:sYoutubeAPI.currRegion withComletionBlock:^(NSMutableDictionary *json){
                            //NSLog(@"%@_________",json);
                            [sYoutubeAPI saveYoutubeJson:json toFileAtFolderPath:folderPath];
                            [self downloadImageWithYoutubeData:json];
                        }];
                    }
                }
            }else{
                [_categoryTbl reloadData];
            }
        }else{
            [sYoutubeAPI createFolderWithRegion:sYoutubeAPI.currRegion];
            for(int i = 0;i< _categoryList.count;i++){
                if(i !=1){
                    [sYoutubeAPI loadDataWithRegion:sYoutubeAPI.currRegion andCategory:_categoryList[i] withCompletionBlock:^(NSDictionary *json){
                        [sYoutubeAPI saveJson:json toFileAtFolderPath:folderPath andCategory:_categoryList[i]];
                        [self downloadImageWithJson:json andCategory:_categoryList[i] atIndex:i];
                    }];
                }else{
                    //case Youtube Top 100
                    // need save top1 image with key in cache
                    [sYoutubeAPI loadYoutubeDataWithRegion:sYoutubeAPI.currRegion withComletionBlock:^(NSDictionary *json){
                        [sYoutubeAPI saveYoutubeJson:json toFileAtFolderPath:folderPath];
                        [self downloadImageWithYoutubeData:json];
                        
                    }];
                }
            }
        }

    }
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
}
#pragma load anh
//youtube top1 image
-(void)downloadImageWithYoutubeData:(NSDictionary *)json{
    NSArray *data = json[@"Youtube Top 100"];
    NSDictionary *top1Data = [data objectAtIndex:0];
    NSString *stringUrl = [top1Data objectForKey:@"thumbnail"];
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSString *keyStore = [sYoutubeAPI.currRegion stringByAppendingString:@"Youtube Top 100"];
    [self.imageURLList setObject:url forKey:keyStore];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSArray* indexArray = [NSArray arrayWithObjects:indexPath, nil];
    [self.categoryTbl reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
}
//
-(void)downloadImageWithJson:(NSDictionary *)json andCategory:(NSDictionary *)category atIndex:(int)i{
    NSDictionary *top1Data;
    if([json[@"feed"][@"entry"] isKindOfClass:[NSArray class]]){
        top1Data = [json[@"feed"][@"entry"] objectAtIndex:0];
    }else{
        top1Data = json[@"feed"][@"entry"];
    }
    NSArray *temp1 = [top1Data objectForKey:@"im:image"];
    NSDictionary *temp2 = [temp1 objectAtIndex:1];
    NSString *stringURL = [temp2 objectForKey:@"label"];
    NSURL *imageURL = [NSURL URLWithString:stringURL];
    NSString *keyStore = [sYoutubeAPI.currRegion stringByAppendingString:category[@"Category"]];
    [self.imageURLList setObject:imageURL forKey:keyStore];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    NSArray* indexArray = [NSArray arrayWithObjects:indexPath, nil];
    [self.categoryTbl reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  table data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categoryList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSString *cellId = [categoryList objectAtIndex:indexPath];
    static NSString *cellId = @"categoryCell";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"CategoryCell" bundle:nil] forCellReuseIdentifier:cellId];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    cell.categoryLabel.text = _categoryList[indexPath.row][@"Category"];
    UIImage *defaultImage = [UIImage imageNamed:@"missing_artwork.png"];
    
    NSString *keyStore = [sYoutubeAPI.currRegion stringByAppendingString:_categoryList[indexPath.row][@"Category"]];
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:keyStore done:^(UIImage *image, SDImageCacheType cacheType) {
        if(image){
            cell.categoryImg.image = image;
        }else{
            [cell.categoryImg sd_setImageWithURL:[self.imageURLList objectForKey:keyStore]
                                placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    if (error) {
                                            NSLog(@"error = %@",error);
                                    }else{
                                        cacheType = SDImageCacheTypeDisk;
                                    [[SDImageCache sharedImageCache] storeImage:image forKey:keyStore];
                                    }
                                }];
        }
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // tao segue voi customcell
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row != 1){
        DetailTop100ViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"showListTop100"];
        CategoryCell *cell = [self.categoryTbl cellForRowAtIndexPath:indexPath];
        destViewController.navigationItem.title = cell.categoryLabel.text;

        [self.navigationController pushViewController:destViewController animated:YES];
        destViewController.genreIndex = indexPath.row;
    }else{
        VideoViewController *videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewControler"];
        CategoryCell *cell = [self.categoryTbl cellForRowAtIndexPath:indexPath];
        videoViewController.navigationItem.title = cell.categoryLabel.text;
        [self.navigationController pushViewController:videoViewController animated:YES];
        
    }
}


-(void)chooseRegion:(id)sender{
    RegionViewController *rVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegionViewController"];
    [rVC setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:rVC animated:YES completion:nil];
    
}
@end
