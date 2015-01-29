@class BBQLevel;
@class BBQCombo;


@interface GameplayScene : CCNode

@property (assign, nonatomic) NSInteger level;



- (void)addSpritesForCookies:(NSSet *)cookies;
+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row;
- (void)setupGameWithLevel:(NSInteger)level;


@end
