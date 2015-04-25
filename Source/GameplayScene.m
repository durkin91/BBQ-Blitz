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
#import "BBQChain.h"
#import "BBQTileObstacle.h"
#import "BBQStraightMovement.h"
#import "BBQDiagonalMovement.h"
#import "BBQPauseMovement.h"



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
@property (strong, nonatomic) BBQCookie *rootCookie;
@property (strong, nonatomic) NSDictionary *rootCookieLimits;

@property (strong, nonatomic) BBQCookie *firstCookieInChain;

@end

@implementation GameplayScene {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_movesLabel;
    CCSprite *_orderDisplayNode;
    CCSprite *_scoreboardBackground;
    BBQMenu *_menuNode;
    CCDrawNode *_drawNode;
    CCDrawNode *_inProgressDrawNode;
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
    
    _drawNode = [[CCDrawNode alloc] init];
    [_cookiesLayer addChild:_drawNode z:20];
    
    _inProgressDrawNode = [[CCDrawNode alloc] init];
    [_cookiesLayer addChild:_inProgressDrawNode z:20];
    
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

- (void)enableInteraction {
    self.userInteractionEnabled = TRUE;
    NSLog(@"User interaction enabled: %hhd", self.userInteractionEnabled);
}


#pragma mark - Adding and removing sprites

- (void)clearOutAllCookiesAndTiles {
    NSMutableArray *cookies = [_cookiesLayer.children mutableCopy];
    for (CCSprite *sprite in cookies) {
        [sprite removeFromParent];
    }
    
    NSMutableArray *tiles = [_tilesLayer.children mutableCopy];
    for (CCSprite *tile in tiles) {
        [tile removeFromParent];
    }
    
    NSArray *cookieOrders = [_orderDisplayNode children];
    for (BBQCookieOrderNode *cookieOrder in cookieOrders) {
        [cookieOrder.cookieSprite.children[0] removeFromParent];
        cookieOrder.tickSprite.visible = NO;
        cookieOrder.quantityLabel.visible = YES;
    }
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.gameLogic.level tileAtColumn:column row:row];
            if (tile.tileType != 0) {
                [self createSpriteForTile:tile];
            }
        }
    }
}

- (void)createSpriteForTile:(BBQTile *)tile {
    CCSprite *tileSprite;
    if ((tile.column % 2 == 0 && tile.row % 2 == 0) || (tile.column % 2 != 0 && tile.row % 2 != 0)) {
        tileSprite = [CCSprite spriteWithImageNamed:@"sprites/TileRegular-Light.png"];
    }
    
    else {
        tileSprite = [CCSprite spriteWithImageNamed:@"sprites/TileRegular-Dark.png"];
    }
    tileSprite.position = [GameplayScene pointForColumn:tile.column row:tile.row];
    tileSprite.zOrder = 10;
    [self.maskLayer addChild:tileSprite];
    tile.sprite = tileSprite;
    
    //Create obstacle sprites
    BBQTileObstacle *topObstacle;
    BBQTileObstacle *bottomObstacle;
    for (BBQTileObstacle *obstacle in tile.obstacles) {
        if (obstacle.zOrder == 1) {
            bottomObstacle = obstacle;
        }
        else if (obstacle.zOrder == 2) {
            topObstacle = obstacle;
        }
    }
    
    if (bottomObstacle) {
        [self createSpriteForTileObstacle:bottomObstacle zOrder:-1000 forCookieOrderCollection:NO];
    }
    if (topObstacle) {
        [self createSpriteForTileObstacle:topObstacle zOrder:-1000 forCookieOrderCollection:NO];
    }
}

- (void)createSpriteForTileObstacle:(BBQTileObstacle *)obstacle zOrder:(NSInteger)zOrder forCookieOrderCollection:(BOOL)isForCookieOrderCollection {
    NSString *directory;
    if (isForCookieOrderCollection == NO) {
        directory = [NSString stringWithFormat:@"sprites/%@.png", [obstacle spriteName]];
    }
    else {
        directory = [NSString stringWithFormat:@"sprites/%@.png", [obstacle spriteNameForPurposesOfCookieOrderCollection]];
    }
    CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
    sprite.position = [GameplayScene pointForColumn:obstacle.column row:obstacle.row];
    
    //Give a negative zOrder as a parameter if I want it to do the default zorder
    if (zOrder < 0) {
        if (obstacle.zOrder == 1) {
            zOrder = 100;
        }
        else if (obstacle.zOrder == 2) {
            zOrder = 200;
        }
    }
    
    [self.maskLayer addChild:sprite z:zOrder];
    obstacle.sprite = sprite;
}


- (BBQCookieNode *)createCookieNodeForCookie:(BBQCookie *)cookie column:(NSInteger)column row:(NSInteger)row highlighted:(BOOL)isHighlighted {
    BBQCookieNode *cookieNode = (BBQCookieNode *)[CCBReader load:@"Cookie"];
    NSString *directory;
    NSInteger z;
    if (!isHighlighted) {
        directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie spriteName]];
        z = 10;
    }
    
    else {
        directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie highlightedSpriteName]];
        z = 30;
    }
    CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
    [cookieNode.cookieSprite addChild:sprite];
    cookieNode.position = [GameplayScene pointForColumn:column row:row];
    if (cookie.cookieType == 10) {
        cookieNode.countCircle.visible = YES;
        cookieNode.countLabel.string = [NSString stringWithFormat:@"%ld", (long)cookie.countdown];
    }
    [self.cookiesLayer addChild:cookieNode z:z];
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
        orderView.quantityLabel.visible = YES;
        NSString *directory;
        if (order.cookie) {
            directory = [NSString stringWithFormat:@"sprites/%@.png", [order.cookie spriteName]];
        }
        else if (order.obstacle) {
            directory = [NSString stringWithFormat:@"sprites/%@.png", [order.obstacle spriteName]];
        }
        CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
        sprite.anchorPoint = CGPointMake(0.5, 0.5);
        [orderView.cookieSprite addChild:sprite];
        orderView.quantityLabel.string = [NSString stringWithFormat:@"%ld", (long)order.quantity];
        
        if (order.obstacle) {
            orderView.cookieSprite.scale = 0.9;
        }
        
        order.orderNode = orderView;
        orderView.zOrder = 5 - i;
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

#pragma  mark - Touch Methods

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
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
            self.rootCookie = cookie;
        }
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if (self.firstCookieInChain == nil) return;
    
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        [self drawInProgressLineForColumn:column row:row touchLocation:location];
        
        if (column != self.swipeFromColumn || row != self.swipeFromRow) {
            
            //Check for backtracked Cookie
            BBQCookie *cookie = [self.gameLogic.level cookieAtColumn:column row:row];
            if ([self.gameLogic isCookieABackTrack:cookie]) {
                [self handleBacktrackedCookie:cookie];
                self.gameLogic.chain.isClosedChain = NO;
            }
            
            //UP
            if (row > self.rootCookie.row && column == self.rootCookie.column) {
                [self tryAddingCookieToChainInDirection:UP cookie:cookie];
            }
            
            //DOWN
            else if (row < self.rootCookie.row && column == self.rootCookie.column) {
                [self tryAddingCookieToChainInDirection:DOWN cookie:cookie];
            }
            
            //RIGHT
            else if (column > self.rootCookie.column && row == self.rootCookie.row) {
                [self tryAddingCookieToChainInDirection:RIGHT cookie:cookie];
            }
            
            //LEFT
            else if (column < self.rootCookie.column && row == self.rootCookie.row) {
                [self tryAddingCookieToChainInDirection:LEFT cookie:cookie];
            }
            
            self.swipeFromRow = row;
            self.swipeFromColumn = column;
        }
    }
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self reset];
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
            
            NSArray *cookiesToMove = [self.gameLogic.level fillHoles];
            [self animateFallingAndNewCookies:cookiesToMove completion:^{
                
                [self beginNextTurn];
            }];
    
        }];
    }
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self beginNextTurn];
}

- (void)reset {
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
    self.rootCookie = nil;
    [_drawNode clear];
    [_inProgressDrawNode clear];
}

- (void)beginNextTurn {
    self.userInteractionEnabled = YES;
    [self reset];
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


#pragma mark - Touch Helper Methods

- (BOOL)isBacktracking:(CGPoint)location rootPoint:(CGPoint)rootPoint {
    BOOL isBacktracking = NO;
    BBQCookie *previousCookie = [self.gameLogic previousCookieToCookieInChain:self.rootCookie];
    if (self.gameLogic.chain.isClosedChain == YES) {
        previousCookie = [self.gameLogic.chain.cookiesInChain lastObject];
    }

    if (previousCookie) {
        CGPoint previousCookieLocation = [GameplayScene pointForColumn:previousCookie.column row:previousCookie.row];
        
        if ((location.x > rootPoint.x && location.x < previousCookieLocation.x && location.y == rootPoint.y && location.y == previousCookieLocation.y) ||
            (location.x > previousCookieLocation.x && location.x < rootPoint.x && location.y == rootPoint.y && location.y == previousCookieLocation.y) ||
            (location.y > rootPoint.y && location.y < previousCookieLocation.y && location.x == rootPoint.x && location.x == previousCookieLocation.x) ||
            (location.y > previousCookieLocation.y && location.y < rootPoint.y && location.x == rootPoint.x && location.x == previousCookieLocation.x)) {
            isBacktracking = YES;
        }
    }
    return isBacktracking;
}

- (void)handleBacktrackedCookie:(BBQCookie *)cookie {
    
    NSArray *removedCookies = [self.gameLogic backtrackedCookiesForCookie:cookie];
    [self removeHighlightedCookies:removedCookies];
    [self redrawSegmentsForCookiesInChain];
    self.rootCookie = cookie;
    
    BBQCookie *firstCookie = [self.gameLogic.chain.cookiesInChain firstObject];
    firstCookie.temporaryPowerup = nil;
    [self highlightCookie:firstCookie];
}

- (void)activateCookies:(NSArray *)cookies {
    for (BBQCookie *cookie in cookies) {
        [self highlightCookie:cookie];
        [self animateActivatedCookieInChain:cookie];
        [self drawSegmentToCookie:cookie];
    }
}

- (void)tryAddingCookieToChainInDirection:(NSString *)direction cookie:(BBQCookie *)cookie {
    
    NSArray *cookiesToActivate = [self.gameLogic tryAddingCookieToChain:cookie inDirection:direction];
    if (cookiesToActivate) {
        [self activateCookies:cookiesToActivate];
        self.rootCookie = cookie;
    }
}

#pragma mark - Line Drawing methods

- (void)drawSegmentToCookie:(BBQCookie *)cookie {
    CGPoint cookiePosition = [GameplayScene pointForColumn:cookie.column row:cookie.row];
    
    BBQCookie *previousCookie;
    if ([self.gameLogic isFirstCookieInChain:cookie] == YES) {
        previousCookie = [self.gameLogic.chain.cookiesInChain lastObject];
    }
    else {
        previousCookie = [self.gameLogic previousCookieToCookieInChain:cookie];
    }
    CGPoint previousCookiePosition = [GameplayScene pointForColumn:previousCookie.column row:previousCookie.row];
    [_drawNode drawSegmentFrom:previousCookiePosition to:cookiePosition radius:2.0 color:[cookie lineColor]];
}

- (void)redrawSegmentsForCookiesInChain {
    [_drawNode clear];
    NSArray *cookiesInChain = self.gameLogic.chain.cookiesInChain;
    for (NSInteger i = 1; i < [cookiesInChain count]; i++) {
        BBQCookie *cookie = cookiesInChain[i];
        [self drawSegmentToCookie:cookie];
    }
}

- (void)drawInProgressLineForColumn:(NSInteger)column row:(NSInteger)row touchLocation:(CGPoint)location {
    [_inProgressDrawNode clear];
    
    //Take care of drawing the in progress line
    BBQCookie *rootCookie;
    if (self.gameLogic.chain.isClosedChain) {
        rootCookie = [self.gameLogic.chain.cookiesInChain firstObject];
    }
    
    else {
        rootCookie = self.rootCookie;
    }
    
    CGPoint rootPoint = [GameplayScene pointForColumn:rootCookie.column row:rootCookie.row];
    
    float distanceAboveOrBelow = location.y - rootPoint.y;
    float distanceAcross = location.x - rootPoint.x;
    float x = rootPoint.x;
    float y = rootPoint.y;
    
    if (ABS(distanceAboveOrBelow) >= ABS(distanceAcross)) {
        y = location.y;
        
    }
    else {
        x = location.x;
    }
    
    CGPoint endPoint = CGPointMake(x, y);
    
    NSInteger columnAdjusted, rowAdjusted;
    [self convertPoint:endPoint toColumn:&columnAdjusted row:&rowAdjusted];
    
    if (endPoint.y > rootPoint.y) {
        BBQCookie *upperLimitCookie = self.rootCookieLimits[UP];
        CGPoint upperLimit = [GameplayScene pointForColumn:upperLimitCookie.column row:upperLimitCookie.row];
        endPoint.y = MIN(endPoint.y, upperLimit.y);
    }
    
    else if (endPoint.y < rootPoint.y) {
        BBQCookie *lowerLimitCookie = self.rootCookieLimits[DOWN];
        CGPoint lowerLimit = [GameplayScene pointForColumn:lowerLimitCookie.column row:lowerLimitCookie.row];
        endPoint.y = MAX(endPoint.y, lowerLimit.y);
    }
    
    else if (endPoint.x > rootPoint.x) {
        BBQCookie *rightLimitCookie = self.rootCookieLimits[RIGHT];
        CGPoint rightLimit = [GameplayScene pointForColumn:rightLimitCookie.column row:rightLimitCookie.row];
        endPoint.x = MIN(endPoint.x, rightLimit.x);
    }
    
    else if (endPoint.x < rootPoint.x) {
        BBQCookie *leftLimitCookie = self.rootCookieLimits[LEFT];
        CGPoint leftLimit = [GameplayScene pointForColumn:leftLimitCookie.column row:leftLimitCookie.row];
        endPoint.x = MAX(endPoint.x, leftLimit.x);
    }
    
    BOOL isBacktracking = [self isBacktracking:endPoint rootPoint:rootPoint];
    if (isBacktracking && (columnAdjusted != rootCookie.column || rowAdjusted != rootCookie.row)) {
        BBQCookie *previousCookie = [self.gameLogic previousCookieToCookieInChain:self.rootCookie];
        [self handleBacktrackedCookie:previousCookie];
        rootPoint = [GameplayScene pointForColumn:self.rootCookie.column row:self.rootCookie.row];
        [_inProgressDrawNode drawSegmentFrom:rootPoint to:endPoint radius:2.0 color:[self.rootCookie lineColor]];
        
        BBQCookie *firstCookie = [self.gameLogic.chain.cookiesInChain firstObject];
        firstCookie.temporaryPowerup = nil;
        [self highlightCookie:firstCookie];
        return;
    }
    
    else if (isBacktracking == NO && [self.gameLogic doesNotRequireInProgressLine]) {
        return;
    }
    
    //Make sure not to draw the line at all if its on the wrong side of the root cookie
    NSString *previousCookieDirection = [self.gameLogic directionOfPreviousCookieInChain:self.rootCookie];
    if ([previousCookieDirection isEqualToString:UP] && rootPoint.x == endPoint.x && rootPoint.y < endPoint.y) {
        return;
    }
    else if ([previousCookieDirection isEqualToString:DOWN] && rootPoint.x == endPoint.x && rootPoint.y > endPoint.y) {
        return;
    }
    else if ([previousCookieDirection isEqualToString:RIGHT] && rootPoint.y == endPoint.y && rootPoint.x < endPoint.x) {
        return;
    }
    else if ([previousCookieDirection isEqualToString:LEFT] && rootPoint.y == endPoint.y && rootPoint.x > endPoint.x) {
        return;
    }
    
    //Finally, draw the line
    [_inProgressDrawNode drawSegmentFrom:rootPoint to:endPoint radius:2.0 color:[self.rootCookie lineColor]];
}

#pragma mark - Animations

- (void)animateActivatedCookieInChain:(BBQCookie *)cookie {
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
    CCActionScaleTo *scaleBack = [CCActionScaleTo actionWithDuration:0.1 scale:1.0];
    CCActionSequence *sequence = [CCActionSequence actions:scaleUp, scaleBack, nil];
    [cookie.sprite runAction:sequence];
}

- (CCActionCallBlock *)updateScoreAndMoves {
    CCActionCallBlock *block = [CCActionCallBlock actionWithBlock:^{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        _scoreLabel.string = [formatter stringFromNumber:@(self.gameLogic.currentScore)];
        _movesLabel.string = [NSString stringWithFormat:@"%ld", (long)self.gameLogic.movesLeft];
        NSLog(@"Moves left label: %@", _movesLabel.string);
    }];
    return block;
}

- (void)animateScoreForCookies:(NSArray *)cookies {
    for (BBQCookie *cookie in cookies) {
        [self animateScoreForSingleCookie:cookie];
    }
}

- (void)animateScoreForSingleCookie:(BBQCookie *)cookie {
    //Add a label for the score that slowly fades up
    CGPoint cookieSpriteWorldPos = [_cookiesLayer convertToWorldSpace:[GameplayScene pointForColumn:cookie.column row:cookie.row]];
    CGPoint relativeToSelfPos = [self convertToNodeSpace:cookieSpriteWorldPos];
    
    NSString *score = [NSString stringWithFormat:@"%lu", (long)cookie.score];
    CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:score fontName:@"GillSans-BoldItalic" fontSize:12];
    scoreLabel.position = relativeToSelfPos;
    scoreLabel.zOrder = 300;
    scoreLabel.outlineColor = [CCColor blackColor];
    scoreLabel.outlineWidth = 1.0;
    [self addChild:scoreLabel];
    
    [BBQAnimations animateScoreLabel:scoreLabel];
}

- (NSTimeInterval)animateFallingAndNewCookies:(NSArray *)cookiesToMove completion:(dispatch_block_t)completion {
    
    NSTimeInterval longestDuration = 0;
    NSTimeInterval tileDuration = 3.0;
    NSTimeInterval delay = 0.5;
    
    for (BBQCookie *cookie in cookiesToMove) {
        NSMutableArray *array = [NSMutableArray array];
        NSTimeInterval totalDuration = delay;
        for (NSInteger i = 0; i < [cookie.movements count]; i++) {
            id movement = cookie.movements[i];
            CCAction *action;
            NSTimeInterval duration = 0;
            if ([movement isKindOfClass:[BBQStraightMovement class]]) {
                BBQStraightMovement *straightMovement = movement;
                if (straightMovement.isNewCookie) {
                    NSInteger startRow = NumRows;
                    BBQCookieNode *sprite = [self createCookieNodeForCookie:cookie column:straightMovement.destinationColumn row:startRow highlighted:NO];
                    cookie.sprite = sprite;
                }
                
                CGPoint newPosition = [GameplayScene pointForColumn:straightMovement.destinationColumn row:straightMovement.destinationRow];
                
                duration = ((cookie.sprite.position.y - newPosition.y) / TileHeight) * tileDuration;
                
                action = [CCActionMoveTo actionWithDuration:duration position:newPosition];
            }
            else if ([movement isKindOfClass:[BBQDiagonalMovement class]]) {
                BBQDiagonalMovement *diagonalMovement = movement;
                CGPoint newPosition = [GameplayScene pointForColumn:diagonalMovement.destinationColumn row:diagonalMovement.destinationRow];
                duration = tileDuration;
                action = [CCActionMoveTo actionWithDuration:duration position:newPosition];
            }
            
            else if ([movement isKindOfClass:[BBQPauseMovement class]]) {
                BBQPauseMovement *pauseMovement = movement;
                action = [CCActionDelay actionWithDuration:pauseMovement.numberOfTileMovementsToPauseFor * tileDuration];
            }
            
            totalDuration = totalDuration + duration;
            if (action) {
                [array addObject:action];
            }
        }
        
        longestDuration = MAX(longestDuration, totalDuration);
        
        CCActionSequence *sequence = [CCActionSequence actionWithArray:array];
        [cookie.sprite runAction:sequence];
        cookie.movements = nil;
    }

    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:longestDuration], [CCActionCallBlock actionWithBlock:completion], nil];
    [self runAction:sequence];
    
    return longestDuration;

}

- (NSTimeInterval)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        NSInteger startRow = NumRows;
        
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
    
    return longestDuration;
}

- (NSTimeInterval)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    
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
    
    return longestDuration;
    
}

- (NSTimeInterval)animatePowerupForCookie:(BBQCookie *)cookie detonatePowerupsWithinArray:(BOOL)detonatePowerupsWithinArray {
    
    [self.gameLogic activatePowerupForCookie:cookie];
    
    __block NSTimeInterval longestDuration = 0;
    __block NSTimeInterval scaleActionDuration = 0.3;
    
    //Take care of root cookie
    CCActionScaleTo *scaleAction = [CCActionScaleTo actionWithDuration:scaleActionDuration scale:0.1];
    [cookie.sprite runAction:[CCActionSequence actions:scaleAction, [CCActionRemove action], nil]];
    cookie.sprite = nil;
    longestDuration = scaleActionDuration;
    
    for (NSArray *array in cookie.activePowerup.arraysOfDisappearingCookies) {
        
        [array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            
            if ([object isKindOfClass:[BBQCookie class]]) {
                BBQCookie *powerupCookie = object;
                
                [self animateScoreForSingleCookie:powerupCookie];
                
                
                NSTimeInterval delay = 0.1*idx;
                
                CCActionCallBlock *action = [CCActionCallBlock actionWithBlock:^{
                    
                    [self animateCookieRemoval:powerupCookie powerupDuration:longestDuration scaleActionDuration:scaleActionDuration detonatePowerupsWithinArray:detonatePowerupsWithinArray];
                    [self animateObstaclesForColumn:powerupCookie.column row:powerupCookie.row includeAdjacentObstacles:NO];
                    
                }];
                
                longestDuration = MAX(longestDuration, scaleActionDuration + delay);
                
                [powerupCookie.sprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:delay], action, nil]];
            }
            
            else if ([object isKindOfClass:[BBQTile class]]) {
                BBQTile *tile = object;
                if (tile.tileType != 0) {
                    [self animateObstaclesForColumn:tile.column row:tile.row includeAdjacentObstacles:NO];
                }
            }
            
        }];
    }
    
    [self.gameLogic addPowerupScoreToCurrentScore:cookie.activePowerup];
    [self runAction:[self updateScoreAndMoves]];
    
    return longestDuration;
}

- (void)animateChain:(BBQChain *)chain completion:(dispatch_block_t)completion {
    [self animateScoreForCookies:chain.cookiesInChain];
    [_drawNode clear];
    [_inProgressDrawNode clear];
    
    NSTimeInterval powerupDuration = 0;
    NSTimeInterval duration = 0.3;

    if ([chain isAMultiCookieUpgradedPowerupChain]) {
        BBQCookie *multicookie = [chain returnMultiCookieInMultiCookiePowerup];
        [self.gameLogic activatePowerupForCookie:multicookie];
        
        //Take care of root cookie
        CCActionScaleTo *scaleAction = [CCActionScaleTo actionWithDuration:0.3 scale:0.1];
        [multicookie.sprite runAction:[CCActionSequence actions:scaleAction, [CCActionRemove action], nil]];
        [self animateObstaclesForColumn:multicookie.column row:multicookie.row includeAdjacentObstacles:YES];
        
        [self changeMultiCookieUpgradedPowerupSprites:multicookie completion:^{
            
            [self animateUpgradedMultiCookiePowerup:multicookie completion:^{
                
                [self completionBlockForMultiCookiePowerupUpgrade:multicookie];
            }];
        }];
    }
    
    else {
        for (NSInteger i = 0; i < [chain.cookiesInChain count]; i++) {
            BBQCookie *cookie = chain.cookiesInChain[i];
            
            if ([self.gameLogic doesCookieNeedRemoving:cookie]) {
                [cookie addCookieOrder:self.gameLogic.level.cookieOrders];
                [self animateCookieRemoval:cookie powerupDuration:powerupDuration scaleActionDuration:duration detonatePowerupsWithinArray:YES];
            }
            
            else {
                [self removeHighlightFromCookie:cookie];
            }
            
            [self animateObstaclesForColumn:cookie.column row:cookie.row includeAdjacentObstacles:YES];
        }
        
        [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:duration], [self updateScoreAndMoves], [CCActionDelay actionWithDuration:powerupDuration], [CCActionCallBlock actionWithBlock:completion], nil]];
    }
}

- (void)animateCookieRemoval:(BBQCookie *)cookie powerupDuration:(NSTimeInterval)powerupDuration scaleActionDuration:(NSTimeInterval)duration detonatePowerupsWithinArray:(BOOL)detonatePowerupsWithinArray {
    //Refers to all non upgraded multicookie powerups
    if (cookie.activePowerup && detonatePowerupsWithinArray == YES) {
        [self animatePowerupForCookie:cookie detonatePowerupsWithinArray:detonatePowerupsWithinArray];
    }
    
    //Refers to all upgraded multicookie powerup cookies
    else if (cookie.activePowerup && detonatePowerupsWithinArray == NO) {
        BBQCookie *multicookie = [self.gameLogic.chain returnMultiCookieInMultiCookiePowerup];
        [multicookie.activePowerup removeUndetonatedPowerupFromArraysOfPowerupsToDetonate:cookie];
    }
    
    if (cookie.cookieOrder && cookie.sprite != nil) {
        [self removeHighlightFromCookie:cookie];
        CCActionSequence *sequence = [self animateCookieOrderCollection:cookie];
        [cookie.sprite runAction:sequence];
        cookie.sprite = nil;
    }
    
    
    else if (cookie.sprite != nil) {
        CCActionScaleTo *scaleAction = [CCActionScaleTo actionWithDuration:duration scale:0.1];
        [cookie.sprite runAction:[CCActionSequence actions:scaleAction, [CCActionRemove action], nil]];
        
        cookie.sprite = nil;
    }
}


- (CCActionSequence *)animateCookieOrderCollection:(BBQCookie *)cookie {
    CCSprite *orderSprite = cookie.cookieOrder.orderNode.cookieSprite;
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
        NSInteger quantityLeft = [cookie.cookieOrder.orderNode.quantityLabel.string integerValue];
        cookie.cookieOrder.orderNode.quantityLabel.string = [NSString stringWithFormat:@"%lu", (long)cookie.cookieOrder.quantityLeft];
        if (quantityLeft <= 0) {
            cookie.cookieOrder.orderNode.quantityLabel.visible = NO;
            cookie.cookieOrder.orderNode.tickSprite.visible = YES;
        }
    }];
    
    CCActionSequence *orderActionSequence = [CCActionSequence actions:move, scaleUp, scaleDown, removeSprite, updateOrderQuantity, nil];
    return orderActionSequence;
}

- (void)animateObstaclesForColumn:(NSInteger)column row:(NSInteger)row includeAdjacentObstacles:(BOOL)includeAdjacentObstacles {
    //Deal with obstacle on the cookie's tile
    BBQTileObstacle *obstacleOnTile = [self.gameLogic removeObstacleOnTileForColumn:column row:row];
    if (obstacleOnTile) {
        [self prepareObstacleForRemoval:obstacleOnTile];
        
        
        if ([obstacleOnTile.type isEqualToString:GOLD_PLATED_TILE] || [obstacleOnTile.type isEqualToString:SILVER_PLATED_TILE]) {
            [self prepareObstacleForOrderCollection:obstacleOnTile];
        }
        
        else if ([obstacleOnTile.type isEqualToString:WAD_OF_CASH_ONE] || [obstacleOnTile.type isEqualToString:WAD_OF_CASH_TWO] || [obstacleOnTile.type isEqualToString:WAD_OF_CASH_THREE]) {
            [self prepareObstacleForOrderCollection:obstacleOnTile];
        }
    }
    
    //Deal with obstacles around the cookie's tile
    if (includeAdjacentObstacles == YES) {
        NSArray *adjacentObstacles = [self.gameLogic removeObstaclesAroundTileForColumn:column row:row];
        for (BBQTileObstacle *obstacle in adjacentObstacles) {
            [self prepareObstacleForRemoval:obstacle];
            
            if ([obstacle.type isEqualToString:WAD_OF_CASH_ONE] || [obstacle.type isEqualToString:WAD_OF_CASH_TWO] || [obstacle.type isEqualToString:WAD_OF_CASH_THREE]) {
                [self prepareObstacleForOrderCollection:obstacle];
            }
        }
    }
}

- (void)prepareObstacleForRemoval:(BBQTileObstacle *)obstacle {
    [obstacle addOrderToObstacle:self.gameLogic.level.cookieOrders];
    NSInteger zOrder = obstacle.sprite.zOrder;
    
    BBQTileObstacle *newActiveObstacle = [self.gameLogic activeObstacleForTileAtColumn:obstacle.column row:obstacle.row];
    if (newActiveObstacle && newActiveObstacle.sprite == nil) {
        [self createSpriteForTileObstacle:newActiveObstacle zOrder:zOrder - 1 forCookieOrderCollection:NO];
    }
}

- (void)prepareObstacleForOrderCollection:(BBQTileObstacle *)obstacle {
    if (obstacle.cookieOrder) {
        NSInteger zOrderOfObstacleSprite = obstacle.sprite.zOrder;
        [obstacle.sprite removeFromParent];
        [self createSpriteForTileObstacle:obstacle zOrder:zOrderOfObstacleSprite forCookieOrderCollection:YES];
        [self animateObstacleOrderCollection:obstacle];
    }
    else {
        [obstacle.sprite removeFromParent];
    }

}

- (void)animateObstacleOrderCollection:(BBQTileObstacle *)obstacle {
    CCSprite *orderSprite = obstacle.cookieOrder.orderNode.cookieSprite;
    CGPoint obstacleSpriteWorldPos = [obstacle.sprite.parent convertToWorldSpace:obstacle.sprite.positionInPoints];
    CGPoint relativeToOrderSpritePos = [orderSprite convertToNodeSpace:obstacleSpriteWorldPos];
    [obstacle.sprite removeFromParent];
    [orderSprite addChild:obstacle.sprite];
    obstacle.sprite.position = relativeToOrderSpritePos;
    
    CGPoint endPosition = orderSprite.position;
    
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:1.0 position:endPosition];
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.1 scale:1.0];
    CCActionRemove *removeSprite = [CCActionRemove action];
    CCActionCallBlock *updateOrderQuantity = [CCActionCallBlock actionWithBlock:^{
        NSInteger quantityLeft = [obstacle.cookieOrder.orderNode.quantityLabel.string integerValue];
        obstacle.cookieOrder.orderNode.quantityLabel.string = [NSString stringWithFormat:@"%lu", (long)obstacle.cookieOrder.quantityLeft];
        if (quantityLeft <= 0) {
            obstacle.cookieOrder.orderNode.quantityLabel.visible = NO;
            obstacle.cookieOrder.orderNode.tickSprite.visible = YES;
        }
    }];
    
    CCActionSequence *orderActionSequence = [CCActionSequence actions:move, scaleUp, scaleDown, removeSprite, updateOrderQuantity, nil];
    [obstacle.sprite runAction:orderActionSequence];
}




#pragma mark - Upgraded multicookie powerup methods

- (void)completionBlockForMultiCookiePowerupUpgrade:(BBQCookie *)multicookie {
    if ([multicookie.activePowerup.arraysOfDisappearingCookies count] > 0) {
        [self animateUpgradedMultiCookiePowerup:multicookie completion:^{
            [self completionBlockForMultiCookiePowerupUpgrade:multicookie];
        }];
    }
    else {
        [self beginNextTurn];
    }
}

- (void)changeMultiCookieUpgradedPowerupSprites:(BBQCookie *)multicookie completion:(dispatch_block_t)completion {
    
    __block NSTimeInterval spinDuration = 0.5;
    
    for (NSArray *array in multicookie.activePowerup.arraysOfDisappearingCookies) {
        
        [array enumerateObjectsUsingBlock:^(BBQCookie *powerupCookie, NSUInteger idx, BOOL *stop) {
            //Spin action
            CCActionRotateBy *firstRotation = [CCActionRotateBy actionWithDuration:spinDuration angle:360.0];
            CCActionCallBlock *changeTexture = [CCActionCallBlock actionWithBlock:^{
                [self removeHighlightFromCookie:powerupCookie];
            }];
            CCActionSequence *rotationSequence = [CCActionSequence actions:firstRotation, changeTexture, nil];
            [powerupCookie.sprite runAction:rotationSequence];
        }];
    }
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:spinDuration + 0.1], [CCActionCallBlock actionWithBlock:completion], nil];
    [self runAction:sequence];
}

- (void)animateUpgradedMultiCookiePowerup:(BBQCookie *)multiCookie completion:(dispatch_block_t)completion {
    
    __block NSTimeInterval detonationDuration = 0;
    __block NSTimeInterval fillHolesDuration = 0;
    __block NSTimeInterval topUpCookiesDuration = 0;
    
    NSArray *array = multiCookie.activePowerup.arraysOfDisappearingCookies[0];
    detonationDuration = [self animateArrayOfUpgradedMultiCookiePowerups:array completion:^{
        
        NSArray *columns = [self.gameLogic.level fillHoles];
        fillHolesDuration = [self animateFallingCookies:columns completion:^{
            
            NSArray *columns = [self.gameLogic topUpCookiesWithMultiCookie:multiCookie];
            topUpCookiesDuration = [self animateNewCookies:columns completion:^{
                
                [multiCookie.activePowerup.arraysOfDisappearingCookies removeObject:array];
                
            }];
        }];
    }];
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:5.0], [CCActionCallBlock actionWithBlock:completion], nil];
    [self runAction:sequence];
}

- (NSTimeInterval)animateArrayOfUpgradedMultiCookiePowerups:(NSArray *)array completion:(dispatch_block_t)completion {
    NSTimeInterval longestDuration = 0;
    
    for (BBQCookie *cookie in array) {
        NSTimeInterval powerupDuration = [self animatePowerupForCookie:cookie detonatePowerupsWithinArray:NO];
        longestDuration = MAX(powerupDuration, longestDuration);
    }
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:longestDuration], [CCActionCallBlock actionWithBlock:completion], nil];
    [self runAction:sequence];
    
    return longestDuration;
}


#pragma mark - Popover methods

- (void)didPlay {
    [_menuNode dismissMenu:START_LEVEL withBackgroundFadeOut:YES];
}

#pragma mark - Getters & Setters

- (void)setRootCookie:(BBQCookie *)rootCookie {
    _rootCookie = rootCookie;
    if (rootCookie) {
        self.rootCookieLimits = [self.gameLogic rootCookieLimits:rootCookie];
    }
}


@end
