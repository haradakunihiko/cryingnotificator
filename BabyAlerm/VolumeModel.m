//
//  VolumeModel.m
//  BabyAlerm
//
//  Created by harada on 2014/01/28.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "VolumeModel.h"
#import "HistoryModel.h"


@implementation VolumeModel

@dynamic average;
@dynamic enabled;
@dynamic isOverThreashold;
@dynamic peak;
@dynamic time;
@dynamic history;

-(NSDictionary *)toDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *array =[[[self entity] attributesByName] allKeys];
    [array enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSObject *value =[self valueForKey:key];
        if(value != nil && ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]])){
            [dict setObject:value forKey:key];
        }
    }];
    return dict;
}

@end
