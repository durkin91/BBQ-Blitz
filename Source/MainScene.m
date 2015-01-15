#import "MainScene.h"
#import "BBQCookie.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"
#import "BBQCombineCookies.h"

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
    self.level = [[BBQLevel alloc] initWithFile:@"Level_1"];
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
    [self addTiles];
    [self beginGame];
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.level tileAtColumn:column row:row] != nil) {
                CCSprite *tileNode = [CCSprite spriteWithImageNamed:@"sprites/Tile.png"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.tilesLayer addChild:tileNode];
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
    }
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight / 2);
}

//In the tutorial these are in the View Controller

- (void)beginGame {
    [self shuffle];
}

- (void)shuffle {
    NSSet *newCookies = [self.level shuffle];
    [self addSpritesForCookies:newCookies];
}

#pragma mark - Gesture Recognizers

- (void)handleSwipeUpFrom:(UIGestureRecognizer *)recognizer {
    NSLog(@"Swipe Up");
    NSMutableArray *animationsToPerform = [self.gameLogic swipe:@"Up" forLevel:self.level];
}

- (void)handleSwipeDownFrom:(UIGestureRecognizer *)recognizer {
    NSLog(@"Swipe Down");
}

- (void)handleSwipeLeftFrom:(UIGestureRecognizer *)recognizer {
    NSLog(@"Swipe Left");
}

- (void)handleSwipeRightFrom:(UIGestureRecognizer *)recognizer {
    NSLog(@"Swipe Right");
}

#pragma mark - Animations

- (void)animateCombos:(NSMutableArray *)combosArray completion:(dispatch_block_t)completion {
    for (BBQCombineCookies *combo in combosArray) {
        
        //Put cookie A on top and move cookie A to cookie B, then remove cookie A
        combo.cookieA.sprite.zOrder = 100;
        combo.cookieB.sprite.zOrder = 90;
        
        const NSTimeInterval duration = 0.3;
        CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration:duration position:combo.cookieB.sprite.position];
        CCActionRemove *removeA = [CCActionRemove action];
        
        //Change sprite texture for cookie B
        CCActionCallBlock *changeSprite = [CCActionCallBlock actionWithBlock:^{
            NSString *directory = [NSString stringWithFormat:@"sprites/%@.png", [combo.cookieB spriteName]];
            CCTexture *texture = [CCTexture textureWithFile:directory];
            combo.cookieB.sprite.texture = texture;
        }];
        
        CCActionSequence *sequenceA = [CCActionSequence actions:moveA, removeA, changeSprite, [CCActionCallBlock actionWithBlock:completion], nil];
        [combo.cookieA.sprite runAction:sequenceA];
    }
}


@end
