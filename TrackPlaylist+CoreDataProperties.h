//
//  TrackPlaylist+CoreDataProperties.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/16/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TrackPlaylist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackPlaylist (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createAt;
@property (nullable, nonatomic, retain) NSString *dbTrackId;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *videoid;

@end

NS_ASSUME_NONNULL_END
