//
//  BBQMovement.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"
#import "BBQCookieNode.h"

@interface BBQMovement : NSObject

@property (nonatomic) NSInteger destinationColumn;
@property (nonatomic) NSInteger destinationRow;
@property (nonatomic) BOOL isExitingCookie;
@property (nonatomic) BOOL isEnteringCookie;
@property (strong, nonatomic) BBQCookie *cookie;
@property (strong, nonatomic) BBQCookieNode *sprite;

- (instancetype)initWithCookie:(BBQCookie *)cookie destinationColumn:(NSInteger)destinationColumn destinationRow:(NSInteger)destinationRow;

@end
