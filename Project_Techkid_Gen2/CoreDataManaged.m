//
//  CoreDataManaged.m
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/3/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "CoreDataManaged.h"
#import "Track.h"
#import "playlist.h"
#import "TrackPlaylist.h"

@implementation CoreDataManaged

+(instancetype)ShareInstance;
{
    static dispatch_once_t once_t;
    static CoreDataManaged *ShareInstance;
    
    dispatch_once(&once_t, ^{
        ShareInstance = [[CoreDataManaged alloc]init];
    });
    return ShareInstance;
}

#pragma mark - History
-(BOOL)SavingCoreDataWithtitle:(NSString *)title andData:(NSData *)image andVideoID:(NSString *)videoid andDate:(NSDate *)date andVideoCount:(NSNumber *)viewCount andDuration:(NSNumber *)duration;
{
    BOOL result = NO;
    
    if ([title length] == 0 ) {
        NSLog(@"tilte are Mandatory ");
        return NO;
    }
    NSMutableArray *Array = [self ReadingCoreData];
    for (Track *tracks in Array) {
        if ([tracks.videoid isEqualToString:videoid]) {
            return NO;
        }
    }
    
        NSLog(@"%@ -%@",duration,viewCount);
    
    Track *tracks = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    

    if (tracks == nil) {
        NSLog(@"Failed to create the new person");
        return NO;
    }
    else{
        tracks.title = title;
        tracks.atwork = image;
        tracks.videoid = videoid;
        tracks.atCreate = date;
        tracks.duration = duration;
        tracks.viewcount = viewCount;
        
        NSError *savingError = nil;
    
        if ([self.managedObjectContext save:&savingError]) {
        return YES;
        }
        else{
            NSLog(@"failed Saving");
        }
    }
    return result;
}

-(NSMutableArray *)ReadingCoreData;
{

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Track"];
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc]initWithKey:@"atCreate" ascending:YES];

    
    fetchRequest.sortDescriptors = @[dateSort];
    
    NSError *readingError = nil;
    
    NSArray *tracks = [self.managedObjectContext executeFetchRequest:fetchRequest error:&readingError];
    
    NSMutableArray *alltracks = [[NSMutableArray alloc]initWithArray:tracks];
    return alltracks;
}

-(void)DeleteCoreDataWithTrack:(NSInteger )currentTrack;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Track"];
    NSError *DeleteError = nil;
    
    NSArray *track = [self.managedObjectContext executeFetchRequest:fetchRequest error:&DeleteError];
    
    if ([track count] > 0) {
        Track *newTrack = [track objectAtIndex:currentTrack];
        [self.managedObjectContext deleteObject:newTrack];
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]) {
            NSLog(@"Successfully deleted the last person in the array.");
        }
        else{
            NSLog(@"Failed to delete the last person in the array.");
        }
    }
    else{
        NSLog(@"count not find any person entities in the context");
    }
}

#pragma mark - Playlist 
-(BOOL)SavingCoreDataWithPLaylist:(NSString *)title andImage:(NSString *)image andIndex:(NSInteger )index andDate:(NSDate *)date;
{
    BOOL result = NO;
    
    if ([title length] == 0 ) {
        NSLog(@"tilte are Mandatory ");
        return NO;
    }
    
    NSMutableArray *Array = [self ReadingWithPlaylistCoreData];
    for (Playlist *playlist in Array) {
        if ([playlist.title isEqualToString:title]) {
            return NO;
        }
    }
    
    Playlist *playlist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:self.managedObjectContext];
    
    
    if (playlist == nil) {
        NSLog(@"Failed to create the new person");
        return NO;
    }
    else{
        
        playlist.title = title;
        playlist.artwork = image;
        playlist.index = [NSNumber numberWithInteger:index];
        playlist.createAt = date;

        NSError *savingError = nil;
        
        if ([self.managedObjectContext save:&savingError]) {
            return YES;
        }
        else{
            NSLog(@"failed Saving");
        }
    }
    return result;
}

-(NSMutableArray *)ReadingWithPlaylistCoreData;
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
    
    NSError *readingError = nil;
    
    NSArray *Playlist = [self.managedObjectContext executeFetchRequest:fetchRequest error:&readingError];
    
    NSMutableArray *allplaylist = [[NSMutableArray alloc]initWithArray:Playlist];
    return allplaylist;
}

-(void)DeleteCoreDataWithPlaylist:(NSInteger )currentTrack;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
    NSError *DeleteError = nil;
    
    NSArray *playlist = [self.managedObjectContext executeFetchRequest:fetchRequest error:&DeleteError];
    
    if ([playlist count] > 0) {
        Playlist *newplaylist = [playlist objectAtIndex:currentTrack];
        [self.managedObjectContext deleteObject:newplaylist];
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]) {
            NSLog(@"Successfully deleted the last person in the array.");
        }
        else{
            NSLog(@"Failed to delete the last person in the array.");
        }
    }
    else{
        NSLog(@"count not find any person entities in the context");
    }
}

#pragma mark - core data playlist tracks

-(BOOL)SavingCoreDataWithPlaylistTracks:(NSString *)title andImage:(NSData *)image andTrackid:(NSString *)trackid andVideoid:(NSString *)vieoid;
{
    BOOL result = NO;
    
    if ([title length] == 0 ) {
        NSLog(@"tilte are Mandatory ");
        return NO;
    }
    
    NSMutableArray *Array = [self ReadingWithPlaylistTracksCoreData];
    for (TrackPlaylist *trackplaylist in Array) {
        if ([trackplaylist.title isEqualToString:title] && [trackplaylist.dbTrackId isEqualToString:trackid]) {
            return NO;
        }
    }
    
    TrackPlaylist *trackplaylist = [NSEntityDescription insertNewObjectForEntityForName:@"TrackPlaylist" inManagedObjectContext:self.managedObjectContext];
    
    
    if (trackplaylist == nil) {
        NSLog(@"Failed to create the new person");
        return NO;
    }
    else{
        trackplaylist.title = title;
        trackplaylist.dbTrackId = trackid;
        trackplaylist.image = image;
        trackplaylist.videoid = vieoid;
        
        NSError *savingError = nil;
        
        if ([self.managedObjectContext save:&savingError]) {
            return YES;
        }
        else{
            NSLog(@"failed Saving");
        }
    }
    return result;
}

-(NSMutableArray *)ReadingWithPlaylistTracksCoreData;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"TrackPlaylist"];
    NSError *readingError = nil;
    NSArray *TrackPlaylist = [self.managedObjectContext executeFetchRequest:fetchRequest error:&readingError];
    NSMutableArray *allplaylist = [[NSMutableArray alloc]initWithArray:TrackPlaylist];
        NSLog(@"%lu",allplaylist.count);
    return allplaylist;

}

-(void)DeleteCoreDataWithPlaylistTracks:(NSInteger )currentTrack;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"TrackPlaylist"];
    NSError *DeleteError = nil;
    
    NSArray *trackPlaylist = [self.managedObjectContext executeFetchRequest:fetchRequest error:&DeleteError];
    
    if ([trackPlaylist count] > 0) {
        TrackPlaylist *newplaylist = [trackPlaylist objectAtIndex:currentTrack];
        [self.managedObjectContext deleteObject:newplaylist];
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]) {
            NSLog(@"Successfully deleted the last person in the array.");
        }
        else{
            NSLog(@"Failed to delete the last person in the array.");
        }
    }
    else{
        NSLog(@"count not find any person entities in the context");
    }
}



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.khaixt.core_data" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"core_data" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"core_data.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
