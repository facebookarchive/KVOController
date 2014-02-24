/**
  Copyright (c) 2014-present, Facebook, Inc.
  All rights reserved.

  This source code is licensed under the BSD-style license found in the
  LICENSE file in the root directory of this source tree. An additional grant
  of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ClockLayer.h"
#import <CoreText/CoreText.h>

// number layer attributes
#define NUMBER_LAYER_COUNT 12
#define NUMBER_FONT_NAME @"HelveticaNeue"
#define NUMBER_FONT_SIZE 16.0

// normalized hand length, ratio of clock radius
#define SECOND_HAND_LENGTH 0.57
#define MINUTE_HAND_LENGTH 0.65
#define HOUR_HAND_LENGTH 0.5

@interface ElipseLayer : CAShapeLayer
@end

@implementation ElipseLayer

- (void)setBounds:(CGRect)bounds
{
  if (!CGRectEqualToRect(self.bounds, bounds)) {
    super.bounds = bounds;
    if (CGRectEqualToRect(CGRectZero, bounds)) {
      self.path = NULL;
    } else {
      CGMutablePathRef path = CGPathCreateMutable();
      CGPathAddEllipseInRect(path, nil, bounds);
      self.path = path;
      CGPathRelease(path);
    }
  }
}

@end

static CALayer *hand_layer(CGFloat contentsScale)
{
  CALayer *layer = [CALayer layer];
  layer.contentsScale = contentsScale;
  layer.shouldRasterize = YES;
  return layer;
}

static ElipseLayer *elipse_layer(CGFloat contentsScale)
{
  ElipseLayer *layer = [ElipseLayer layer];
  layer.contentsScale = contentsScale;
  layer.shouldRasterize = YES;
  return layer;
}

static CATextLayer *number_layer(CGFloat contentsScale, CTFontRef font, NSUInteger number)
{
  CATextLayer *layer = [CATextLayer layer];
  layer.string = [NSString stringWithFormat:@"%lu", (unsigned long)number];
  layer.alignmentMode = kCAAlignmentCenter;
  layer.fontSize = NUMBER_FONT_SIZE;
  layer.font = font;
  layer.contentsScale = contentsScale;
  return layer;
}

// clock style keys
static NSString * const kClockBackgroundColorKey = @"clockBackgroundColor";
static NSString * const kClockForegroundColorKey = @"clockForegroundColor";
static NSString * const kClockAccentColorKey = @"clockAccentColor";

// clock style properties
@interface ClockLayer ()
@property (readonly) UIColor *clockBackgroundColor;
@property (readonly) UIColor *clockForegroundColor;
@property (readonly) UIColor *clockAccentColor;
@end

@implementation ClockLayer
{
  ElipseLayer *_faceLayer;
  ElipseLayer *_largeDotLayer;
  ElipseLayer *_smallDotLayer;
  CALayer *_secondHandLayer;
  CALayer *_minuteHandLayer;
  CALayer *_hourHandLayer;
  NSArray *_numberLayers;
  CGFloat _radius;
  BOOL _needsFullLayout;
}

#pragma mark - Class

// dark style definition
+ (NSDictionary *)darkStyle
{
  return @{kClockBackgroundColorKey: [UIColor blackColor],
           kClockForegroundColorKey: [UIColor whiteColor],
           kClockAccentColorKey: [UIColor redColor]};
}

// light style definition
+ (NSDictionary *)lightStyle
{
  return @{kClockBackgroundColorKey: [UIColor whiteColor],
           kClockForegroundColorKey: [UIColor blackColor],
           kClockAccentColorKey: [UIColor redColor]};
}

// default style definition
+ (id)defaultValueForKey:(NSString *)key
{
  id value = [self darkStyle][key];
  if (nil != value) {
    return value;
  }
  return [super defaultValueForKey:key];
}

#pragma mark - Lifecycle

- (id)init
{
  self = [super init];
  if (self) {
    // default contents scale
    CGFloat contentsScale = [UIScreen mainScreen].scale;
    
    // elipse layers
    _faceLayer = elipse_layer(contentsScale);
    _largeDotLayer = elipse_layer(contentsScale);
    _smallDotLayer = elipse_layer(contentsScale);
    
    // number layers
    CTFontRef font = CTFontCreateWithName((CFStringRef)NUMBER_FONT_NAME, NUMBER_FONT_SIZE, NULL);
    NSMutableArray *numberLayers = [NSMutableArray arrayWithCapacity:NUMBER_LAYER_COUNT];
    for (NSUInteger i=1; i <= NUMBER_LAYER_COUNT; ++i) {
      [numberLayers addObject:number_layer(contentsScale, font, i)];
    }
    _numberLayers = numberLayers;
    
    // hand layers
    _hourHandLayer = hand_layer(contentsScale);
    _minuteHandLayer = hand_layer(contentsScale);
    _secondHandLayer = hand_layer(contentsScale);
    
    // update sublayers
    NSMutableArray *sublayers = [NSMutableArray arrayWithObjects:_faceLayer, nil];
    [sublayers addObjectsFromArray:_numberLayers];
    [sublayers addObjectsFromArray:@[_largeDotLayer, _minuteHandLayer, _hourHandLayer, _secondHandLayer, _smallDotLayer]];
    self.sublayers = sublayers;
    
    if (NULL != font) {
      CFRelease(font);
    }
  }
  return self;
}

#pragma mark - Properties

@dynamic clockBackgroundColor;
@dynamic clockForegroundColor;
@dynamic clockAccentColor;

- (void)setStyle:(NSDictionary *)style
{
  super.style = style;
  [self _updatedStyle];
}

- (void)setBounds:(CGRect)bounds
{
  if (!CGRectEqualToRect(bounds, self.bounds)) {
    _radius = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) / 2.;
    _needsFullLayout = YES;
    super.bounds = bounds;
  }
}

- (void)setDate:(NSDate *)date
{
  if (_date != date && ![_date isEqualToDate:date]) {
    _date = date;
    [self setNeedsLayout];
  }
}

#pragma mark - Utilities

- (void)_updatedStyle
{
  CGColorRef backgroundColor = self.clockBackgroundColor.CGColor;
  CGColorRef foregroundColor = self.clockForegroundColor.CGColor;
  CGColorRef accentColor = self.clockAccentColor.CGColor;
  
  _faceLayer.fillColor = backgroundColor;
  _largeDotLayer.fillColor = foregroundColor;
  _smallDotLayer.fillColor = accentColor;

  [_numberLayers enumerateObjectsUsingBlock:^(CATextLayer *numberLayer, NSUInteger idx, BOOL *stop) {
    numberLayer.foregroundColor = foregroundColor;
  }];
  
  _hourHandLayer.backgroundColor = foregroundColor;
  _minuteHandLayer.backgroundColor = foregroundColor;
  _secondHandLayer.backgroundColor = accentColor;
}

- (void)_rotateHandLayers
{
  NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:_date];
  NSInteger minutesIntoDay = dateComponents.hour * 60 + dateComponents.minute;
  CGFloat percentMinutesIntoDay = (CGFloat)minutesIntoDay / (12.0 * 60.0);
  CGFloat percentMinutesIntoHour = (CGFloat)dateComponents.minute / 60.0;
  CGFloat percentSecondsIntoMinute = (CGFloat)dateComponents.second / 60.0;
  
  // XXX set fixed time
  //  percentMinutesIntoDay = (10 * 60 + 12) / (12 * 60.);
  //  percentMinutesIntoHour = 12.0 / 60.0;
  //  percentSecondsIntoMinute = 47.0 / 60.0;
  
  _secondHandLayer.transform = CATransform3DMakeRotation(M_PI * 2 * percentSecondsIntoMinute, 0, 0, 1);
  _hourHandLayer.transform = CATransform3DMakeRotation(M_PI * 2 * percentMinutesIntoDay, 0, 0, 1);
  _minuteHandLayer.transform = CATransform3DMakeRotation(M_PI * 2 * percentMinutesIntoHour, 0, 0, 1);
}

- (void)_layoutElipseLayers
{
  CGRect bounds = self.bounds;
  CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  
  _faceLayer.bounds = bounds;
  _faceLayer.position = center;

  _smallDotLayer.bounds = CGRectMake(0, 0, 3.0, 3.0);
  _smallDotLayer.position = center;
  
  _largeDotLayer.bounds = CGRectMake(0, 0, 9.0, 9.0);
  _largeDotLayer.position = center;
}

- (void)_layoutNumberLayers
{
  // XXX document
  CGRect bounds = self.bounds;
  CGPoint p = CGPointMake(0, _radius - 14);
  CGFloat tickAngle = 2 * M_PI / NUMBER_LAYER_COUNT;
  
  [_numberLayers enumerateObjectsUsingBlock:^(CALayer *numberLayer, NSUInteger idx, BOOL *stop) {
    CGAffineTransform t = CGAffineTransformMakeRotation(7 * tickAngle + idx * tickAngle);
    CGPoint pp = CGPointApplyAffineTransform(p, t);
    pp.x += bounds.size.width / 2;
    pp.y += bounds.size.height / 2;
    numberLayer.position = pp;
    numberLayer.bounds = CGRectMake(0.0, 0.0, 18.0, 18.0);
  }];
}

- (void)_layoutHandLayers
{
  CGRect bounds = self.bounds;
  CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  
  _secondHandLayer.bounds = CGRectMake(0, 0, 1.0, SECOND_HAND_LENGTH * _radius);
  _secondHandLayer.anchorPoint = CGPointMake(0.5, 1);
  _secondHandLayer.position = center;
  
  _minuteHandLayer.bounds = CGRectMake(0, 0, 2.0, MINUTE_HAND_LENGTH * _radius);
  _minuteHandLayer.anchorPoint = CGPointMake(0.5, 1);
  _minuteHandLayer.position = center;
  _minuteHandLayer.cornerRadius = 1.5;
  
  _hourHandLayer.bounds = CGRectMake(0, 0, 3.0, HOUR_HAND_LENGTH * _radius);
  _hourHandLayer.anchorPoint = CGPointMake(0.5, 1);
  _hourHandLayer.position = center;
  _hourHandLayer.cornerRadius = 1.5;
  
  [self _rotateHandLayers];
}

#pragma mark - Overides

- (void)layoutSublayers
{
  if (!_needsFullLayout) {
    [self _rotateHandLayers];
  } else {
    [self _layoutElipseLayers];
    [self _layoutNumberLayers];
    [self _layoutHandLayers];
    _needsFullLayout = NO;
  }
}

@end
