//
//  WorldsScene.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCScene.h"
#import "BBQWorldView.h"

@interface WorldsScene : CCScene

@property (assign, nonatomic) NSInteger currentLevel;
@property (assign, nonatomic) BBQWorldView *worldNode;


@end
