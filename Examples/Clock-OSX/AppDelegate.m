/**
  Copyright (c) 2014-present, Facebook, Inc.
  All rights reserved.

  This source code is licensed under the BSD-style license found in the
  LICENSE file in the root directory of this source tree. An additional grant
  of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import "Clock.h"
#import "ClockView.h"

@interface AppDelegate()
@end

#define CLOCK_VIEW_MAX_COUNT 10
#define CLOCK_VIEW_TIME_DELAY 3.0

@implementation AppDelegate
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

- (void)_addClockView
{
  if (!_clockViews) {
    _clockViews = [NSMutableArray array];
  }

  ClockView *clockView = [[ClockView alloc] initWithClock:[Clock clock]];
  [_clockViews addObject:clockView];
  [_window.contentView addSubview:clockView];

  NSSize clockSize = clockView.bounds.size;
  NSRect contentBounds = [_window.contentView bounds];

  [clockView setFrameOrigin:NSMakePoint(arc4random_uniform(contentBounds.size.width) - (clockSize.width / 2.), arc4random_uniform(contentBounds.size.height) - (clockSize.height / 2.))];
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
  dispatch_resume(timer);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  while (_clockViews.count < CLOCK_VIEW_MAX_COUNT) {
    [self _addClockView];
  }
  
  [self _scheduleTimer];
}

@end
