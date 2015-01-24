//
//  BBQCookieOrder.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"
#import "BBQCookieOrderNode.h"

@interface BBQCookieOrder : NSObject

@property (strong, nonatomic) BBQCookie *cookie;
@property (assign, nonatomic) NSInteger quantity;
@property (assign, nonatomic) NSInteger quantityLeft;
@property (assign, nonatomic) BBQCookieOrderNode *view;
@property (assign, nonatomic) CCSprite *sprite;


-(instancetype)initWithCookieType:(NSInteger)cookieType startingAmount:(NSInteger)startingAmount;
-(BOOL)orderIsComplete;

@end
