
#import "BBQMenu.h"

@class BBQLevel;
@class BBQCombo;

@protocol GameplaySceneDelegate <NSObject>

-(void)setCurrentLevel:(NSInteger)currentLevel;

@end


@interface GameplayScene : CCNode <BBQMenuDelegate>

@property (weak, nonatomic) id <GameplaySceneDelegate> delegate;
@property (assign, nonatomic) NSInteger level;


- (void)addSpritesForCookies:(NSSet *)cookies;
+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row;
- (void)setupGameWithLevel:(NSInteger)level;


@end
