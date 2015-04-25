//
//  BBQDiagonalMovement.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBQDiagonalMovement : NSObject

@property (assign, nonatomic) NSInteger destinationColumn;
@property (assign, nonatomic) NSInteger destinationRow;
@property (assign, nonatomic) NSInteger startColumn;
@property (assign, nonatomic) NSInteger startRow;

- (instancetype)initWithDestinationColumn:(NSInteger)column row:(NSInteger)row;

@end
