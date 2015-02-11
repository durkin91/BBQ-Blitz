#import "GameplayScene.h"
#import "BBQCookie.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"
#import "BBQComboAnimation.h"
#import "BBQMoveCookie.h"
#import "BBQCookieOrderNode.h"
#import "BBQRanOutOfMovesNode.h"
#import "BBQLevelCompleteNode.h"
#import "BBQAnimations.h"
#import "WorldsScene.h"
#import "BBQCookieNode.h"
#import "BBQLaserTileNode.h"


static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameplayScene ()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *tilesLayer;
@property (strong, nonatomic) CCNode *overlayTilesLayer;
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
    _menuNode.delegate = self;

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

- (void)setupGameWithLevel:(NSInteger)level {
    
    self.level = level;
    self.gameLogic = [[BBQGameLogic alloc] init];
    _menuNode.gameLogic = self.gameLogic;
    NSSet *cookies = [self.gameLogic setupGameLogicWithLevel:level];
    _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.currentScore];
    [self addSpritesForCookies:cookies];
    [self addTiles];
    [_menuNode displayMenuFor:START_LEVEL];
}

- (void)replayGame {
    [self clearOutAllCookiesAndTiles];
    [self setupGameWithLevel:self.level];
}

- (void)startNextLevel {
    [self clearOutAllCookiesAndTiles];
    [self setupGameWithLevel:self.level + 1];
}

- (void)progressToNextMaxLevel {
    WorldsScene *worlds = (WorldsScene *)[CCBReader load:@"Worlds"];
    CCScene *scene = [[CCScene alloc] init];
    [scene addChild:worlds];
    [[CCDirector sharedDirector] replaceScene:scene];
    [worlds.worldNode progressToNextLevel];
}

- (void)clearOutAllCookiesAndTiles {
    //Clear out all of the existing cookies and tiles
    NSMutableArray *cookies = [_cookiesLayer.children mutableCopy];
    for (CCSprite *sprite in cookies) {
        [sprite removeFromParent];
    }
    
    NSMutableArray *tiles = [_tilesLayer.children mutableCopy];
    for (CCSprite *tile in tiles) {
        [tile removeFromParent];
    }
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.gameLogic.level tileAtColumn:column row:row];
            if (tile.tileType > 0) {
                [self createSpriteForTile:tile column:column row:row];
            }
        }
    }
}

- (void)createSpriteForTile:(BBQTile *)tile column:(NSInteger)column row:(NSInteger)row {
    
    NSString *directory = [NSString stringWithFormat:@"Tiles/%@", [tile spriteName]];
    CCNode *tileSprite = [CCBReader load:directory];
    tileSprite.position = [GameplayScene pointForColumn:column row:row];
    tileSprite.zOrder = 10;
    //tileSprite.anchorPoint = CGPointMake(0.5, 0.5);
    [self.tilesLayer addChild:tileSprite];
    tile.sprite = tileSprite;
    
    if (tile.tileType == 3) {
        BBQLaserTileNode *laserTileOverlay = (BBQLaserTileNode *)[CCBReader load:@"LaserTile"];
        laserTileOverlay.position = [GameplayScene pointForColumn:column row:row];
        [self.overlayTilesLayer addChild:laserTileOverlay];
        tile.overlayTile = laserTileOverlay;
    }

}

- (BBQCookieNode *)createCookieNodeForCookie:(BBQCookie *)cookie column:(NSInteger)column row:(NSInteger)row {
    BBQCookieNode *cookieNode = (BBQCookieNode *)[CCBReader load:@"Cookie"];
    NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie spriteName]];
    CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
    [cookieNode.cookieSprite addChild:sprite];
    cookieNode.position = [GameplayScene pointForColumn:column row:row];
    [self.cookiesLayer addChild:cookieNode];
    return cookieNode;
}

- (void)spriteForCookie:(BBQCookie *)cookie {
    BBQCookieNode *cookieNode = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row];
    cookie.sprite = cookieNode;
    
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

- (void)addSpritesForCookies:(NSSet *)cookies {
    for (BBQCookie *cookie in cookies) {
        [self spriteForCookie:cookie];
    }
}

+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight / 2);
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
            [_menuNode displayMenuFor:LEVEL_COMPLETE];
            
        }
        
        //check whether player has run out of moves
        else if (![self.gameLogic areThereMovesLeft]) {
            [self removeGestureRecognizers];
            [_menuNode displayMenuFor:NO_MORE_MOVES];
        }

    }];
    
}

#pragma mark - Animate Swipe

- (void)animateSwipe:(NSDictionary *)animations completion:(dispatch_block_t)completion {
    
    const NSTimeInterval duration = 0.4;
    
    ////**** COMBOS ACTION BLOCK ****
    
    CCActionCallBlock *performCombosAndMoveCookies = [CCActionCallBlock actionWithBlock:^{
        
        ////COMBOS
        for (BBQComboAnimation *combo in animations[COMBOS]) {
            
            //Put cookie A on top and move cookie A to cookie B, then remove cookie A
            combo.cookieA.sprite.zOrder = 100;
            combo.cookieB.sprite.zOrder = 90;
            
            CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration:duration position:[GameplayScene pointForColumn:combo.destinationColumn row:combo.destinationRow]];
            CCActionRemove *removeA = [CCActionRemove action];
            
            CCActionCallBlock *updateCountCircle = [CCActionCallBlock actionWithBlock:^{
                
                if (combo.cookieB.isFinalCookie) {
                    combo.cookieB.sprite.countCircle.visible = NO;
                    combo.cookieB.sprite.tickSprite.visible = YES;
                }
                
                else {
                    //combo.cookieB.sprite.countCircle.visible = YES;
                    combo.cookieB.sprite.countLabel.string = [NSString stringWithFormat:@"%ld", (long)combo.cookieB.count];
                }
                
                //scale up and down
                CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
                CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.1 scale:1.0];
                CCActionSequence *scaleSequence = [CCActionSequence actions:scaleUp, scaleDown, nil];
                [combo.cookieB.sprite runAction:scaleSequence];
                
                //Display score label
                if (combo.score > 0) {
                    NSString *scoreString = [NSString stringWithFormat:@"%ld", (long)combo.score];
                    CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"GillSans-BoldItalic" fontSize:12.0];
                    scoreLabel.position = [GameplayScene pointForColumn:combo.destinationColumn row:combo.destinationRow];
                    scoreLabel.outlineColor = [CCColor blackColor];
                    scoreLabel.outlineWidth = 1.0;
                    scoreLabel.zOrder = 300;
                    [_cookiesLayer addChild:scoreLabel];
                    [BBQAnimations animateScoreLabel:scoreLabel];
                }
                
                //If it is a static tile, break the tile
                if (combo.didBreakOutOfStaticTile == YES) {
                    BBQTile *tileB = [self.gameLogic.level tileAtColumn:combo.cookieB.column row:combo.cookieB.row];
                    
                    if (tileB.overlayTile) {
                        if (tileB.staticTileCountdown > 0) {
                            tileB.overlayTile.countLabel.string = [NSString stringWithFormat:@"%ld", (long)tileB.staticTileCountdown];
                        }
                        
                        else if (tileB.staticTileCountdown <= 0) {
                            [tileB.overlayTile removeFromParent];
                            tileB.overlayTile = nil;
                        }
                    }
                    
                    else if (tileB.tileType == 1) {
                        [tileB.sprite removeFromParent];
                        CCNode *newSprite = [CCBReader load:@"Tiles/RegularTile"];
                        newSprite.position = [GameplayScene pointForColumn:combo.cookieB.column row:combo.cookieB.row];
                        [_tilesLayer addChild:newSprite];
                        tileB.sprite = newSprite;
                    }
                }
                
            }];
            
            CCActionSequence *sequenceA = [CCActionSequence actions:moveA, removeA, updateCountCircle, nil];
            [combo.cookieA.sprite runAction:sequenceA];
            
        }
        
        ////MOVE COOKIES
        for (BBQMoveCookie *movement in animations[MOVEMENTS]) {
            CGPoint position = [GameplayScene pointForColumn:movement.destinationColumn row:movement.destinationRow];
            CCActionMoveTo *moveAnimation = [CCActionMoveTo actionWithDuration:duration position:position];
            [movement.cookieA.sprite runAction:moveAnimation];
        }
        
    }];
    
    
    //**** UPDATE SCORE & MOVES ****
    CCActionCallBlock *updateScoreBlock = [CCActionCallBlock actionWithBlock:^{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        _scoreLabel.string = [formatter stringFromNumber:@(self.gameLogic.currentScore)];
        _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
        NSLog(@"Moves left label: %@", _movesLabel.string);
    }];
    
    //**** CREATE SPRITES FOR NEW GOOSE EGG COOKIES ****
    CCActionCallBlock *newCookieSprites = [CCActionCallBlock actionWithBlock:^{
        NSArray *newCookies = animations[GOLDEN_GOOSE_COOKIES];
        for (BBQCookie *cookie in newCookies) {
            [self spriteForCookie:cookie];
        }
    }];
    
    ////**** FINAL SEQUENCE ****
    CCActionSequence *finalSequence = [CCActionSequence actions:performCombosAndMoveCookies, updateScoreBlock, newCookieSprites, [CCActionCallBlock actionWithBlock:completion], nil];
    [_cookiesLayer runAction:finalSequence];
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


#pragma mark - Popover methods

- (void)didPlay {
    [_menuNode dismissMenu:START_LEVEL withBackgroundFadeOut:YES];
}


@end
