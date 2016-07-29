//
//  Track+CoreDataProperties.h
//  Project_Techkid_Gen2
//
//  Created by Khai on 4/16/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

@interface Track (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *atCreate;
@property (nullable, nonatomic, retain) NSData *atwork;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *videoid;
@property (nullable, nonatomic, retain) NSNumber *viewcount;

@end

NS_ASSUME_NONNULL_END
