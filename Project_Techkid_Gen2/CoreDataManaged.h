//
//  CoreDataManaged.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/3/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface CoreDataManaged : NSObject

#define Instance [CoreDataManaged ShareInstance] 

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(instancetype)ShareInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


-(NSMutableArray *)ReadingCoreData;
-(BOOL)SavingCoreDataWithtitle:(NSString *)title andData:(NSData *)image andVideoID:(NSString *)videoid andDate:(NSDate *)date andVideoCount:(NSNumber *)viewCount andDuration:(NSNumber *)duration;
-(void)DeleteCoreDataWithTrack:(NSInteger )currentTrack;


-(BOOL)SavingCoreDataWithPLaylist:(NSString *)title andImage:(NSString *)image andIndex:(NSInteger )index andDate:(NSDate *)date;
-(NSMutableArray *)ReadingWithPlaylistCoreData;
-(void)DeleteCoreDataWithPlaylist:(NSInteger )currentTrack;

-(BOOL)SavingCoreDataWithPlaylistTracks:(NSString *)title andImage:(NSData *)image andTrackid:(NSString *)trackid andVideoid:(NSString *)vieoid;
-(NSMutableArray *)ReadingWithPlaylistTracksCoreData;
-(void)DeleteCoreDataWithPlaylistTracks:(NSInteger )currentTrack;
@end
