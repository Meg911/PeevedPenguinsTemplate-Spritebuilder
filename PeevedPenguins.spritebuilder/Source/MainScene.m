//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene
//when the user touches the play button the screen transitions to the GamePlay 'Layer' 960x320in size
- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    CCLOG(@"play button pressed");
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end
