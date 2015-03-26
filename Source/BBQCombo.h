//
//  BBQCombo.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookieOrder.h"


@class BBQCookie;

@interface BBQCombo : NSObject


@property (nonatomic) BOOL isLastCookieInChain;
@property (strong, nonatomic) BBQCookieOrder *cookieOrder;
@property (nonatomic) NSInteger numberOfTilesToDelayBy;



@end
