//
//  BBQCookieOrder.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"
#import "BBQCookieOrderNode.h"

@interface BBQCookieOrder : NSObject

@property (strong, nonatomic) BBQCookie *cookie;
@property (assign, nonatomic) NSInteger quantity;
@property (assign, nonatomic) NSInteger quantityLeft;
@property (strong, nonatomic) BBQCookieOrderNode *orderNode;

-(instancetype)initWithCookieType:(NSInteger)cookieType startingAmount:(NSInteger)startingAmount;

@end
