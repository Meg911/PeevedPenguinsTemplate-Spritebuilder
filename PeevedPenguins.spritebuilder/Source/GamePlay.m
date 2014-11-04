//
//  GamePlay.m
//  PeevedPenguins
//
//  Created by Magreth de Graaf on 30/10/2014.
//  Copyright (c) 2014 Software Rebel. All rights reserved.
//

#import "GamePlay.h"
#import "Penguin.h"
#import "CCPhysics+ObjectiveChipmunk.h"


@interface GamePlay(){
   //CCSprite *penguin;
   //CCSprite * seal;
    CCNode * penguin;
    CCNode * seal;
}
@end

@implementation GamePlay {
    CCPhysicsNode * _physicsNode;
    CCNode * _catapultArm;
    
    CCPhysicsBody *_physicsBody;
    CCNode * _contentNode;
    
    CCNode * _levelNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    Penguin * _currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    CCAction *_followPenguin;
}

static const float MIN_SPEED = 5.f;

#pragma mark - Init
// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    

    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    //visualise physics bodys and joints for Debugging
  //  _physicsNode.debugDraw = NO;
    
    //nothing will collide with our invisible nodes
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    _physicsNode.collisionDelegate = self;
}




#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [self launchPenguin];
}
   /*  CGPoint touchLocation = [touch locationInNode:_contentNode];

    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        //if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
            // create a penguin from the ccb-file
            _currentPenguin = [CCBReader load:@"Penguin"];
            // initially position it on the scoop. 34,138 is the position in the node space of the _catapultArm
            CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
            // transform the world position to the node space to which the penguin will be added (_physicsNode)
            _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
            // add it to the physics world
            [_physicsNode addChild:_currentPenguin];
            // we don't want the penguin to rotate in the scoop
            _currentPenguin.physicsBody.allowsRotation = FALSE;
            
            // create a joint to keep the penguin fixed to the scoop until the catapult is released
            _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
        
  // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
        
        // create a penguin from the ccb-file
        _currentPenguin = (Penguin *)[CCBReader load:@"Penguin"];
        // initially position it on the scoop. 34,138 is the position in the node space of the _catapultArm
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
        // transform the world position to the node space to which the penguin will be added (_physicsNode)
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        // add it to the physics world
        [_physicsNode addChild:_currentPenguin];
        // we don't want the penguin to rotate in the scoop
        _currentPenguin.physicsBody.allowsRotation = NO;
        
        // create a joint to keep the penguin fixed to the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
             }

}*/

//- (void)touchMoved:(CCTouch *)touch withEvent:(UIEvent *)event {
- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

//- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // when touches end, release the catapult
    [self releaseCatapult];
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    // when touches are cancelled, release the catapult
    [self releaseCatapult];
}
- (void)releaseCatapult {
    if (_mouseJoint != nil) {
        // releases the joint and lets the catpult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        // releases the joint and lets the penguin fly
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        
        // after snapping rotation is fine
        _currentPenguin.physicsBody.allowsRotation = YES;
        
        _currentPenguin.launched = YES;
        
        CGRect uiPointsBoundingBox = CGRectMake(0, 0, self.boundingBox.size.width, self.boundingBox.size.height);
        // follow the flying penguin
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:uiPointsBoundingBox];
        [_contentNode runAction:_followPenguin];
    }
}


- (void)sealRemoved:(CCNode *)seal {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    // place the particle effect on the seals position
    explosion.position = seal.position;
    // add the particle effect to the same node the seal is on
    [seal.parent addChild:explosion];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = YES;
    
    // finally, remove the destroyed seal
    [seal removeFromParent];
}

- (void)nextAttempt {
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    _followPenguin = nil;
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0, 0)];
    [_contentNode runAction:actionMoveTo];
}

- (void)launchPenguin {
    // loads the Penguin.ccb we have set up in Spritebuilder
    CCNode* penguin = [CCBReader load:@"Penguin"];
    // position the penguin at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
   
    //ensure followed object is visible when playing... like being followed by a camera
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
   [self runAction:follow];
   // [_contentNode runAction:follow];
    
}



#pragma mark - Game Actions

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector]replaceScene:[CCBReader loadAsScene:@"GamePlay"]];
}
#pragma mark - Collision Handling

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    float energy = [pair totalKineticEnergy];
    
    // if energy is large enough, remove the seal
    if (energy > 5000.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved:nodeA];
        } key:nodeA];
    }
}

#pragma mark - Update

- (void)update:(CCTime)delta {
    if (_currentPenguin.launched) {
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED) {
            [self nextAttempt];
            return;
        }
        
        // right corner of penguin
        int penguinMaxX = _currentPenguin.boundingBox.origin.x + _currentPenguin.boundingBox.size.width;
        
        // if right corner of penguin leaves is further left, then the left end of the scene -> next attempt
        if (penguinMaxX < self.boundingBox.origin.x) {
            [self nextAttempt];
            return;
        }
        
        // left conrer of penguin
        int penguinMinX = _currentPenguin.boundingBox.origin.x;
        
        // if left corner of penguin leaves is further right, then the right end of the scene -> next attempt
        if (penguinMinX > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self nextAttempt];
            return;
        }
    }
}
@end
