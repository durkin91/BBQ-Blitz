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
#import "BBQLaserTileNode.h"
#import "BBQCookieOrder.h"



static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameplayScene ()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *tilesLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *overlayTilesLayer;
@property (strong, nonatomic) BBQGameLogic *gameLogic;
@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;
@property (assign, nonatomic) CGPoint swipeFromLocation;

@end

@implementation GameplayScene {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_movesLabel;
    CCSprite *_orderDisplayNode;
    CCSprite *_scoreboardBackground;
    BBQMenu *_menuNode;
}

#pragma mark - Setting Up

-(void)didLoadFromCCB {
    _menuNode.delegate = self;
    
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
    self.userInteractionEnabled = YES;
    

}

#pragma mark - Helper methods

- (void)setupGameWithLevel:(NSInteger)level {
    
    self.level = level;
    self.gameLogic = [[BBQGameLogic alloc] init];
    _menuNode.gameLogic = self.gameLogic;
    NSSet *cookies = [self.gameLogic setupGameLogicWithLevel:level];
    _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.currentScore];
    [self addSpritesForOrders];
    
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
    if (cookie.cookieType == 10) {
        cookieNode.countCircle.visible = YES;
        cookieNode.countLabel.string = [NSString stringWithFormat:@"%ld", (long)cookie.countdown];
    }
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
        
        order.orderNode = orderView;
        
    }
}

+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight / 2);
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    if (point.x >= 0 && point.x < NumColumns * TileWidth &&
        point.y >= 0 && point.y < NumRows * TileHeight) {
        *column = point.x / TileWidth;
        *row = point.y / TileHeight;
        return YES;
    }
    
    else {
        *column = NSNotFound;
        *row = NSNotFound;
        return NO;
    }
}

- (void)enableInteraction {
    self.userInteractionEnabled = TRUE;
    NSLog(@"User interaction enabled: %hhd", self.userInteractionEnabled);
}

#pragma  mark - Swipe Methods

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        BBQTile *tile = [self.gameLogic.level tileAtColumn:column row:row];
        if (tile.tileType != 0) {
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
            self.swipeFromLocation = location;
        }
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if (self.swipeFromColumn == NSNotFound) return;
    
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        NSString *swipeDirection;
        if (location.x < self.swipeFromLocation.x) {
            swipeDirection = @"Left";
        }
        else if (location.x > self.swipeFromLocation.x) {
            swipeDirection = @"Right";
        }
        else if (location.y < self.swipeFromLocation.y) {
            swipeDirection = @"Down";
        }
        else if (location.y > self.swipeFromLocation.y) {
            swipeDirection = @"Up";
        }
        
        NSLog(@"Swipe direction: %@", swipeDirection);
        if (swipeDirection) {
            [self swipeDirection:swipeDirection];
        }
        self.swipeFromColumn = NSNotFound;
    }
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
    self.swipeFromLocation = CGPointMake(0, 0);
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self touchEnded:touch withEvent:event];
}

- (void)swipeDirection:(NSString *)direction {
    NSLog(@"Swipe %@", direction);
    self.userInteractionEnabled = NO;
    
    NSArray *movements = [self.gameLogic movementsForSwipe:direction columnOrRow:[self.gameLogic returnColumnOrRowWithSwipeDirection:direction column:self.swipeFromColumn row:self.swipeFromRow]];
    [self animateMovements:movements swipeDirection:direction completion:^{
        
        NSArray *columns = [self.gameLogic.level fillHoles];
        [self animateFallingCookies:columns completion:^{
            
            NSArray *columns = [self.gameLogic.level topUpCookies];
            [self animateNewCookies:columns completion:^{
                
                [self updateScoreAndMoves];
                
                self.userInteractionEnabled = YES;
                
                //check whether the player has finished the level
                if ([self.gameLogic isLevelComplete]) {
                    [_menuNode displayMenuFor:LEVEL_COMPLETE];
                    
                }
                
                //check whether player has run out of moves
                else if (![self.gameLogic areThereMovesLeft]) {
                    [_menuNode displayMenuFor:NO_MORE_MOVES];
                }
                
            }];
        }];
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
            CCActionCallBlock *removeB = [CCActionCallBlock actionWithBlock:^{
                if (combo.isRootCombo) {
                    CCActionRemove *remove = [CCActionRemove action];
                    [combo.cookieB.sprite runAction:remove];
                }

            }];
            
            CCActionCallBlock *updateCountCircle = [CCActionCallBlock actionWithBlock:^{
                
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
                
                //Take care of powerups
                if (combo.powerup) {
                    for (BBQCookie *cookie in combo.powerup.disappearingCookies) {
                        [cookie.sprite removeFromParent];
                    }
                }
                
                //Take care of steel blocker tiles
                for (BBQTile *tile in combo.steelBlockerTiles) {
                    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SteelBlockersEffect"];
                    explosion.autoRemoveOnFinish = TRUE;
                    explosion.position = tile.sprite.position;
                    [_cookiesLayer addChild:explosion];
                    [tile.sprite removeFromParent];
                    [self createSpriteForTile:tile column:tile.column row:tile.row];
                    
                }

            }];
            
            CCActionSequence *sequenceA = [CCActionSequence actions:moveA, removeA, removeB, updateCountCircle, nil];
            [combo.cookieA.sprite runAction:sequenceA];
            
        }
        
        ////MOVE COOKIES
        for (BBQMoveCookie *movement in animations[MOVEMENTS]) {
            CGPoint position = [GameplayScene pointForColumn:movement.destinationColumn row:movement.destinationRow];
            CCActionMoveTo *moveAnimation = [CCActionMoveTo actionWithDuration:duration position:position];
            [movement.cookieA.sprite runAction:moveAnimation];
        }
        
    }];
    
    //**** DELAY ****
    CCActionDelay *delayOne = [CCActionDelay actionWithDuration:duration + 0.3];
    
    //**** MOVEMENT BATCH TWO ****
    CCActionCallBlock *movementsBatchTwo = [CCActionCallBlock actionWithBlock:^{
        NSArray *movements = animations[MOVEMENTS_BATCH_2];
        for (BBQMoveCookie *movement in movements) {
            CGPoint position = [GameplayScene pointForColumn:movement.destinationColumn row:movement.destinationRow];
            CCActionMoveTo *moveAnimation = [CCActionMoveTo actionWithDuration:duration position:position];
            [movement.cookieA.sprite runAction:moveAnimation];
        }
    }];
    
    //**** DELAY ****
    CCActionDelay *delayTwo = [CCActionDelay actionWithDuration:duration + 0.3];
    
    //**** DROP EXISTING COOKIES ****
    CCActionCallBlock *dropExistingCookies = [CCActionCallBlock actionWithBlock:^{
        NSArray *dropMovements = animations[DROP_MOVEMENTS];
        for (BBQMoveCookie *movement in dropMovements) {
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
    
    //**** CREATE SPRITES FOR NEW GOOSE EGG COOKIES AND STEEL BLOCKER TILES && SECURITY GUARD COUNTDOWN UPDATE ****
    CCActionCallBlock *newSprites = [CCActionCallBlock actionWithBlock:^{
        NSArray *newCookies = animations[GOLDEN_GOOSE_COOKIES];
        for (BBQCookie *cookie in newCookies) {
            [self spriteForCookie:cookie];
        }
        
        NSArray *newSteelBlockerTiles = animations[NEW_STEEL_BLOCKER_TILES];
        for (BBQTile *tile in newSteelBlockerTiles) {
            [tile.sprite removeFromParent];
            [self createSpriteForTile:tile column:tile.column row:tile.row];
        }
        
        for (BBQCookie *guard in self.gameLogic.level.securityGuardCookies) {
            guard.sprite.countLabel.string = [NSString stringWithFormat:@"%ld", (long)guard.countdown];
        }

        
    }];
    
    //**** UPDATE COUNTDOWN ON SECURITY TILES ****//
//    CCActionCallBlock *updateSecurityGuards = [CCActionCallBlock actionWithBlock:^{
//        for (BBQCookie *guard in self.gameLogic.level.securityGuardCookies) {
//            guard.sprite.countLabel.string = [NSString stringWithFormat:@"%ld", (long)guard.countdown];
//        }
//    }];
    

    ////**** FINAL SEQUENCE ****
    CCActionSequence *finalSequence = [CCActionSequence actions:performCombosAndMoveCookies, delayOne, movementsBatchTwo, delayTwo, dropExistingCookies, updateScoreBlock, newSprites, [CCActionCallBlock actionWithBlock:completion], nil];
    [_cookiesLayer runAction:finalSequence];
}

- (void)updateScoreAndMoves {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    _scoreLabel.string = [formatter stringFromNumber:@(self.gameLogic.currentScore)];
    _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    NSLog(@"Moves left label: %@", _movesLabel.string);

}

- (void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        NSInteger startRow = ((BBQCookie *)[array firstObject]).row + 1;
        
        [array enumerateObjectsUsingBlock:^(BBQCookie *cookie, NSUInteger idx, BOOL *stop) {
            BBQCookieNode *sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:startRow];
            cookie.sprite = sprite;
            
            NSTimeInterval delay = 0.1 + 0.2*([array count] - idx - 1);
            
            NSTimeInterval duration = (startRow - cookie.row) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            CGPoint newPosition = [GameplayScene pointForColumn:cookie.column row:cookie.row];
            CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration:duration position:newPosition];
            cookie.sprite.opacity = 0;
            [cookie.sprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:delay],
                [CCActionSpawn actions:[CCActionFadeIn actionWithDuration:0.05], moveAction, nil],
                nil]];
        }];
    }
    
    [self runAction:[CCActionSequence actions:
        [CCActionDelay actionWithDuration:longestDuration],
        [CCActionCallBlock actionWithBlock:completion], nil]];
}

- (void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        [array enumerateObjectsUsingBlock:^(BBQCookie *cookie, NSUInteger idx, BOOL *stop) {
            CGPoint newPosition = [GameplayScene pointForColumn:cookie.column row: cookie.row];
            NSTimeInterval delay = 0.5 + 0.15*idx;
            
            NSTimeInterval duration = ((cookie.sprite.position.y - newPosition.y) / TileHeight) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration:duration position:newPosition];
            CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:delay], moveAction, nil];
            [cookie.sprite runAction:sequence];
        }];
    }
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:longestDuration], [CCActionCallBlock actionWithBlock:completion], nil];
    [self runAction:sequence];
    
}

- (void)animateMovements:(NSArray *)finalCookies swipeDirection:(NSString *)swipeDirection completion: (dispatch_block_t)completion {
    
    __block NSTimeInterval longestDuration = 0;
    
    [finalCookies enumerateObjectsUsingBlock:^(BBQCookie *cookie, NSUInteger idx, BOOL *stop) {
        CGPoint newPosition = [GameplayScene pointForColumn:cookie.column row:cookie.row];
        
        NSTimeInterval duration = 0;
        CGFloat tileDuration = 1.0;
        if ([swipeDirection isEqualToString:UP]) {
            duration = ((newPosition.y - cookie.sprite.position.y) / TileHeight) * tileDuration;
        }
        else if ([swipeDirection isEqualToString:DOWN]) {
            duration = ((cookie.sprite.position.y - newPosition.y) / TileHeight) * tileDuration;
        }
        else if ([swipeDirection isEqualToString:RIGHT]) {
            duration = ((newPosition.x - cookie.sprite.position.x) / TileWidth) * tileDuration;
        }
        else if ([swipeDirection isEqualToString:LEFT]) {
            duration = ((cookie.sprite.position.x - newPosition.x) / TileWidth) * tileDuration;
        }
        longestDuration = MAX(longestDuration, duration);
        
        CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration:duration position:newPosition];
        
        //Remove the extra sprite on a combo if necessary
        CCActionDelay *delayRemoval;
        CCActionDelay *delayForLastCookie;
        CCAction *removeCookie;
        if (cookie.combo) {
            
            //Generic delay
            delayRemoval = [CCActionDelay actionWithDuration:cookie.combo.numberOfTilesToDelayBy * tileDuration];
            
            //Delay for last cookie
            if (cookie.combo.isLastCookieInChain) {
                delayForLastCookie = [CCActionDelay actionWithDuration:0.15];
            }
            
            //Cookie removal
            if (cookie.combo.cookieOrder) {
                removeCookie = [self animateCookieOrderCollection:cookie];
            }
            
            else {
                removeCookie = [CCActionRemove action];
            }
            
        }
        
//        //Take care of removing root cookie
//        if (cookie.combo && cookie.combo.rootCookie && cookie.combo.rootCookie.combo.cookieOrder) {
//            removeRootCookie = [CCActionCallBlock actionWithBlock:^{
//                CCActionSequence *removalSequence = [self animateCookieOrderCollection:cookie];
//                [cookie.combo.rootCookie.sprite runAction:removalSequence];
//            }];
//        }
//        
//        else if (cookie.combo && !cookie.combo.cookieOrder && cookie.combo.rootCookie) {
//            removeRootCookie = [CCActionCallBlock actionWithBlock:^{
//                CCActionRemove *removeCookie = [CCActionRemove action];
//                [cookie.combo.rootCookie.sprite runAction:removeCookie];
//            }];
//        }
//        
//        //Take care of removing last cookie
//        CGFloat delayDuration = 0.15;
//        if (cookie.combo && cookie.combo.isLastCookie && cookie.combo.cookieOrder) {
//            removeLastCookie = [CCActionCallBlock actionWithBlock:^{
//                CCActionSequence *removeLastCookie = [self animateCookieOrderCollection:cookie];
//                CCActionDelay *delayForLastCookie = [CCActionDelay actionWithDuration:delayDuration];
//                CCActionSequence *finalSequence = [CCActionSequence actions: delayForLastCookie, removeLastCookie, nil];
//                [cookie.sprite runAction:finalSequence];
//            }];
//        }
//        
//        else if (cookie.combo && cookie.combo.isLastCookie && !cookie.combo.cookieOrder) {
//            removeLastCookie = [CCActionCallBlock actionWithBlock:^{
//                CCActionRemove *remove = [CCActionRemove action];
//                [cookie.sprite runAction:remove];
//            }];
//        }
        
        CCActionSequence *finalSequence = [CCActionSequence actions:moveAction, delayRemoval, delayForLastCookie, removeCookie, nil];
        
        [cookie.sprite runAction:finalSequence];
    }];
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:longestDuration], [CCActionCallBlock actionWithBlock:completion], nil];
    [self runAction:sequence];
}

- (CCActionSequence *)animateCookieOrderCollection:(BBQCookie *)cookie {
    CCSprite *orderSprite = cookie.combo.cookieOrder.orderNode.cookieSprite.children[0];
    CGPoint endPosition = [orderSprite convertToWorldSpace:CGPointZero];
    
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:1.0 position:endPosition];
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.1 scale:1.0];
    CCActionRemove *removeSprite = [CCActionRemove action];
    CCActionCallBlock *updateOrderQuantity = [CCActionCallBlock actionWithBlock:^{
        NSInteger quantityLeft = [cookie.combo.cookieOrder.orderNode.quantityLabel.string integerValue];
        quantityLeft --;
        cookie.combo.cookieOrder.orderNode.quantityLabel.string = [NSString stringWithFormat:@"%i", quantityLeft];
    }];
    
    CCActionSequence *orderActionSequence = [CCActionSequence actions:move, scaleUp, scaleDown, removeSprite, updateOrderQuantity, nil];
    return orderActionSequence;
}

#pragma mark - Popover methods

- (void)didPlay {
    [_menuNode dismissMenu:START_LEVEL withBackgroundFadeOut:YES];
}


@end
