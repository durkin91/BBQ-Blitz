//
//  BBQCombineCookies.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBQCookie.h"

@interface BBQCombineCookies : NSObject

@property (strong, nonatomic) BBQCookie *cookieA;
@property (strong, nonatomic) BBQCookie *cookieB;

- (instancetype)initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB;

@end
