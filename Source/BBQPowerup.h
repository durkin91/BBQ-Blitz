//
//  BBQPowerup.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBQLevel;
@class BBQCookie;


#define HORIZONTAL @"Horizontal"
#define VERTICAL @"Vertical"

@interface BBQPowerup : NSObject

@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) NSInteger scorePerCookie;
@property (assign, nonatomic) NSInteger totalScore;
@property (strong, nonatomic) NSMutableArray *arraysOfDisappearingCookies;
@property (strong, nonatomic) NSString *direction;
@property (assign, nonatomic) BOOL isCurrentlyTemporary;
@property (assign, nonatomic) BOOL hasBeenActivated;
@property (assign, nonatomic) BOOL isReadyToDetonate;


- (instancetype)initWithType:(NSInteger)type direction:(NSString *)swipeDirection;
- (void)performPowerupWithLevel:(BBQLevel *)level cookie:(BBQCookie *)rootCookie;
- (void)removeDuplicateCookiesFromChainsCookies:(NSArray *)cookiesInChain;
- (void)scorePowerup;
- (void)addCookieOrders:(NSArray *)cookieOrders;

@end
