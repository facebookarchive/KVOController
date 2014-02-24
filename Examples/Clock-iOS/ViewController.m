/**
  Copyright (c) 2014-present, Facebook, Inc.
  All rights reserved.

  This source code is licensed under the BSD-style license found in the
  LICENSE file in the root directory of this source tree. An additional grant
  of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ViewController.h"
#import "Clock.h"
#import "ClockView.h"

#define CLOCK_VIEW_MAX_COUNT 10
#define CLOCK_VIEW_TIME_DELAY 3.0
#define RANDOM_ENABLED 1

@interface ViewController ()

@end

@implementation ViewController
{
  NSMutableArray *_clockViews;
  dispatch_source_t _timer;
}

- (void)dealloc
{
  if (NULL != _timer) {
    dispatch_source_cancel(_timer);
  }
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)_addClockView
{
  if (!_clockViews) {
    _clockViews = [NSMutableArray array];
  }
  
  ClockView *clockView = [[ClockView alloc] initWithClock:[Clock clock] style:arc4random_uniform(kClockViewStyleDark+1)];
  [_clockViews addObject:clockView];
  [self.view addSubview:clockView];

  clockView.bounds = CGRectMake(0, 0, 132, 132);

  CGRect contentBounds = self.view.bounds;
#if RANDOM_ENABLED
  clockView.center = CGPointMake(arc4random_uniform(contentBounds.size.width), arc4random_uniform(contentBounds.size.height));
#else
  clockView.center = CGPointMake(contentBounds.size.width / 2., contentBounds.size.height / 2.);
#endif
}

- (void)_removeClockView
{
  if (0 == _clockViews.count) {
    return;
  }

  [_clockViews[0] removeFromSuperview];
  [_clockViews removeObjectAtIndex:0];
}

- (void)_removeAddClockView
{
  [self _removeClockView];
  [self _addClockView];
}

- (void)_scheduleTimer
{
  dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
  dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, CLOCK_VIEW_TIME_DELAY * NSEC_PER_SEC), CLOCK_VIEW_TIME_DELAY * NSEC_PER_SEC, 1.0);
  
  __weak id weakSelf = self;
  dispatch_source_set_event_handler(timer, ^{
    [weakSelf _removeAddClockView];
  });
  
  _timer = timer;
#if RANDOM_ENABLED
  dispatch_resume(timer);
#endif
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];

  while (_clockViews.count < CLOCK_VIEW_MAX_COUNT) {
    [self _addClockView];
  }

  [self _scheduleTimer];
}

@end
