//
//  BBQStartLevelNode.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol BBQStartLevelNodeDelegate <NSObject>

- (void)didPlay;

@end

@interface BBQStartLevelNode : CCNode

@property (weak, nonatomic) id <BBQStartLevelNodeDelegate> delegate;

@property (assign, nonatomic) CCLabelTTF *levelLabel;
@property (assign, nonatomic) CCLayoutBox *greyStarsLayoutNode;

@end
