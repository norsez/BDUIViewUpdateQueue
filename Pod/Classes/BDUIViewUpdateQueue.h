//
//  BDUIViewUpdateQueue.h
//  Pods
//
//  Created by Norsez Orankijanan on 5/20/15.
//
//

#import <UIKit/UIKit.h>

/**
 Convenient singleton class to queue updating of UIView animations.
 Should be used to queue update events of cells in a UIView only.
 <b>Never</b> nest these methods.
 */
@interface BDUIViewUpdateQueue : NSObject
/**
 execute the input block in the UIView's serial queue.
 The block should contains both updating of the datasource and UIView update animation.
 */
- (void)updateView:(UIView*)view block:(void(^)(void))updateBlock;
/**
 delay seconds before executing the input block in the UIView's serial queue.
 The block should contains both updating of the datasource and UIView update animation.
 */
- (void)updateView:(UIView*)view block:(void(^)(void))updateBlock delay:(NSTimeInterval)delayInSeconds;

/**
 Hold off on execute the update block until waitUntilTrueBlock returns YES.
 */
- (void)updateView:(UIView *)view block:(void (^)(void))updateBlock waitUntil:(BOOL(^)(void))waitUntilTrueBlock;

+ (BDUIViewUpdateQueue *)shared;
@end
