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

- (BBQCookieNode *)createCookieNodeForCookie:(BBQCookie *)cookie column:(NSInteger)column row:(NSInteger)row {
    BBQCookieNode *cookieNode = (BBQCookieNode *)[CCBReader load:@"Cookie"];
    NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [cookie spriteName]];
    CCSprite *sprite = [CCSprite spriteWithImageNamed:directory];
    [cookieNode.cookieSprite addChild:sprite];
    cookieNode.position = [GameplayScene pointForColumn:column row:row];
    [self.cookiesLayer addChild:cookieNode];
    return cookieNode;
}

- (void)addSpritesForCookies:(NSSet *)cookies {
    for (BBQCookie *cookie in cookies) {
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
}

+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight / 2);
}

- (void)swipeDirection:(NSString *)direction {
    NSLog(@"Swipe %@", direction);
    self.userInteractionEnabled = NO;
    NSDictionary *animations = [self.gameLogic swipe:direction];
    [BBQAnimations animateSwipe:animations scoreLabel:_scoreLabel movesLabel:_movesLabel cookiesLayer:_cookiesLayer currentScore:self.gameLogic.currentScore movesLeft:self.gameLogic.movesLeft completion:^{
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
