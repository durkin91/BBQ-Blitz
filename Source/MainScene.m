#import "MainScene.h"
#import "BBQCookie.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"
#import "BBQCombo.h"
#import "BBQMoveCookie.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface MainScene ()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *tilesLayer;
@property (strong, nonatomic) BBQGameLogic *gameLogic;

@end

@implementation MainScene

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

- (void)removeCookiesFromSharkTiles {
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.gameLogic.level tileAtColumn:column row:row];
            if (tile.tileType == 2) {
                BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:column row:row];
                [self.gameLogic.level replaceCookieAtColumn:column row:row withCookie:nil];
                [cookie.sprite runAction:[CCActionRemove action]];
            }
        }
    }

}

- (void)swipeDirection:(NSString *)direction {
    NSLog(@"Swipe %@", direction);
    self.userInteractionEnabled = NO;
    NSDictionary *animations = [self.gameLogic swipe:direction];
    [self animateSwipe:animations completion:^{
        self.userInteractionEnabled = YES;
    }];
    
    //[self removeCookiesFromSharkTiles];
    
    NSSet *newCookies = [self.gameLogic.level createCookiesInBlankTiles];
    [self addSpritesForCookies:newCookies];
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
    
    for (BBQCombo *combo in animations[COMBOS]) {
        
        //Put cookie A on top and move cookie A to cookie B, then remove cookie A
        combo.cookieA.sprite.zOrder = 100;
        combo.cookieB.sprite.zOrder = 90;
        
        CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration:duration position:combo.cookieB.sprite.position];
        CCActionEaseIn *ease = [CCActionEaseIn actionWithAction:moveA];
        CCActionRemove *removeA = [CCActionRemove action];
        
        //Change sprite texture for cookie B
//        NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [combo.cookieB spriteName]];
//        CCSprite *upgradedSprite = [CCSprite spriteWithImageNamed:directory];
//        upgradedSprite.visible = NO;
//        [combo.cookieB.sprite addChild:upgradedSprite];
//        combo.cookieB.upgradedSprite = upgradedSprite;
//        
//        CCActionHide *hideRegularSprite = [CCActionHide action];
//        
//        CCActionShow *showUpgradedSprite = [CCActionShow action];
        //CCActionScaleTo *scaleUpgradedSprite = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
        //CCActionScaleTo *scaleBackUpgradedSprite = [CCActionScaleTo actionWithDuration:0.05 scale:1];
        //CCActionSequence *sequenceB = [CCActionSequence actions:showUpgradedSprite, scaleUpgradedSprite, scaleBackUpgradedSprite, nil];
        
//        CCActionCallBlock *runSequenceB = [CCActionCallBlock actionWithBlock:^{
//            [combo.cookieB.sprite runAction:hideRegularSprite];
//            NSLog(@"Hid regular sprite: %@", combo.cookieB.sprite);
//            [combo.cookieB.upgradedSprite runAction:showUpgradedSprite];
//        }];
        
        CCActionCallBlock *changeSprite = [CCActionCallBlock actionWithBlock:^{
            NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [combo.cookieB spriteName]];
            CCTexture *texture = [CCTexture textureWithFile:directory];
            combo.cookieB.sprite.texture = texture;
        }];
        
        CCActionSequence *sequenceA = [CCActionSequence actions:ease, removeA, changeSprite, [CCActionCallBlock actionWithBlock:completion], nil];
        [combo.cookieA.sprite runAction:sequenceA];
        
    }
    
    for (BBQMoveCookie *movement in animations[MOVEMENTS]) {
        CCActionMoveTo *moveAnimation = [CCActionMoveTo actionWithDuration:duration position:movement.destination];
        [movement.cookieA.sprite runAction:moveAnimation];
    }
}


@end
