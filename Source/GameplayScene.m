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
@property (strong, nonatomic) BBQCookie *rootCookie;
@property (strong, nonatomic) NSDictionary *rootCookieLimits;
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
    CCDrawNode *_drawNode;
    CCDrawNode *_inProgressDrawNode;
}

#pragma mark - Setting Up

-(void)didLoadFromCCB {
    _menuNode.delegate = self;
    
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
    self.rootCookie = nil;
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
        NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [order.cookie spriteName]];
        CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
        sprite.anchorPoint = CGPointMake(0.5, 0.5);
        [orderView.cookieSprite addChild:sprite];
        orderView.quantityLabel.string = [NSString stringWithFormat:@"%ld", (long)order.quantity];
        
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

- (void)changeCookieZIndex:(NSArray *)cookies {
    NSInteger z = 10;
    for (BBQCookie *cookie in cookies) {
        cookie.sprite.zOrder = z;
        z = z + 10;
    }
}

- (void)drawSegmentToCookie:(BBQCookie *)cookie {
    CGPoint cookiePosition = [GameplayScene pointForColumn:cookie.column row:cookie.row];
    BBQCookie *previousCookie = [self.gameLogic previousCookieToCookieInChain:cookie];
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
    CGPoint rootPoint = [GameplayScene pointForColumn:self.rootCookie.column row:self.rootCookie.row];
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
    
    if ([self isBacktracking:endPoint rootPoint:rootPoint] && (columnAdjusted != self.rootCookie.column || rowAdjusted != self.rootCookie.row)) {
        BBQCookie *previousCookie = [self.gameLogic previousCookieToCookieInChain:self.rootCookie];
        [self handleBacktrackedCookie:previousCookie];
        rootPoint = [GameplayScene pointForColumn:self.rootCookie.column row:self.rootCookie.row];
    }
    
    [_inProgressDrawNode drawSegmentFrom:rootPoint to:endPoint radius:2.0 color:[self.rootCookie lineColor]];
}

- (BOOL)isBacktracking:(CGPoint)location rootPoint:(CGPoint)rootPoint {
    BOOL isBacktracking = NO;
    BBQCookie *previousCookie = [self.gameLogic previousCookieToCookieInChain:self.rootCookie];
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
    //[self animateActivatedCookieInChain:cookie];
    [self redrawSegmentsForCookiesInChain];
    self.rootCookie = cookie;
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
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:score fontName:@"GillSans-BoldItalic" fontSize:12];
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
    [_drawNode clear];
    [_inProgressDrawNode clear];
    
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

- (void)setRootCookie:(BBQCookie *)rootCookie {
    _rootCookie = rootCookie;
    if (rootCookie) {
        self.rootCookieLimits = [self.gameLogic rootCookieLimits:rootCookie];
    }
}


@end
