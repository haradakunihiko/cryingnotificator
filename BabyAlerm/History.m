//
//  History.m
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "History.h"

@implementation History

-(id)init{
    if(self = [super init]){
        self.historyDetails = [NSMutableArray new];
    }
    return self;
}


-(void)addObject:(HistoryDetail *)detail{
    [self.historyDetails addObject:detail];
}

-(NSInteger)count{
    return [self.historyDetails count];
}

-(HistoryDetail *)objectAtIndex:(NSInteger)index{
    return [self.historyDetails objectAtIndex:index];
}

@end
