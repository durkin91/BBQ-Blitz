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
@property (assign, nonatomic) NSInteger totalScore;
@property (strong, nonatomic) NSMutableArray *arraysOfDisappearingCookies;
@property (strong, nonatomic) NSMutableArray *upgradedMuliticookiePowerupCookiesThatNeedreplacing;
@property (strong, nonatomic) NSString *direction;
@property (assign, nonatomic) BOOL isReadyToDetonate;


- (instancetype)initWithType:(NSInteger)type direction:(NSString *)swipeDirection;
- (NSString *)powerupName;
- (void)performPowerupWithLevel:(BBQLevel *)level cookie:(BBQCookie *)rootCookie cookieTypeToCollect:(BBQCookie *)cookieTypeToCollect;
- (void)scorePowerup;
- (void)addCookieOrders:(NSArray *)cookieOrders;
- (BOOL)canOnlyJoinWithCookieNextToIt;
- (NSMutableArray *)returnArrayOfCookiesRandomlyAssignedToArrays:(NSMutableArray *)oldArray;
- (void)removeUndetonatedPowerupFromArraysOfPowerupsToDetonate:(BBQCookie *)cookie;
- (void)addNewlyCreatedPowerupToArraysOfPowerupsToDetonate:(BBQCookie *)cookie;

- (BOOL)isAPivotPad;
- (BOOL)isAMultiCookie;
- (BOOL)isATypeSixPowerup;
- (BOOL)isACrissCross;
- (BOOL)isABox;
- (BOOL)isATwoSixesCombo;
- (BOOL)isATwoBoxCombo;
- (BOOL)isATwoCrissCrossCombo;
- (BOOL)isATypeSixWithCrissCrossCombo;
- (BOOL)isaTypeSixWithBoxCombo;
- (BOOL)isABoxAndCrissCrossCombo;
- (BOOL)canBeDetonatedWithoutAChain;


@end
