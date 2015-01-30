//
//  BBQLevelCompleteNode.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol BBQLevelCompleteNodeDelegate <NSObject>

- (void)didPressNext;

@end

@interface BBQLevelCompleteNode : CCNode

@property (weak, nonatomic) id <BBQLevelCompleteNodeDelegate> delegate;

@property (assign, nonatomic) CCLayoutBox *greyStarsLayoutNode;
@property (assign, nonatomic) CCLabelTTF *yourScoreLabel;

@end
