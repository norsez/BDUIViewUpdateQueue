//
//  BDUIViewUpdateQueue.m
//  Pods
//
//  Created by Norsez Orankijanan on 5/20/15.
//
//

#import "BDUIViewUpdateQueue.h"

#define kTimeIntervalWaitSeconds 1.5

#define KEY_TIMER_ID @"KEY_TIMER_ID"
#define KEY_WHEN_TRUE @"KEY_WHEN_TRUE"
#define KEY_EXECUTE_BLOCK @"KEY_EXECUTE_BLOCK"
#define KEY_LOCK_Q @"KEY_LOCK_Q"

@interface BDUIViewUpdateQueue ()
{
  NSMutableDictionary *_queuesByUIView;
}

@end

@implementation BDUIViewUpdateQueue

- (dispatch_queue_t)_q_forView:(UIView*)lockView
{
  dispatch_queue_t q = [_queuesByUIView objectForKey:@(lockView.hash)];
  if  (!q){
    NSString * name = [NSString stringWithFormat:@"co.bluedot.BDUIViewUpdateQueue.queue.updateUIView.%@", lockView.description];
    q = dispatch_queue_create([name cStringUsingEncoding:NSUTF8StringEncoding], 0);
    [_queuesByUIView setObject:q forKey:@(lockView.hash)];
  }
  
  return q;
}

- (void)updateView:(UIView *)UIView block:(void (^)(void))updateBlock delay:(NSTimeInterval)delayInSeconds
{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self updateView:UIView block:updateBlock];
  });
}

- (void)updateView:(UIView *)UIView block:(void (^)(void))updateBlock
{
  dispatch_sync([self _q_forView:UIView], ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      updateBlock();
    });
  });
}


- (void)updateView:(UIView *)UIView block:(void (^)(void))updateBlock waitUntil:(BOOL (^)(void))waitUntilTrueBlock
{
  NSAssert(updateBlock!=nil, @"updateBlock can't be nil");
  NSAssert(waitUntilTrueBlock!=nil, @"waitUntilTrueblock can't be nil");
  [self _initWaitLockQueue:[self _q_forView:UIView] executeblock:updateBlock whenTrue:waitUntilTrueBlock];
}

#pragma mark - GCD wait

- (NSMutableDictionary*)_timerByTimerIds
{
  static NSMutableDictionary *timerByTimerId;
  if (!timerByTimerId) {
    timerByTimerId = [NSMutableDictionary new];
  }
  return timerByTimerId;
}

- (NSTimer*)_scheduledTimerWithId:(NSString*)timerId lock_q:(dispatch_queue_t)lock_q executeBlock:(void(^)(void))executeBlock whenTrue:(BOOL(^)(void))whenTrue
{
  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTimeIntervalWaitSeconds
                                                    target:self
                                                  selector:@selector(_timeWaitTimer:)
                                                  userInfo:@{KEY_TIMER_ID:timerId,
                                                             KEY_EXECUTE_BLOCK:[executeBlock copy],
                                                             KEY_WHEN_TRUE:[whenTrue copy],
                                                             KEY_LOCK_Q:lock_q
                                                             }
                                                   repeats:YES];
  [[self _timerByTimerIds] setObject:timer forKey:timerId];
  return timer;
}

- (void)_timeWaitTimer:(id)sender
{
  NSTimer* timer = sender;
  dispatch_queue_t lock_q = [timer.userInfo objectForKey:KEY_LOCK_Q];
  
  dispatch_sync(lock_q, ^{

    
    NSString* timerId = [timer.userInfo objectForKey:KEY_TIMER_ID];
    void(^executeBlock)(void) = [timer.userInfo objectForKey:KEY_EXECUTE_BLOCK];
    BOOL(^tryBlock)(void) = [timer.userInfo objectForKey:KEY_WHEN_TRUE];

    if (tryBlock()) {
      [timer invalidate];
      [[self _timerByTimerIds] removeObjectForKey:timerId];
      dispatch_sync(lock_q, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
          executeBlock();
        });
      });
    }
    
  });
}

- (void)_initWaitLockQueue:(dispatch_queue_t)lock_q executeblock:(void(^)(void))executeBlock whenTrue:(BOOL(^)(void))whenTrue
{
  dispatch_sync(lock_q, ^{
    [self _scheduledTimerWithId:[@([NSDate date].timeIntervalSince1970) stringValue]
                         lock_q:lock_q
                   executeBlock:executeBlock
                       whenTrue:whenTrue];
  });
}

#pragma mark - singleton
- (id)init
{
  self = [super init];
  if(self){
    
    _queuesByUIView = [NSMutableDictionary new];
    
  }
  return self;
}
+ (BDUIViewUpdateQueue *)shared
{
  static dispatch_once_t pred;
  static BDUIViewUpdateQueue *singleton = nil;
  
  dispatch_once(&pred, ^{ singleton = [[self alloc] init]; });
  return singleton;
}
@end
