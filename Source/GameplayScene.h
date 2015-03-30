
#import "BBQMenu.h"
#import "BBQCookieNode.h"
#import "BBQCombo.h"

#define HORIZONTAL @"Horizontal"
#define VERTICAL @"Vertical"

@class BBQLevel;
@class BBQComboAnimation;

@protocol GameplaySceneDelegate <NSObject>

-(void)setCurrentLevel:(NSInteger)currentLevel;
- (void)progressToNextLevel;

@end


@interface GameplayScene : CCNode <BBQMenuDelegate>

@property (weak, nonatomic) id <GameplaySceneDelegate> delegate;
@property (nonatomic) NSInteger level;



- (void)addSpritesForCookies:(NSSet *)cookies;
+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row;
- (void)setupGameWithLevel:(NSInteger)level;
- (void)progressToNextMaxLevel;



@end
