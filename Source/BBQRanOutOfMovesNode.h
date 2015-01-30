//
//  BBQRanOutOfMovesNode.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol BBQRanOutOfMovesNodeDelegate <NSObject>

- (void)didPressEnd;

@end

@interface BBQRanOutOfMovesNode : CCNode

@property (weak, nonatomic) id <BBQRanOutOfMovesNodeDelegate> delegate;

@end
