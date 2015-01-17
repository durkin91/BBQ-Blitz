@class BBQLevel;
@class BBQCombo;


@interface MainScene : CCNode

@property (strong, nonatomic) BBQLevel *level;



- (void)addSpritesForCookies:(NSSet *)cookies;


@end
