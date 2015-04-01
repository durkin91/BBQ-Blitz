#import "GameplayScene.h"
#import "BBQCookie.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"
#import "BBQCookieOrderNode.h"
#import "BBQRanOutOfMovesNode.h"
#import "BBQLevelCompleteNode.h"
#import "BBQAnimations.h"
#import "WorldsScene.h"
#import "BBQLaserTileNode.h"
#import "BBQCookieOrder.h"
#import "BBQMovement.h"
#import "BBQChain.h"



static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameplayScene ()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *tilesLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *overlayTilesLayer;
@property (strong, nonatomic) CCClippingNode *cropLayer;
@property (strong, nonatomic) CCNode *maskLayer;
@property (strong, nonatomic) BBQGameLogic *gameLogic;

@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;
@property (assign, nonatomic) NSInteger rootColumnForSwipe;
@property (assign, nonatomic) NSInteger rootRowForSwipe;
@property (assign, nonatomic) double touchBeganTimestamp;
@property (assign, nonatomic) NSTimeInterval tileDuration;
@property (assign, nonatomic) BOOL canStartNextAnimation;

@property (strong, nonatomic) BBQCookie *firstCookieInChain;

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
    
    self.swipeFromColumn = self.swipeFromRow = self.rootColumnForSwipe = self.rootRowForSwipe = NSNotFound;
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
    
    self.cropLayer.stencil = self.maskLayer;
    self.cropLayer.alphaThreshold = 0.0;
    
    
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
    
    //NSString *directory = [NSString stringWithFormat:@"Tiles/%@", [tile spriteName]];
    //CCNode *tileSprite = [CCBReader load:directory];
    CCSprite *tileSprite = [CCSprite spriteWithImageNamed:@"sprites/MaskTile.png"];
    tileSprite.position = [GameplayScene pointForColumn:column row:row];
    tileSprite.zOrder = 10;
    [self.maskLayer addChild:tileSprite];
    tile.sprite = tileSprite;
    
//    if (tile.tileType == 3) {
//        BBQLaserTileNode *laserTileOverlay = (BBQLaserTileNode *)[CCBReader load:@"LaserTile"];
//        laserTileOverlay.position = [GameplayScene pointForColumn:column row:row];
//        [self.overlayTilesLayer addChild:laserTileOverlay];
//        tile.overlayTile = laserTileOverlay;
//    }

}

- (BBQCookieNode *)createCookieNodeForCookie:(BBQCookie *)cookie column:(NSInteger)column row:(NSInteger)row highlighted:(BOOL)isHighlighted {
    BBQCookieNode *cookieNode = (BBQCookieNode *)[CCBReader load:@"Cookie"];
    NSString *directory;
    if (!isHighlighted) {
        directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie spriteName]];
    }
    
    else {
        directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie highlightedSpriteName]];
    }
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
    BBQCookieNode *cookieNode = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:NO];
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
- (void)highlightCookie:(BBQCookie *)cookie {
    [cookie.sprite removeFromParent];
    cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:YES];
}

-(void)removeHighlightFromCookie:(BBQCookie *)cookie {
    [cookie.sprite removeFromParent];
    cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:NO];
}

- (void)removeHighlightedCookies:(NSArray *)cookies {
    for (BBQCookie *cookie in cookies) {
        [self removeHighlightFromCookie:cookie];
    }
}

- (void)addSpritesForOrders {
    NSArray *orderviews = [_orderDisplayNode children];
    NSArray *orderObjects = self.gameLogic.level.cookieOrders;
    for (int i = 0; i < [orderObjects count]; i++) {
        BBQCookieOrder *order = orderObjects[i];
        BBQCookieOrderNode *orderView = orderviews[i];
        NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [order.cookie spriteName]];
        CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
        sprite.anchorPoint = CGPointMake(0.5, 0.5);
        [orderView.cookieSprite addChild:sprite];
        orderView.quantityLabel.string = [NSString stringWithFormat:@"%ld", (long)order.quantity];
        
        order.orderNode = orderView;
        orderView.zOrder = 5 - i;
        
    }
}

- (void)highlightCookiesInColumn:(NSInteger)column row:(NSInteger)row {
    if (column >= 0 && column < NumColumns) {
        for (NSInteger i = 0; i < NumRows; i++) {
            BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:column row:i];
            if (cookie) {
                [cookie.sprite removeFromParent];
                cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:YES];
            }
        }
    }
    
    if (row >= 0 && row < NumRows) {
        for (NSInteger i = 0; i < NumColumns; i++) {
            BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:i row:row];
            if (cookie) {
                [cookie.sprite removeFromParent];
                cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:YES];
            }
        }
    }

}

- (void)removeHighlightFromCookiesInColumn:(NSInteger)column row:(NSInteger)row includingRootCookie:(BOOL)includingRootCookie {
    if (column >= 0 && row < NumColumns) {
        for (NSInteger i = 0; i < NumRows; i++) {
            BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:column row:i];
            
            if (cookie && cookie.row != self.rootRowForSwipe) {
                [cookie.sprite removeFromParent];
                cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:NO];
            }
            else if (cookie && cookie.row == self.rootRowForSwipe && includingRootCookie == YES) {
                [cookie.sprite removeFromParent];
                cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:NO];
            }
        }
    }
    if (row >= 0 && row < NumRows) {
        for (NSInteger i = 0; i < NumColumns; i++) {
            BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:i row:row];
            
            if (cookie && cookie.column != self.rootColumnForSwipe) {
                [cookie.sprite removeFromParent];
                cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:NO];
            }
            
            else if (cookie && cookie.column == self.rootColumnForSwipe && includingRootCookie == YES) {
                [cookie.sprite removeFromParent];
                cookie.sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:cookie.row highlighted:NO];
            }
        }
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
    self.canStartNextAnimation = YES;
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:column row:row];
        if (cookie != nil) {
            [self.gameLogic startChainWithCookie:cookie];
            self.firstCookieInChain = cookie;
            [self highlightCookie:cookie];
            [self animateActivatedCookieInChain:cookie];
            
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
        }
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if (self.firstCookieInChain == nil) return;
    
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        if (column != self.swipeFromColumn || row != self.swipeFromRow) {
            
            BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:column row:row];
            if ([self.gameLogic isCookieABackTrack:cookie]) {
                NSArray *removedCookies = [self.gameLogic backtrackedCookiesForCookie:cookie];
                [self removeHighlightedCookies:removedCookies];
                [self animateActivatedCookieInChain:cookie];
                //Code to illustrate the removal of previous cookies from chain
            }
            
            else if ([self.gameLogic tryAddingCookieToChain:cookie] == YES) {
                [self highlightCookie:cookie];
                [self animateActivatedCookieInChain:cookie];
            }
            
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
        }
    }
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    self.swipeFromColumn = self.swipeFromRow = self.rootRowForSwipe = self.rootColumnForSwipe = NSNotFound;
    self.userInteractionEnabled = NO;
    
    //If the chain isn't a valid chain
    if ([self.gameLogic.chain isACompleteChain] == NO) {
        [self removeHighlightedCookies:self.gameLogic.chain.cookiesInChain];
        [self beginNextTurn];
    }
    
    //If the chain is a valid chain
    else {
        self.gameLogic.movesLeft--;
        [self.gameLogic calculateScoreForChain];
        BBQChain *chain = [self.gameLogic removeCookiesInChain];
        [self animateChain:chain completion:^{
            [self updateScoreAndMoves];
    
            NSArray *columns = [self.gameLogic.level fillHoles];
            [self animateFallingCookies:columns completion:^{
                
                NSArray *columns = [self.gameLogic.level topUpCookies];
                [self animateNewCookies:columns completion:^{
                    
                    [self beginNextTurn];
                    
                }];
            }];
        }];
    }
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    self.swipeFromColumn = self.swipeFromRow = self.rootRowForSwipe = self.rootColumnForSwipe = NSNotFound;
    [self.gameLogic resetEverythingForNextTurn];
}

- (void)beginNextTurn {
    self.userInteractionEnabled = YES;
    [self.gameLogic resetEverythingForNextTurn];
    
    //check whether the player has finished the level
    if ([self.gameLogic isLevelComplete]) {
        [_menuNode displayMenuFor:LEVEL_COMPLETE];
        
    }
    
    //check whether player has run out of moves
    else if (![self.gameLogic areThereMovesLeft]) {
        [_menuNode displayMenuFor:NO_MORE_MOVES];
    }
}

- (void)changeCookieZIndex:(NSArray *)cookies {
    NSInteger z = 10;
    for (BBQCookie *cookie in cookies) {
        cookie.sprite.zOrder = z;
        z = z + 10;
    }
}

#pragma mark - Animate Swipe

- (void)animateActivatedCookieInChain:(BBQCookie *)cookie {
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
    CCActionScaleTo *scaleBack = [CCActionScaleTo actionWithDuration:0.1 scale:1.0];
    CCActionSequence *sequence = [CCActionSequence actions:scaleUp, scaleBack, nil];
    [cookie.sprite runAction:sequence];
}

- (void)updateScoreAndMoves {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    _scoreLabel.string = [formatter stringFromNumber:@(self.gameLogic.currentScore)];
    _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
    NSLog(@"Moves left label: %@", _movesLabel.string);

}

- (void)animateScoreForChain:(BBQChain *)chain {
    for (BBQCookie *cookie in chain.cookiesInChain) {
        //Add a label for the score that slowly fades up
        CGPoint cookieSpriteWorldPos = [_cookiesLayer convertToWorldSpace:[GameplayScene pointForColumn:cookie.column row:cookie.row]];
        CGPoint relativeToSelfPos = [self convertToNodeSpace:cookieSpriteWorldPos];
        
        NSString *score = [NSString stringWithFormat:@"%lu", (long)chain.scorePerCookie];
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:score fontName:@"GillSans-BoldItalic" fontSize:16];
        scoreLabel.position = relativeToSelfPos;
        scoreLabel.zOrder = 300;
        scoreLabel.outlineColor = [CCColor blackColor];
        scoreLabel.outlineWidth = 1.0;
        [self addChild:scoreLabel];
        
        [BBQAnimations animateScoreLabel:scoreLabel];
    }
}

- (void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        NSInteger startRow = ((BBQCookie *)[array firstObject]).row + 1;
        
        [array enumerateObjectsUsingBlock:^(BBQCookie *cookie, NSUInteger idx, BOOL *stop) {
            BBQCookieNode *sprite = [self createCookieNodeForCookie:cookie column:cookie.column row:startRow highlighted:NO];
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

- (void)animateChain:(BBQChain *)chain completion:(dispatch_block_t)completion {
    [self animateScoreForChain:chain];
    [self changeCookieZIndex:chain.cookiesInChain];
    
    for (NSInteger i = 0; i < [chain.cookiesInChain count]; i++) {
        BBQCookie *cookie = chain.cookiesInChain[i];
        
        if (i < chain.numberOfCookiesForOrder && cookie.sprite != nil) {
            [self removeHighlightFromCookie:cookie];
            CCActionSequence *sequence = [self animateCookieOrderCollection:cookie cookieOrder:chain.cookieOrder];
            [cookie.sprite runAction:sequence];
            cookie.sprite = nil;
        }
        
        
        else if (cookie.sprite != nil) {
            CCActionScaleTo *scaleAction = [CCActionScaleTo actionWithDuration:0.3 scale:0.1];
            [cookie.sprite runAction:[CCActionSequence actions:scaleAction, [CCActionRemove action], nil]];
            
            cookie.sprite = nil;
        }
    }
    
    [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.3], [CCActionCallBlock actionWithBlock:completion], nil]];
}

- (void)animateMovements:(NSArray *)movements swipeDirection:(NSString *)swipeDirection completion: (dispatch_block_t)completion {
    
    __block NSTimeInterval tileDuration = 0.1;
    
    [movements enumerateObjectsUsingBlock:^(BBQMovement *movement, NSUInteger idx, BOOL *stop) {
        CGPoint newPosition = [GameplayScene pointForColumn:movement.destinationColumn row:movement.destinationRow];
        
        if (movement.isEnteringCookie) {
            
            BBQCookieNode *sprite;
            if ([swipeDirection isEqualToString:UP]) {
                sprite = [self createCookieNodeForCookie:movement.cookie column:movement.destinationColumn row:movement.destinationRow - 1 highlighted:NO];
            }
            else if ([swipeDirection isEqualToString:DOWN]) {
                sprite = [self createCookieNodeForCookie:movement.cookie column:movement.destinationColumn row:movement.destinationRow + 1 highlighted:NO];
            }
            else if ([swipeDirection isEqualToString:LEFT]) {
                sprite = [self createCookieNodeForCookie:movement.cookie column:movement.destinationColumn + 1 row:movement.destinationRow highlighted:NO];
            }
            else if ([swipeDirection isEqualToString:RIGHT]) {
                sprite = [self createCookieNodeForCookie:movement.cookie column:movement.destinationColumn - 1 row:movement.destinationRow highlighted:NO];
            }
            movement.sprite = sprite;
            movement.cookie.sprite = sprite;
        }
        
        CCActionMoveTo *moveSprite = [CCActionMoveTo actionWithDuration:tileDuration position:newPosition];
        CCActionSequence *sequence;
        if (movement.isExitingCookie) {
            sequence = [CCActionSequence actions:moveSprite, [CCActionRemove action], nil];
        }
        else {
            sequence = [CCActionSequence actions:moveSprite, nil];
        }
        
        [movement.sprite runAction:sequence];
        
    }];
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:tileDuration], [CCActionCallBlock actionWithBlock:completion], nil];
    [self runAction:sequence];
}

- (CCActionSequence *)animateCookieOrderCollection:(BBQCookie *)cookie cookieOrder:(BBQCookieOrder *)cookieOrder {
    CCSprite *orderSprite = cookieOrder.orderNode.cookieSprite;
    CGPoint cookieSpriteWorldPos = [cookie.sprite.parent convertToWorldSpace:cookie.sprite.positionInPoints];
    CGPoint relativeToOrderSpritePos = [orderSprite convertToNodeSpace:cookieSpriteWorldPos];
    [cookie.sprite removeFromParent];
    [orderSprite addChild:cookie.sprite];
    cookie.sprite.position = relativeToOrderSpritePos;
    
    CGPoint endPosition = orderSprite.position;
    
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:1.0 position:endPosition];
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.1 scale:1.0];
    CCActionRemove *removeSprite = [CCActionRemove action];
    CCActionCallBlock *updateOrderQuantity = [CCActionCallBlock actionWithBlock:^{
        NSInteger quantityLeft = [cookieOrder.orderNode.quantityLabel.string integerValue];
        quantityLeft --;
        cookieOrder.orderNode.quantityLabel.string = [NSString stringWithFormat:@"%i", quantityLeft];
        if (quantityLeft == 0) {
            cookieOrder.orderNode.quantityLabel.visible = NO;
            cookieOrder.orderNode.tickSprite.visible = YES;
        }
    }];
    
    CCActionSequence *orderActionSequence = [CCActionSequence actions:move, scaleUp, scaleDown, removeSprite, updateOrderQuantity, nil];
    return orderActionSequence;
}

#pragma mark - Popover methods

- (void)didPlay {
    [_menuNode dismissMenu:START_LEVEL withBackgroundFadeOut:YES];
}


@end
