//
//  BBQPowerup.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"

@class BBQLevel;


#define HORIZONTAL @"Horizontal"
#define VERTICAL @"Vertical"

@interface BBQPowerup : NSObject

@property (strong, nonatomic) BBQCookie *rootCookie;
@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) NSMutableArray *disappearingCookies;
@property (strong, nonatomic) NSString *direction;

- (instancetype)initWithCookie:(BBQCookie *)cookie type:(NSInteger)type direction:(NSString *)swipeDirection;
- (void)performPowerupWithLevel:(BBQLevel *)level;


@end
