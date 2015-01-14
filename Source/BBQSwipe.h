//
//  BBQSwipe.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQLevel.h"

@interface BBQSwipe : NSObject

- (instancetype)initWithDirection:(NSString *)swipeDirection forLevel:(BBQLevel *)level;

@end
