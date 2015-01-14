#import "MainScene.h"
#import "BBQCookie.h"
#import "BBQLevel.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface MainScene ()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *tilesLayer;

@end

@implementation MainScene

#pragma mark - Starting Up

-(void)didLoadFromCCB {
    
    //load the level and begin game
    self.level = [[BBQLevel alloc] initWithFile:@"Level_1"];
    [self addTiles];
    [self beginGame];
}

- (void)onEnter {
    [super onEnter];
    
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

#pragma mark - 

@end
