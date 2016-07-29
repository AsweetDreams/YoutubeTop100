//
//  RegionViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 4/15/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "RegionViewController.h"
#import "YoutubeAPI.h"

@interface RegionViewController ()
@property (nonatomic,strong) NSArray *listCountry;
@property (nonatomic,assign) int index;
@end

@implementation RegionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *pListCountry = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"plist"];
    _listCountry = [[NSArray alloc] initWithContentsOfFile:pListCountry];
    for (int i = 0;i < _listCountry.count;i++) {
        if([_listCountry[i][@"store"] isEqualToString:sYoutubeAPI.currRegion]){
            _index = i;
            break;
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma tableview datasource and delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _listCountry.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell =  [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    cell.textLabel.text = [_listCountry[indexPath.row] objectForKey:@"name"];
    cell.imageView.image = [UIImage imageNamed:[_listCountry[indexPath.row] objectForKey:@"image"]];
    if(indexPath.row == _index){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    sYoutubeAPI.currRegion = [_listCountry[indexPath.row] objectForKey:@"store"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
