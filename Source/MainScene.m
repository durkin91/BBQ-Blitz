#import "MainScene.h"
#import "BBQCookie.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"
#import "BBQCombo.h"
#import "BBQMoveCookie.h"
#import "BBQCookieOrder.h"
#import "BBQCookieOrderView.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface MainScene ()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *tilesLayer;
@property (strong, nonatomic) BBQGameLogic *gameLogic;

@end

@implementation MainScene {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_movesLabel;
    CCSprite *_orderDisplayNode;
}

#pragma mark - Setting Up

-(void)didLoadFromCCB {
    
    //load the level, setup gameLogic and begin game
    self.gameLogic = [[BBQGameLogic alloc] init];
    
    //**** Add Gesture Recognizers ****//
    //Swipe Up
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [[UIApplication sharedApplication].delegate.window addGestureRecognizer:swipeUpGestureRecognizer];
    
    //Swipe Down
    UISwipeGestureRecognizer *swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[UIApplication sharedApplication].delegate.window addGestureRecognizer:swipeDownGestureRecognizer];
    
    //Swipe Left
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[UIApplication sharedApplication].delegate.window addGestureRecognizer:swipeLeftGestureRecognizer];
    
    //Swipe Right
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[UIApplication sharedApplication].delegate.window addGestureRecognizer:swipeRightGestureRecognizer];

    //Start the game
    NSSet *cookies = [self.gameLogic setupGame];
    [self addSpritesForOrders];
    _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    [self addSpritesForCookies:cookies];
    [self addTiles];
}

#pragma mark - Helper methods

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.gameLogic.level tileAtColumn:column row:row];
            if (tile != nil) {
                NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [tile spriteName]];
                CCSprite *tileSprite = [CCSprite spriteWithImageNamed:directory];
                tileSprite.position = [self pointForColumn:column row:row];
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
        BBQCookieOrderView *orderView = orderviews[i];
        NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [order.cookie spriteName]];
        CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
        sprite.anchorPoint = CGPointMake(0.0, 0.5);
        [orderView.cookieSprite addChild:sprite];
        orderView.quantityLabel.string = [NSString stringWithFormat:@"%ld", (long)order.quantity];
        
        order.view = orderView;

    }
}

- (void)addSpritesForCookies:(NSSet *)cookies {
    for (BBQCookie *cookie in cookies) {
        NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie spriteName]];
        CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
        sprite.position = [self pointForColumn:cookie.column row:cookie.row];
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

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
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
    const NSTimeInterval delay = 0.4;
    
    NSTimeInterval durationPlusDelay = duration + delay;
    CCActionDelay *delayAction = [CCActionDelay actionWithDuration:durationPlusDelay];
    
    ////**** COMBOS ****
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
            sprite.position = [self pointForColumn:combo.cookieB.column row:combo.cookieB.row];
            [self.cookiesLayer addChild:sprite];
            combo.cookieB.sprite = sprite;
        
        }];
        
        CCActionSequence *sequenceA = [CCActionSequence actions:moveA, removeA, changeSprite, [CCActionCallBlock actionWithBlock:completion], nil];
        [combo.cookieA.sprite runAction:sequenceA];
        
    }
    
    ////**** MOVEMENTS ****
    for (BBQMoveCookie *movement in animations[MOVEMENTS]) {
        CGPoint position = [self pointForColumn:movement.destinationColumn row:movement.destinationRow];
        CCActionMoveTo *moveAnimation = [CCActionMoveTo actionWithDuration:duration position:position];
        [movement.cookieA.sprite runAction:moveAnimation];
    }
    
    ////**** EAT COOKIES ****
    NSArray *cookieOrders = self.gameLogic.level.cookieOrders;
    for (BBQCookie *cookie in animations[EATEN_COOKIES]) {
        
        CCActionCallBlock *explodeBlock = [CCActionCallBlock actionWithBlock:^{
            CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"EatCookiesEffect"];
            explosion.autoRemoveOnFinish = TRUE;
            explosion.position = [self pointForColumn:cookie.column row:cookie.row];
            [cookie.sprite.parent addChild:explosion];
            [cookie.sprite removeFromParent];
            NSLog(@"Exploded this cookie: %@", cookie);

        }];
        
        CCActionSequence *sequence = [CCActionSequence actions:delayAction, explodeBlock, nil];
        [cookie.sprite runAction:sequence];
    }
    
    ////**** UPDATE SCORE AND MOVES ****
    CCActionCallBlock *updateScoreBlock = [CCActionCallBlock actionWithBlock:^{
        _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.currentScore];
        _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    }];
    CCActionSequence *updateScoreSequence = [CCActionSequence actions:delayAction, updateScoreBlock , nil];
    [self.cookiesLayer runAction:updateScoreSequence];
    
    ////**** REGENERATE NEW COOKIES ****
    
    CCActionCallBlock *newCookies = [CCActionCallBlock actionWithBlock:^{
        NSSet *newCookiesSet = [self.gameLogic.level createCookiesInBlankTiles];
        [self addSpritesForCookies:newCookiesSet];
    }];
    
    CCActionSequence *newCookieSequence = [CCActionSequence actions:delayAction, newCookies, nil];
    [self.cookiesLayer runAction:newCookieSequence];

}


@end
