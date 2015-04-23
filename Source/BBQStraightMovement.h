//
//  BBQStraightMovement.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBQStraightMovement : NSObject

@property (assign, nonatomic) NSInteger destinationColumn;
@property (assign, nonatomic) NSInteger destinationRow;
@property (assign, nonatomic) BOOL isNewCookie;
@property (assign, nonatomic) NSInteger numberOfTilesToPauseForNewCookie;

- (instancetype)initWithDestinationColumn:(NSInteger)column row:(NSInteger)row;

@end
