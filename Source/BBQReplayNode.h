//
//  BBQReplayNode.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol BBQReplayNodeDelegate <NSObject>

- (void)didPressReplay;

@end

@interface BBQReplayNode : CCNode

@property (weak, nonatomic) id <BBQReplayNodeDelegate> delegate;

@end
