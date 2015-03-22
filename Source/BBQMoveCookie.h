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
@property (assign, nonatomic) NSInteger destinationColumn;
@property (assign, nonatomic) NSInteger destinationRow;
@property (assign, nonatomic) BOOL removeAfterMovement;

-(instancetype)initWithCookieA:(BBQCookie *)cookieA destinationColumn:(NSInteger)column destinationRow:(NSInteger)row;

@end
