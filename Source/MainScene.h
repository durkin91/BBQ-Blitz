@class BBQLevel;
@class BBQCombineCookies;


@interface MainScene : CCNode

@property (strong, nonatomic) BBQLevel *level;
@property (copy, nonatomic) void (^swipeHandler)(BBQCombineCookies *combo);


- (void)addSpritesForCookies:(NSSet *)cookies;


@end
