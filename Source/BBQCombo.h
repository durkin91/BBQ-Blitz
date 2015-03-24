//
//  BBQCombo.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBQCookie;

@interface BBQCombo : NSObject

@property (strong, nonatomic) BBQCookie *rootCookie;
@property (assign, nonatomic) BOOL isRootCookie;



@end
