//
//  BBQChain.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQChain.h"
#import "BBQLevel.h"

@implementation BBQChain

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        if (column >= 0 && column < NumColumns) {
            self.activeColumn = column;
        }
        
        if (row >= 0 && row < NumRows) {
            self.activeRow = row;
        }
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Cookies involved: %@", self.cookiesInChain];
}

@end
