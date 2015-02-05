//
//  BBQComboModel.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 2/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"

static const NSInteger startingScoreForCombo = 400;

@interface BBQComboModel : NSObject

@property (assign, nonatomic) BBQCookie *cookieB;
@property (assign, nonatomic) NSInteger numberOfCookiesInCombo;
@property (assign, nonatomic) NSInteger score;

- (instancetype)initWithCookieB:(BBQCookie *)cookieB numberOfCookiesInCombo:(NSInteger)numberOfCookiesInCombo;

@end
