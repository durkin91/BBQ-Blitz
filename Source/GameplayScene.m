#import "GameplayScene.h"
#import "BBQCookie.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"
#import "BBQCombo.h"
#import "BBQMoveCookie.h"
#import "BBQCookieOrder.h"
#import "BBQCookieOrderNode.h"
#import "BBQRanOutOfMovesNode.h"
#import "BBQLevelCompleteNode.h"
#import "BBQAnimations.h"
#import "BBQMenu.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameplayScene ()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *tilesLayer;
@property (strong, nonatomic) BBQGameLogic *gameLogic;

@end

@implementation GameplayScene {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_movesLabel;
    CCSprite *_orderDisplayNode;
    CCSprite *_scoreboardBackground;
    BBQMenu *_menuNode;
    NSMutableArray *_gestureRecognizers;
}

#pragma mark - Setting Up

-(void)didLoadFromCCB {
    
    //load the level, setup gameLogic and begin game
    self.gameLogic = [[BBQGameLogic alloc] init];
    
    ////****GESTURE RECOGNIZERS****
    _gestureRecognizers = [@[] mutableCopy];
    
    //Swipe Up
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [_gestureRecognizers addObject:swipeUpGestureRecognizer];
    
    //Swipe Down
    UISwipeGestureRecognizer *swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [_gestureRecognizers addObject:swipeDownGestureRecognizer];
    
    //Swipe Left
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_gestureRecognizers addObject:swipeLeftGestureRecognizer];
    
    //Swipe Right
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_gestureRecognizers addObject:swipeRightGestureRecognizer];
    
    [self addGestureRecognizers];


    //Start the game
    NSSet *cookies = [self.gameLogic setupGame];
    [self addSpritesForOrders];
    _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    [self addSpritesForCookies:cookies];
    [self addTiles];
}

#pragma mark - Helper methods

- (void)addGestureRecognizers {
    for (UISwipeGestureRecognizer *gesture in _gestureRecognizers) {
        [[UIApplication sharedApplication].delegate.window addGestureRecognizer:gesture];
    }
}

- (void)removeGestureRecognizers {
    for (UISwipeGestureRecognizer *gesture in _gestureRecognizers) {
        [[UIApplication sharedApplication].delegate.window removeGestureRecognizer:gesture];
    }
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.gameLogic.level tileAtColumn:column row:row];
            if (tile != nil) {
                NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [tile spriteName]];
                CCSprite *tileSprite = [CCSprite spriteWithImageNamed:directory];
                tileSprite.position = [GameplayScene pointForColumn:column row:row];
                [self.tilesLayer addChild:tileSprite];
                tile.sprite = tileSprite;
            }
        }
    }
}

//The way I have changed the sprite is a hack for now. Would be much better to just figure out how to change the texture
- (void)addSpritesForOrders {
    NSArray *orderviews = [_orderDisplayNode children];
    NSArray *orderObjects = self.gameLogic.level.cookieOrders;
    for (int i = 0; i < [orderObjects count]; i++) {
        BBQCookieOrder *order = orderObjects[i];
        BBQCookieOrderNode *orderView = orderviews[i];
        NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [order.cookie spriteName]];
        CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
        sprite.anchorPoint = CGPointMake(0.0, 0.5);
        [orderView.cookieSprite addChild:sprite];
        orderView.quantityLabel.string = [NSString stringWithFormat:@"%ld", (long)order.quantity];
        
        order.view = orderView;
        order.sprite = sprite;

    }
}

- (void)addSpritesForCookies:(NSSet *)cookies {
    for (BBQCookie *cookie in cookies) {
        NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie spriteName]];
        CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
        sprite.position = [GameplayScene pointForColumn:cookie.column row:cookie.row];
        [self.cookiesLayer addChild:sprite];
        cookie.sprite = sprite;
        
        //animate them
        self.userInteractionEnabled = NO;
        CCActionScaleTo *startSmall = [CCActionScaleTo actionWithDuration:0.05 scale:0.1];
        CCActionScaleTo *scaleAction = [CCActionScaleTo actionWithDuration:0.4 scale:1.0];
        CCActionCallBlock *block = [CCActionCallBlock actionWithBlock:^{
            self.userInteractionEnabled = YES;
        }];
        CCActionSequence *sequence = [CCActionSequence actions:startSmall, scaleAction, block, nil];
        [cookie.sprite runAction:sequence];
        
    }
}

+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight / 2);
}

- (void)removeSpritesFromSharkTiles:(NSArray *)cookies {
    for (BBQCookie *cookie in cookies) {
        [cookie.sprite runAction:[CCActionRemove action]];
    }

}

- (void)swipeDirection:(NSString *)direction {
    NSLog(@"Swipe %@", direction);
    self.userInteractionEnabled = NO;
    NSDictionary *animations = [self.gameLogic swipe:direction];
    [self animateSwipe:animations completion:^{
        self.userInteractionEnabled = YES;
        
        //check whether the player has finished the level
        if ([self.gameLogic isLevelComplete]) {
            [self removeGestureRecognizers];
            [_menuNode displayMenuFor:LEVEL_COMPLETE gameLogic:self.gameLogic];

        }
        
        //check whether player has run out of moves
        else if (![self.gameLogic areThereMovesLeft]) {
            [self removeGestureRecognizers];
            [_menuNode displayMenuFor:NO_MORE_MOVES gameLogic:self.gameLogic];
        }
    }];
    
}


#pragma mark - Gesture Recognizers

- (void)handleSwipeUpFrom:(UIGestureRecognizer *)recognizer {
    [self swipeDirection:@"Up"];
}

- (void)handleSwipeDownFrom:(UIGestureRecognizer *)recognizer {
    [self swipeDirection:@"Down"];
}

- (void)handleSwipeLeftFrom:(UIGestureRecognizer *)recognizer {
    [self swipeDirection:@"Left"];
}

- (void)handleSwipeRightFrom:(UIGestureRecognizer *)recognizer {
    [self swipeDirection:@"Right"];
}

#pragma mark - Animations

- (void)animateSwipe:(NSDictionary *)animations completion:(dispatch_block_t)completion {
    
    const NSTimeInterval duration = 0.2;
    const NSTimeInterval delay = 0.5;
    
    CCActionDelay *delayAction = [CCActionDelay actionWithDuration:delay];
    
    ////**** COMBOS ACTION BLOCK ****
    
    CCActionCallBlock *performCombosAndMoveCookies = [CCActionCallBlock actionWithBlock:^{
        
        ////COMBOS
        for (BBQCombo *combo in animations[COMBOS]) {
            
            //Put cookie A on top and move cookie A to cookie B, then remove cookie A
            combo.cookieA.sprite.zOrder = 100;
            combo.cookieB.sprite.zOrder = 90;
            
            CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration:duration position:combo.cookieB.sprite.position];
            CCActionRemove *removeA = [CCActionRemove action];
            
            CCActionCallBlock *changeSprite = [CCActionCallBlock actionWithBlock:^{
                
                [combo.cookieB.sprite removeFromParent];
                
                NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [combo.cookieB spriteName]];
                CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
                sprite.position = [GameplayScene pointForColumn:combo.cookieB.column row:combo.cookieB.row];
                [self.cookiesLayer addChild:sprite];
                combo.cookieB.sprite = sprite;
                
            }];
            
            CCActionSequence *sequenceA = [CCActionSequence actions:moveA, removeA, changeSprite, nil];
            [combo.cookieA.sprite runAction:sequenceA];
            
        }
        
        ////MOVE COOKIES
        for (BBQMoveCookie *movement in animations[MOVEMENTS]) {
            CGPoint position = [GameplayScene pointForColumn:movement.destinationColumn row:movement.destinationRow];
            CCActionMoveTo *moveAnimation = [CCActionMoveTo actionWithDuration:duration position:position];
            [movement.cookieA.sprite runAction:moveAnimation];
        }
        
    }];
    
    
    ////**** EAT COOKIES ****
    CCActionCallBlock *eatCookies = [CCActionCallBlock actionWithBlock:^{
        NSArray *cookieOrders = self.gameLogic.level.cookieOrders;
        for (BBQCookie *cookie in animations[EATEN_COOKIES]) {
            
            //Particle System
            CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"EatCookiesEffect"];
            explosion.autoRemoveOnFinish = TRUE;
            explosion.position = [GameplayScene pointForColumn:cookie.column row:cookie.row];
            [cookie.sprite.parent addChild:explosion];
            
            //Score Label
            NSInteger scoreForCookie = [self.gameLogic scoreForCookie:cookie];
            NSString *scoreString = [NSString stringWithFormat:@"%ld", (long)scoreForCookie];
            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"GillSans-BoldItalic" fontSize:16.0];
            scoreLabel.position = cookie.sprite.position;
            scoreLabel.outlineColor = [CCColor blackColor];
            scoreLabel.outlineWidth = 1.0;
            scoreLabel.zOrder = 300;
            [_cookiesLayer addChild:scoreLabel];
            [BBQAnimations animateScoreLabel:scoreLabel];
            
            [cookie.sprite removeFromParent];
            
            //check if the cookie is a cookie from the order
            BOOL didFind = NO;
            for (BBQCookieOrder *order in cookieOrders) {
                if (cookie.cookieType == order.cookie.cookieType) {
                    
                    //create the bezier action
                    //                    ccBezierConfig curve;
                    //                    curve.endPosition = [orderSprite convertToWorldSpace:CGPointZero];
                    //
                    //                    CCActionBezierTo *bezierMove = [CCActionBezierTo actionWithDuration:3.0 bezier:curve];
                    
                    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.3 scale:1.4];
                    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.3 scale:1.0];
                    //CCActionRemove *removeSprite = [CCActionRemove action];
                    
                    CCActionSequence *orderActionSequence = [CCActionSequence actions:scaleUp, scaleDown, nil];
                    
                    //check whether order is complete
                    if ([order orderIsComplete]) {
                        order.view.tickSprite.visible = YES;
                        order.view.quantityLabel.visible = NO;
                        [order.view.tickSprite runAction:orderActionSequence];
                    }
                    else {
                        order.view.quantityLabel.string = [NSString stringWithFormat:@"%ld", (long)order.quantityLeft];
                        [order.view.quantityLabel runAction:orderActionSequence];
                    }
                    
                    didFind = YES;
                    break;
                }
            }
            
            NSLog(@"Exploded this cookie: %@", cookie);
            
        }
        
    }];
    
    ////**** UPDATE SCORE & MOVES ****
    CCActionCallBlock *updateScoreBlock = [CCActionCallBlock actionWithBlock:^{
        _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.currentScore];
        _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    }];
    
    ////**** REGENERATE NEW COOKIES ****
    CCActionCallBlock *newCookies = [CCActionCallBlock actionWithBlock:^{
        NSSet *newCookiesSet = [self.gameLogic.level createCookiesInBlankTiles];
        [self addSpritesForCookies:newCookiesSet];
    }];
    
    ////**** FINAL SEQUENCE ****
    CCActionSequence *finalSequence = [CCActionSequence actions:performCombosAndMoveCookies, delayAction, eatCookies, updateScoreBlock, newCookies, [CCActionCallBlock actionWithBlock:completion], nil];
    [self.cookiesLayer runAction:finalSequence];
    
}


@end
