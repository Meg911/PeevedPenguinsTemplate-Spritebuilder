//
//  GamePlay.m
//  PeevedPenguins
//
//  Created by Magreth de Graaf on 30/10/2014.
//  Copyright (c) 2014 Software Rebel. All rights reserved.
//

#import "GamePlay.h"
#import "Penguin.h"
#import "Seal.h"
//#import "CCPhysics+ObjectiveChipmunk.h"


@interface GamePlay(){
   //CCSprite *penguin;
   //CCSprite * seal;
    CCNode * penguin;
    CCNode * seal;
}
@end

@implementation GamePlay {
    CCPhysicsBody *_physicsBody;
    CCNode * _contentNode;
    CCPhysicsNode * _physicsNode;
    CCNode * _catapultArm;
    CCNode * _levelNode;
    CCNode * _pullbackNode;
    
   // Penguin * penguin;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    //CCScene *level = [CCBReader load:@"Levels/Level1"];
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    //visualise physics bodys and joints for Debugging
    _physicsNode.debugDraw = TRUE;
    
    //nothing will collide with our invisible nodes
    _pullbackNode.physicsBody.collisionMask = @[];
    
}

// called on every touch in this scene
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self launchPenguin];
}

- (void)launchPenguin {
    // loads the Penguin.ccb we have set up in Spritebuilder
    CCNode* penguin1 = [CCBReader load:@"Penguin"];
    // position the penguin at the bowl of the catapult
    penguin1.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin1];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin1.physicsBody applyForce:force];
    //ensure followed object is visible when playing... like being followed by a camera
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin1 worldBoundary:self.boundingBox];
  //  [self runAction:follow];
    [_contentNode runAction:follow];
}
-(void) retry{
    //reload the level
    [[CCDirector sharedDirector]replaceScene:[CCBReader loadAsScene:@"GamePlay"]];
}


@end
