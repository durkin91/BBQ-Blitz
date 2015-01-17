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
    
    //***load all cookie textures***//
    

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
    self.userInteractionEnabled = NO;
    NSDictionary *animations = [self.gameLogic swipe:@"Up" forLevel:self.level];
    [self animateSwipe:animations completion:^{
        self.userInteractionEnabled = YES;
    }];
}

- (void)handleSwipeDownFrom:(UIGestureRecognizer *)recognizer {
    NSLog(@"Swipe Down");
    self.userInteractionEnabled = NO;
    NSDictionary *animations = [self.gameLogic swipe:@"Down" forLevel:self.level];
    [self animateSwipe:animations completion:^{
        self.userInteractionEnabled = YES;
    }];
}

- (void)handleSwipeLeftFrom:(UIGestureRecognizer *)recognizer {
    NSLog(@"Swipe Left");
    self.userInteractionEnabled = NO;
    NSDictionary *animations = [self.gameLogic swipe:@"Left" forLevel:self.level];
    [self animateSwipe:animations completion:^{
        self.userInteractionEnabled = YES;
    }];
}

- (void)handleSwipeRightFrom:(UIGestureRecognizer *)recognizer {
    NSLog(@"Swipe Right");
    self.userInteractionEnabled = NO;
    NSDictionary *animations = [self.gameLogic swipe:@"Right" forLevel:self.level];
    [self animateSwipe:animations completion:^{
        self.userInteractionEnabled = YES;
    }];
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
