/**
  Copyright (c) 2014-present, Facebook, Inc.
  All rights reserved.

  This source code is licensed under the BSD-style license found in the
  LICENSE file in the root directory of this source tree. An additional grant
  of patent rights can be found in the PATENTS file in the same directory.
 */

#import "Clock.h"

@interface Clock ()
@property (strong, readwrite, nonatomic) NSDate *date;
@end

@implementation Clock
{
  dispatch_source_t _timer;
}

+ (instancetype)clock
{
  static Clock *_clock = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _clock = [[Clock alloc] init];
  });
  return _clock;
}

- (id)init
{
  self = [super init];
  if (self) {
    [self _updateDate];

    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0);

    __weak Clock *weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
      [weakSelf _updateDate];
    });

    _timer = timer;
    dispatch_resume(timer);
  }
  return self;
}

- (void)dealloc
{
  if (NULL != _timer) {
    dispatch_source_cancel(_timer);
  }
}

- (void)_updateDate
{
  self.date = [NSDate date];
}

@end
