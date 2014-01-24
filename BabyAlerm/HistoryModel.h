//
//  HistoryModel.h
//  BabyAlerm
//
//  Created by harada on 2014/01/23.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VolumeModel;

@interface HistoryModel : NSManagedObject

@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSOrderedSet *volumes;
@end

@interface HistoryModel (CoreDataGeneratedAccessors)

- (void)insertObject:(VolumeModel *)value inVolumesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromVolumesAtIndex:(NSUInteger)idx;
- (void)insertVolumes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeVolumesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInVolumesAtIndex:(NSUInteger)idx withObject:(VolumeModel *)value;
- (void)replaceVolumesAtIndexes:(NSIndexSet *)indexes withVolumes:(NSArray *)values;
- (void)addVolumesObject:(VolumeModel *)value;
- (void)removeVolumesObject:(VolumeModel *)value;
- (void)addVolumes:(NSOrderedSet *)values;
- (void)removeVolumes:(NSOrderedSet *)values;
@end
