//
//  BDViewController.m
//  BDUIViewUpdateQueue
//
//  Created by Norsez Orankijanan on 05/20/2015.
//  Copyright (c) 2014 Norsez Orankijanan. All rights reserved.
//

#import "BDViewController.h"
#import <BDUIViewUpdateQueue/BDUIViewUpdateQueue.h>

@interface BDWastingTimeOperation : NSOperation
{
  BOOL _finished;
  NSUInteger _cardinal;
}
- (instancetype)initWithCardinal:(NSUInteger)cardinal;
@property (nonatomic, assign) NSUInteger cardinal;
@property (nonatomic, assign) double result;
@end


#pragma mark - example class
@interface BDViewController ()
{
  NSArray* _results;
}
@end

@implementation BDViewController

#pragma mark - This is where is demo is
- (void)updateResultWithOp:(BDWastingTimeOperation*)op
{
  //this is how BDUIViewUpdateQueue can help you.
  [[BDUIViewUpdateQueue shared] updateView:self.tableView block:^{
    [self _actuallyDoUpdateWithOp:op]; // try not wrapping it with BDUIViewUpdateQueue here. Crash fest!
  }];
  
//  [self _actuallyDoUpdateWithOp:op]; // try not wrapping it with BDUIViewUpdateQueue here = Bug fest!
}

#pragma mark -
- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  _results = @[];
  
  NSArray* ops = @[];
  for (int i=0; i < 15; i++) {
    BDWastingTimeOperation* op = [[BDWastingTimeOperation alloc] initWithCardinal:i+1];
    __unsafe_unretained BDWastingTimeOperation *toUse = op;
    op.completionBlock = ^{
      [self updateResultWithOp:toUse];
    };
    ops = [ops arrayByAddingObject:op];
  }
  
  [[NSOperationQueue mainQueue] addOperations:ops waitUntilFinished:NO];
  
}

#pragma mark - table view delegate

- (void)_actuallyDoUpdateWithOp:(BDWastingTimeOperation*)op
{
  NSString* str = [NSString stringWithFormat:@"op #%d: result = %f", (int)op.cardinal, op.result];
  _results = [_results arrayByAddingObject:str];
  NSIndexPath* toInsert = [NSIndexPath indexPathForRow:_results.count-1 inSection:0];
  [self.tableView insertRowsAtIndexPaths:@[toInsert] withRowAnimation:UITableViewRowAnimationBottom];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _results.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *cellID = @"CellID";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell==nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
  }
  
  cell.textLabel.text = _results[indexPath.row];
  
  return cell;
}

@end


@implementation BDWastingTimeOperation
- (instancetype)initWithCardinal:(NSUInteger)cardinal
{
  self = [super init];
  if (self) {
    _cardinal = cardinal;
    self.queuePriority = NSOperationQueuePriorityVeryHigh;
  }
  return self;
}

- (BOOL)isAsynchronous
{
  return YES;
}

- (BOOL)isConcurrent
{
  return YES;
}

- (void)main
{
  _result = (self.cardinal) * (arc4random_uniform(31.0) + 5);
}

@end