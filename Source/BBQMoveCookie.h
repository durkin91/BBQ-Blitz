//
//  BBQMoveCookie.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"

@interface BBQMoveCookie : NSObject

@property (strong, nonatomic) BBQCookie *cookieA;
@property (nonatomic) CGPoint destination;

-(instancetype)initWithCookieA:(BBQCookie *)cookieA destination:(CGPoint)position;

@end
