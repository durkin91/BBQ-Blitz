//
//  BBQChain.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBQChain : NSObject

@property (strong, nonatomic) NSMutableArray *cookiesInChain;
@property (assign, nonatomic) NSInteger activeRow;
@property (assign, nonatomic) NSInteger activeColumn;

@end
