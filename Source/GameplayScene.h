@class BBQLevel;
@class BBQCombo;


@interface GameplayScene : CCNode



- (void)addSpritesForCookies:(NSSet *)cookies;
+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row;


@end
