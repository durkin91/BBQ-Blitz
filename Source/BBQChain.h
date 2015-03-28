//
//  BBQChain.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBQCookie;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface BBQChain : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *cookiesInChain;
@property (assign, nonatomic) ChainType chainType;

- (void)addCookie:(BBQCookie *)cookie;

@end
