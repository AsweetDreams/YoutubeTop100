//
//  YoutubeAPI.h
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 3/27/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"
#import "Constant.h"

#define sYoutubeAPI [YoutubeAPI sharedInstance]
#define DIGITS_SET [NSCharacterSet characterSetWithCharactersInString:@"0123456789"]

@interface YoutubeAPI : NSObject{
    NSString *currRegion;
}
@property (nonatomic, retain) NSString *currRegion;

+ (instancetype) sharedInstance;

- (GTLServiceYouTube *)youTubeService;


//search;
//-(void)SearchwithKeywork:(NSString *)keywork andTrack:(void (^)(NSArray *tracks))completion;
- (void)exploreVideosWithKeyword:(GTLServiceYouTube *)service keyWord:(NSString *)keyword withPageToken:(NSString *)token completionBlock:(void(^)(NSArray *videos,NSString *token))completion;

-(void)searchWithKeywork:(NSString *)keywork andType:(NSString *)type andTrack:(void (^)(NSArray *tracks))completion;

//top album
-(void)exploreListAlbumWithGenne:(NSString *)genne withCompletionBlock:(void(^)(NSArray *array))completion;

//top song
-(void)exploreBlockWithGenne:(NSString *)genne andTrack:(void(^)(NSArray *tracks))completion;

//suggesstion
-(void)autocompleteSegesstions : (NSString *)searchWish andSuggestion:(void(^)(NSMutableArray *ParsingArray))completion;

// save jsondata
-(BOOL)checkFolderExistWithRegion:(NSString*)region;
-(void)createFolderWithRegion:(NSString *) region;
- (void)writeWithJson:(NSDictionary *)json andFilePath:(NSString *)newFilePath;
- (BOOL)checkFolderNeedUpdate:(NSString *)folderPath;

// save youtube data
-(NSArray *) readYoutubeDataWithRegion:(NSString *)region;

-(void) getDataYoutubeWithIndex:(int)index andListId:(NSArray *)listId saveTo:(NSMutableArray *)tmpVideos withCompletionBlock:(void(^)(NSMutableArray *tempVideos))completion;
- (void) saveYoutubeJson:(NSDictionary *)json toFileAtFolderPath:(NSString *)folderPath;
-(void)loadYoutubeDataWithRegion:(NSString *)region withComletionBlock:(void(^)(NSMutableDictionary *json))completion;
-(void)loadDataWithListVideoId:(NSArray *)listId withCompletionBlock:(void(^)(NSArray *youtubeData))completion;


- (void)loadDataWithRegion:(NSString *)region andCategory:(NSDictionary *)category withCompletionBlock:(void(^)(NSDictionary *))completion;
- (void) saveJson:(NSDictionary *)json toFileAtFolderPath:(NSString *)folderPath andCategory:(NSDictionary *)category;

+ (NSNumber *)ISO8601FormatToFloatSeconds:(NSString *)duration;

-(void)getLinkStreammingWithVideoid:(NSString *)videoid completion:(void(^)(NSMutableDictionary *link))completion;

//get Youtube Top 100
-(void)exploreVideosInPlaylistWithCompletionBlock:(void(^)(NSArray *listId))completion;
-(void)exploreLast50VideosWithPlaylistId:(NSString *)playlistId andFirst50Array:(NSMutableArray *)firstArray andNextPageToken:(NSString *)nextPageToken WithCompletionBlock:(void(^)(NSArray *listId))completion;

//album

-(void)exploreListSongFromAlbumWithId:(NSString *)albumId withCompletionBlock:(void(^)(NSDictionary *dict))completion;

@end
