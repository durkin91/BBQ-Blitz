@class BBQLevel;
@class BBQCombo;


@interface MainScene : CCNode

@property (strong, nonatomic) BBQLevel *level;
@property (copy, nonatomic) void (^swipeHandler)(BBQCombo *combo);


- (void)addSpritesForCookies:(NSSet *)cookies;


@end
