//
//  BBQChain.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookieOrder.h"

@class BBQCookie;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface BBQChain : NSObject

@property (strong, nonatomic) NSMutableArray *cookiesInChain;
@property (assign, nonatomic) ChainType chainType;
@property (assign, nonatomic) NSUInteger score;
@property (strong, nonatomic) BBQCookieOrder *cookieOrder;
@property (assign, nonatomic) NSInteger numberOfCookiesForOrder;
@property (assign, nonatomic) NSInteger cookieType;
@property (assign, nonatomic) NSInteger scorePerCookie;


- (void)addCookie:(BBQCookie *)cookie;
- (BOOL)containsCookie:(BBQCookie *)cookie;
- (BOOL)isACompleteChain;
@end
