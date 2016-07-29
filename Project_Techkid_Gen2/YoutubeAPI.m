//
//  YoutubeAPI.m
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 3/27/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "YoutubeAPI.h"
#import "AFNetworking.h"
#import "Video.h"
#import "Channel.h"
#import "TFHpple.h"
#import "PlaylistSearch.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>


static GTLServiceYouTube *service;

@interface YoutubeAPI () {
    dispatch_queue_t _dispatchQueue;
    NSString *queryType;
}

@property NSURLSessionConfiguration *configuration;
@property AFHTTPSessionManager *httpSessionManager;
@property(strong, nonatomic)  NSOperationQueue *queueHTMLParse;
@property(strong, nonatomic) NSMutableArray *ParsingArray;
@property(strong, nonatomic) XCDYouTubeVideoOperation *demo;
@end

@implementation YoutubeAPI
@synthesize currRegion;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static YoutubeAPI *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YoutubeAPI alloc]init];
    });
    
    return sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        currRegion = @"us";
        
        service = [[GTLServiceYouTube alloc] init];
        self.queueHTMLParse = [[NSOperationQueue alloc] init];
        service.shouldFetchNextPages = YES;
        service.retryEnabled = YES;
        _dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    return self;
}

- (GTLServiceYouTube *)youTubeService {
    static GTLServiceYouTube *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLServiceYouTube alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = NO;
        
        service.APIKey = @"AIzaSyDxiDmfSkdQ463GwZD9EN_b06c_O6gkWT0";
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = NO;
    });
    return service;
}

-(void)exploreBlockWithGenne:(NSString *)genne andTrack:(void(^)(NSArray *tracks))completion{
    NSURLSessionConfiguration *Session = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *type = @"topsongs";
    NSString *region = self.currRegion;
    
    AFHTTPSessionManager *httpSession = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:Session];
    
    NSString *urlString = [NSString stringWithFormat:kItunesExploreUrl,region,type,genne] ;
    
    NSURLSessionDataTask *dataTask = [httpSession GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion && responseObject) {
            completion(responseObject[@"feed"][@"entry"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [dataTask resume];
}

//explore album

-(void)exploreListAlbumWithGenne:(NSString *)genne withCompletionBlock:(void(^)(NSArray *array))completion{
    NSURLSessionConfiguration *Session = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NSString *type = @"topalbums";
    NSString *region = self.currRegion;
    
    AFHTTPSessionManager *httpSession = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:Session];
    
    NSString *urlString = [NSString stringWithFormat:kURLExplodeAlbumITunes,region,genne] ;
    
    NSURLSessionDataTask *dataTask = [httpSession GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion && responseObject) {
            completion(responseObject[@"feed"][@"entry"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [dataTask resume];
}



-(void)searchWithKeywork:(NSString *)keywork andType:(NSString *)type andTrack:(void (^)(NSArray *tracks))completion {
    NSMutableArray *listResult = [[NSMutableArray alloc]init];
    GTLQueryYouTube *query = [GTLQueryYouTube queryForSearchListWithPart:@"snippet"];
    query.q = keywork;
    query.maxResults = 30;
    query.type = type;
    
    
    [[self youTubeService] executeQuery:query
                      completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                          
                          if (!error) {
                              //NO ERROR, check data
                              GTLYouTubeSearchListResponse *searchListResponse = (GTLYouTubeSearchListResponse *)object;
                              
                              if ([type isEqualToString:@"channel"]) {
                                  for (GTLYouTubeSearchResult *result in searchListResponse) {
                                      Channel *channel = [[Channel alloc] initWithYoutubeSearchResult:result];
                                      [listResult addObject:channel];
                                  }
                              }
                              
                              else if ([type isEqualToString:@"video"]) {
                                  
                                  NSMutableString *listVideoId = [[NSMutableString alloc] initWithString:@""];
                                  for (GTLYouTubeSearchResult *result in searchListResponse) {
                                      Video *video = [[Video alloc] initWithYoutubeSearchResult:result];
                                      [listResult addObject:video];
                                      [listVideoId appendString:[result.identifier.JSON objectForKey:@"videoId"]];
                                      [listVideoId appendString:@","];
                                  }
                                  
                                  [listVideoId deleteCharactersInRange:NSMakeRange([listVideoId length]-1, 1)];
                                  [self getDataVideoYoutubeWithID:listVideoId withCompletionBlock:^(NSMutableArray *tmpVideos) {
                                      completion(tmpVideos);
                                  }];
                              }
                              
                              else if ([type isEqualToString:@"playlist"]) {
                                  for (GTLYouTubeSearchResult *result in searchListResponse) {
                                      PlaylistSearch *playlist = [[PlaylistSearch alloc] initWithYoutubeSearchResult:result];
                                      [listResult addObject:playlist];
                                  }
                              }
                          }
                          
                          completion(listResult);
                          
                      }];
}

- (void) getDataVideoYoutubeWithID:(NSMutableString *)listId withCompletionBlock:(void(^)(NSMutableArray *tmpVideos))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosListWithPart:@"snippet,contentDetails,statistics"];
    query.identifier = listId;
    
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *object, NSError *error) {
        NSArray<Video *> *listVideo = object.items;
        NSMutableArray *array = [NSMutableArray arrayWithArray:listVideo];
        completion(array);
    }];
}

-(void)autocompleteSegesstions:(NSString *)searchWish
                 andSuggestion:(void(^)(NSMutableArray *ParsingArray))completion{
    //searchWish is the text from your search bar (self.searchBar.text)
    dispatch_suspend(_dispatchQueue);
    dispatch_resume(_dispatchQueue);
    dispatch_async(_dispatchQueue, ^{
        NSString *jsonString = [NSString
                                stringWithFormat:ksuggestionVideoURL, searchWish];
        NSString *URLString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // Encoding to identify where, for example, there are spaces in your query.
        
        NSData *allVideosData = [[NSData alloc]initWithContentsOfURL:[[NSURL alloc]initWithString:URLString]];
        NSString *str = [[NSString alloc]initWithData:allVideosData encoding:NSASCIIStringEncoding];
        NSString *json = nil;
        NSScanner *scanner = [NSScanner scannerWithString:str];
        // Scan to where the JSON begins
        [scanner scanUpToString:@"[[" intoString:NULL];
        if ([str containsString:@"]]]"]) {
            [scanner scanUpToString:@"]]]" intoString:&json];
            json = [NSString stringWithFormat:@"%@%@", json, @"]]]"];
        } else {
            [scanner scanUpToString:@"]]" intoString:&json];
            json = [NSString stringWithFormat:@"%@%@", json, @"]]"];
        }
        //The idea is to identify where the "real" JSON begins and ends.
        
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *errorParseJSON = nil;
        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&errorParseJSON];
        if (jsonObject == nil) {
            NSLog(@"Error: %@", errorParseJSON);
        }
        self.ParsingArray = [[NSMutableArray alloc] init];
        
        for (NSArray *searchItem in jsonObject) {
            NSString *searchString = [searchItem objectAtIndex:0];
            [self.ParsingArray addObject:searchString];
        }
        
        completion(self.ParsingArray);
    });
}

#pragma save jsondata
-(void)loadYoutubeDataWithRegion:(NSString *)region withComletionBlock:(void(^)(NSMutableDictionary *json))completion{
    __block NSMutableDictionary *youtubeDict = [[NSMutableDictionary alloc] init];
    [self exploreVideosInPlaylistWithCompletionBlock:^(NSArray *listId) {
        [self  loadDataWithListVideoId:listId withCompletionBlock:^(NSArray *youtubeData) {
            [youtubeDict setObject:youtubeData forKey:@"Youtube Top 100"];
            completion(youtubeDict);
        }];
    }];
}

- (void) saveYoutubeJson:(NSDictionary *)json toFileAtFolderPath:(NSString *)folderPath{
    /* save file */
    NSString *fileName = @"Youtube Top 100";
    NSString *newFilePath = [folderPath stringByAppendingPathComponent:fileName];
    [self writeWithJson:json andFilePath:newFilePath];
}


-(void)loadDataWithListVideoId:(NSArray *)listId withCompletionBlock:(void(^)(NSArray *youtubeData))completion{
    __block NSMutableArray *tmp1Videos;
    [self getDataYoutubeWithIndex:0 andListId:listId saveTo:tmp1Videos withCompletionBlock:^(NSMutableArray *tempVideos) {
        tmp1Videos = tempVideos;
        [self getDataYoutubeWithIndex:1 andListId:listId saveTo:tmp1Videos withCompletionBlock:^(NSMutableArray *tmpVideos) {
            tmp1Videos = tmpVideos;
            completion(tmp1Videos);
        }];
    }];
}

-(void) getDataYoutubeWithIndex:(int)index andListId:(NSArray *)listId saveTo:(NSMutableArray *)tmp1Videos withCompletionBlock:(void(^)(NSMutableArray *tempVideos))completion{
    __block NSMutableArray *tmp = tmp1Videos;
    NSMutableString *listVideoId = [[NSMutableString alloc] initWithString:@""];
    
    for (NSString *videoId in listId[index] ) {
        [listVideoId appendString:videoId];
        [listVideoId appendString:@","];
    }
    [listVideoId deleteCharactersInRange:NSMakeRange([listVideoId length]-1, 1)];
    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosListWithPart:@"snippet,contentDetails,statistics"];
    query.identifier = listVideoId;
    //query.fields = @"items";
    [[self youTubeService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error)
        {
            NSLog(@"Founded!");
            GTLYouTubeVideoListResponse *videoResults = object;
            //NSLog(@"%@",videoResults.items);
            for (GTLYouTubeVideo *video in videoResults.items)
            {
                GTLYouTubeVideoSnippet *videoSnippet = video.snippet;
                GTLYouTubeVideoContentDetails *videoDetails = video.contentDetails;
                GTLYouTubeVideoStatistics *videoStatistics = video.statistics;
                
                NSString *videoId = [NSString stringWithFormat:@"%@",video.identifier];
                NSString *videoTitle = [videoSnippet.JSON objectForKey:@"title"];
                NSString *videoChannel = [videoSnippet.JSON objectForKey:@"channelTitle"];
                NSNumber *videoDuration = [YoutubeAPI ISO8601FormatToFloatSeconds:[videoDetails.JSON objectForKey:@"duration"]];
                NSNumber *videoViews = [[[NSNumberFormatter alloc] init] numberFromString:[videoStatistics.JSON objectForKey:@"viewCount"]];
                
                NSDictionary *thumbnails = [videoSnippet.JSON objectForKey:@"thumbnails"];
                NSDictionary *thumbnail = [thumbnails objectForKey:@"medium"];
                NSString *videoThumbnail = [thumbnail objectForKey:@"url"];
                
                
                // set video fields
                NSMutableDictionary *videoData = [[NSMutableDictionary alloc] init];
                if(videoId) videoData[@"videoId"] = videoId;
                if (videoTitle) videoData[@"title"] = videoTitle;
                if (videoChannel) videoData[@"channel"] = videoChannel;
                if (videoViews) videoData[@"viewCount"] = videoViews;
                if (videoDuration) videoData[@"videoDuration"] = videoDuration;
                if (videoThumbnail) videoData[@"thumbnail"] = videoThumbnail;
                if(tmp){
                    [tmp addObject:videoData];
                }else{
                    tmp = [[NSMutableArray alloc] initWithObjects:videoData, nil];
                }
            }
            completion(tmp);
        }else{
            NSLog(@"%@",error);
        }
    }];
    
}

-(NSArray *) readYoutubeDataWithRegion:(NSString *)region {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *tmpDirectoryPath = NSTemporaryDirectory();

    NSString *filePath = [tmpDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",region,@"Youtube Top 100"]];
    NSData *data = [manager contentsAtPath:filePath];
    if (!data) {
        return nil;
    }
    
    NSError *jsonError;
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers
                                                            error:&jsonError];
    NSArray *arrayData = [dataDict objectForKey:@"Youtube Top 100"];
    return arrayData;
}

- (void)loadDataWithRegion:(NSString *)region andCategory:(NSDictionary *)category withCompletionBlock:(void(^)(NSDictionary *))completion{
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configure];
    
    NSString *urlString = [NSString stringWithFormat:kURLExplodeITunes,region,category[@"GenreId"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"ERROR:_ %@",error);
        }else{
            completion(responseObject);
        }
    }];
    [dataTask resume];
}

- (void)writeWithJson:(NSDictionary *)json andFilePath:(NSString *)newFilePath{
    NSError *error;
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:json
                                    options:NSJSONWritingPrettyPrinted
                                      error:&error];
    
    NSString *stringData =[[NSString alloc] initWithData:jsonData
                                                encoding:NSUTF8StringEncoding];
    [stringData writeToFile:newFilePath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:NULL];
}

-(BOOL)checkFolderExistWithRegion:(NSString*)region{
    // khoi tao file manager
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *tmpDirectoryPath = NSTemporaryDirectory();
    
    // tao folder
    NSString *folderPath = [tmpDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/",region]];
    BOOL isDir;
    BOOL folderExist = [manager fileExistsAtPath:folderPath isDirectory:&isDir];
    if(folderExist){
        /* file exists */
        if(isDir){
            /* file is a directory */
            return TRUE;
        }else{
            /* file isn't a directory */
            return FALSE;
        }
    }else{
        return FALSE;
    }
}

-(void)createFolderWithRegion:(NSString *) region{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *tmpDirectoryPath = NSTemporaryDirectory();
    NSString *folderPath = [tmpDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/",region]];
    [manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void) saveJson:(NSDictionary *)json toFileAtFolderPath:(NSString *)folderPath andCategory:(NSDictionary *)category{
    /* save file */
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",category[@"Category"]];
    NSString *newFilePath = [folderPath stringByAppendingPathComponent:fileName];
    [self writeWithJson:json andFilePath:newFilePath];
}

- (BOOL)checkFolderNeedUpdate:(NSString *)folderPath{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary* attrs = [manager attributesOfItemAtPath:folderPath error:nil];
    NSDate *dateModification = (NSDate *)[attrs objectForKey:NSFileModificationDate];
    NSTimeInterval secondsInDay = 60;
    NSDate *dateNeedUpdate = [dateModification dateByAddingTimeInterval:secondsInDay];
    NSDate *dateCheckUpdate = [NSDate date];
    if([dateCheckUpdate compare:dateNeedUpdate] == NSOrderedDescending){
        NSLog(@"Need Update");
        return true;
    }else{
        NSLog(@"Don't Update");
        return false;
    }
}

// get list video with keyword

- (void)exploreVideosWithKeyword:(GTLServiceYouTube *)service keyWord:(NSString *)keyword withPageToken:(NSString *)token completionBlock:(void(^)(NSArray *videos,NSString *token))completion;
{
    __block NSMutableArray *tmpVideos = [[NSMutableArray alloc] init];
    // dat bien static sau :v
    NSString *region = self.currRegion;
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForSearchListWithPart:@"snippet"];
    query.type = @"video";
    query.q = keyword;
    query.maxResults = 20;
    query.pageToken = token;
    //query.order =@"viewCount";
    query.regionCode = region;
    query.videoCategoryId = @"10";
    query.fields = @"nextPageToken,items(snippet/title,id/videoId)";
    
    
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeSearchListResponse * resultList, NSError *error) {
            if(!error){
                NSLog(@"%@THIS IS NEXT TOKEN",resultList.nextPageToken);
                //search and make list videoId,save it into tmpVideos
                for (int i = 0; i < [resultList.items count]; i++)
                {
                    GTLYouTubeSearchResult *result = resultList.items[i];
                    GTLYouTubeResourceId *identifier = result.identifier;
                    NSString *videoId = [identifier.JSON objectForKey:@"videoId"];
                    NSMutableDictionary *videoData = [[NSMutableDictionary alloc] init];
                    
                    if (videoId) {
                        videoData[@"videoId"] = videoId;
                    }
                    
                    if (!tmpVideos){
                        tmpVideos = [[NSMutableArray alloc] initWithObjects:videoData, nil];
                    }else{
                        [tmpVideos addObject:videoData];
                    }
                }
                
                // build list Id for query videod.list
                NSMutableString *videoIdList = [[NSMutableString alloc] init];
                for (int i = 0; i < [tmpVideos count]; i++)
                {
                    // add videoId to videoId list
                    [videoIdList appendString:[[tmpVideos objectAtIndex:i] objectForKey:@"videoId"]];
                    [videoIdList appendString:@","];
                }
                
                //start query,get info of video

                GTLQueryYouTube *infoQuery = [GTLQueryYouTube queryForVideosListWithPart:@"id,snippet,contentDetails,statistics"];
                infoQuery.identifier = videoIdList;
                
                [service executeQuery:infoQuery
                    completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                        
                        if (!error)
                        {
                            GTLYouTubeVideoListResponse *videoResults = object;
                            
                            for (int i = 0; i < [videoResults.items count]; i++)
                            {
                                
                                GTLYouTubeVideo *video = videoResults.items[i];
                                GTLYouTubeVideoSnippet *videoSnippet = video.snippet;
                                GTLYouTubeVideoContentDetails *videoDetails = video.contentDetails;
                                GTLYouTubeVideoStatistics *videoStatistics = video.statistics;
                                
                                NSString *videoTitle = [videoSnippet.JSON objectForKey:@"title"];
                                NSString *videoChannel = [videoSnippet.JSON objectForKey:@"channelTitle"];
                                NSNumber *videoDuration = [YoutubeAPI ISO8601FormatToFloatSeconds:[videoDetails.JSON objectForKey:@"duration"]];
                                NSNumber *videoViews = [[[NSNumberFormatter alloc] init] numberFromString:[videoStatistics.JSON objectForKey:@"viewCount"]];
                                
                                NSDictionary *thumbnails = [videoSnippet.JSON objectForKey:@"thumbnails"];
                                NSDictionary *thumbnail = [thumbnails objectForKey:@"medium"];
                                NSString *videoThumbnail = [thumbnail objectForKey:@"url"];
                                
                                
                                // set video fields
                                NSMutableDictionary *videoData = tmpVideos[i];
                                if (videoTitle) videoData[@"title"] = videoTitle;
                                if (videoChannel) videoData[@"channel"] = videoChannel;
                                if (videoViews) videoData[@"viewCount"] = videoViews;
                                if (videoDuration) videoData[@"videoDuration"] = videoDuration;
                                if (videoThumbnail) videoData[@"thumbnail"] = videoThumbnail;
                            }
                            
                            completion(tmpVideos,resultList.nextPageToken);
                        }else{
                            NSLog(@"error = %@",error);
                        }
                    }];
            }else{
                NSLog(@"error = %@",error);
            }
        }];
}



+ (NSNumber *)ISO8601FormatToFloatSeconds:(NSString *)duration
{
    NSString *formatString = [duration copy];
    
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    
    formatString = [formatString substringFromIndex:[formatString rangeOfString:@"T"].location];
    
    // only one letter remains after parsing
    while ([formatString length] > 1)
    {
        // remove first char (T, H, M, or S)
        formatString = [formatString substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:formatString];
        
        // extract next integer in format string
        NSString *nextInteger = [[NSString alloc] init];
        [scanner scanCharactersFromSet:DIGITS_SET intoString:&nextInteger];
        
        // determine range of next integer
        NSRange rangeOfNextInteger = [formatString rangeOfString:nextInteger];
        
        // delete parsed integer from format string
        formatString = [formatString substringFromIndex:rangeOfNextInteger.location + rangeOfNextInteger.length];
        
        if ([[formatString substringToIndex:1] isEqualToString:@"H"])
            hours = [nextInteger intValue];
        
        else if ([[formatString substringToIndex:1] isEqualToString:@"M"])
            minutes = [nextInteger intValue];
        
        else if ([[formatString substringToIndex:1] isEqualToString:@"S"])
            seconds = [nextInteger intValue];
    }
    
    //NSLog(@"Video length (seconds): %f", (hours * 3600.0) + (minutes * 60.0) + (seconds * 1.0));
    return [NSNumber numberWithFloat:((hours * 3600.0) + (minutes * 60.0) + (seconds * 1.0))];
}

#pragma mark - Get Link Streamming
-(void)getLinkStreammingWithVideoid:(NSString *)videoid completion:(void(^)(NSMutableDictionary *link))completion;
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        NSArray *preferredVideoQualities = @[  @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ];
        if (self.demo != nil) {
            [self.demo cancel];
            NSLog(@"Cancel - %@",self.demo);
        }
             NSMutableDictionary *quality = [[NSMutableDictionary alloc]init];
            self.demo = [[XCDYouTubeClient defaultClient]getVideoWithIdentifier:videoid completionHandler:^(XCDYouTubeVideo * _Nullable video, NSError * _Nullable error) {
                if (video)
                {
                   
                    NSURL *streamURL = nil;
                    for (NSNumber *videoQuality in preferredVideoQualities)
                    {
                        streamURL = video.streamURLs[videoQuality];
                        if (streamURL)
                        {
                            
                            [quality setObject:streamURL forKey:[NSString stringWithFormat:@"%@",videoQuality]];
                        }
                    }
                    if (!streamURL)
                    {
                        NSError *noStreamError = [NSError errorWithDomain:XCDYouTubeVideoErrorDomain code:XCDYouTubeErrorNoStreamAvailable userInfo:nil];
                        NSLog(@"%@",noStreamError);
                    }
                }
                    completion(quality);
            }];
    });

}

//get list videos in playlist :3
-(void)exploreVideosInPlaylistWithCompletionBlock:(void(^)(NSArray *listId))completion{
    NSString *region = self.currRegion;
    NSString *playlistId;
    NSString *pListCountries = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"plist"];
    NSArray *countryArray = [[NSArray alloc] initWithContentsOfFile:pListCountries];
    for(NSDictionary *country in countryArray){
        if([country[@"store"] isEqualToString:region]){
            playlistId = country[@"youTubeTopPlaylistId"];
            break;
        }
    }
    //NSLog(@"%@",playlistId);
    __block NSMutableArray *listVideoId = [[NSMutableArray alloc] init];
    GTLQueryYouTube *query = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"snippet"];
    query.playlistId = playlistId;
    query.maxResults = 50;
    query.fields = @"items(snippet/resourceId/videoId),nextPageToken";
    __block NSString *nextPageToken;
    // 50 bai dau
    [[self youTubeService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        GTLYouTubeVideoListResponse *result = object;
        nextPageToken = result.nextPageToken;
        for(GTLYouTubePlaylistItem *video in result){
            GTLYouTubePlaylistItemSnippet *videoSnippet = video.snippet;
            GTLYouTubeResourceId *videoResourceId = videoSnippet.resourceId;
            NSString *videoId = videoResourceId.videoId;
            [listVideoId addObject:videoId];
        }
        [self exploreLast50VideosWithPlaylistId:playlistId andFirst50Array:listVideoId andNextPageToken:nextPageToken WithCompletionBlock:^(NSArray *listId) {
            completion(listId);
        }];
    }];
}

-(void)exploreLast50VideosWithPlaylistId:(NSString *)playlistId andFirst50Array:(NSMutableArray *)firstArray andNextPageToken:(NSString *)nextPageToken WithCompletionBlock:(void(^)(NSArray *listId))completion{
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"snippet"];
    query.playlistId = playlistId;
    query.maxResults = 50;
    query.fields = @"items(snippet/resourceId/videoId)";
    query.pageToken = nextPageToken;
    __block NSMutableArray *secondArray;
    
    [[self youTubeService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        GTLYouTubeVideoListResponse *result1 = object;
        for(GTLYouTubePlaylistItem *video in result1){
            GTLYouTubePlaylistItemSnippet *videoSnippet = video.snippet;
            GTLYouTubeResourceId *videoResourceId = videoSnippet.resourceId;
            NSString *videoId = videoResourceId.videoId;
            if(secondArray){
                [secondArray addObject:videoId];
            }else{
                secondArray = [[NSMutableArray alloc] initWithObjects:videoId, nil];
            }
        }
        NSArray *listId = [[NSArray alloc] initWithObjects:firstArray,secondArray, nil];
        completion(listId);
    }];
}

-(void)exploreListSongFromAlbumWithId:(NSString *)albumId withCompletionBlock:(void(^)(NSDictionary *dict))completion{
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configure];
    
    NSString *urlString = [NSString stringWithFormat:kURLExploreListSongFromAlbumITunes,albumId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"ERROR:_ %@",error);
        }else{
            completion(responseObject);
        }
    }];
    [dataTask resume];
}




@end
