    //
//  BBQCombineCookies.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"

#define SAME_TYPE_UPGRADE @"Same"
#define DIFFERENT_TYPE_UPGRADE @"Different"

@interface BBQCombo : NSObject

@property (strong, nonatomic) BBQCookie *cookieA;
@property (strong, nonatomic) BBQCookie *cookieB;
@property (assign, nonatomic) NSString *upgradeType;

- (instancetype)initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB upgradeType:(NSString *)upgradeType;

@end
