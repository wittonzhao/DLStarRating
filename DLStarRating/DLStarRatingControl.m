/*
 
 DLStarRating
 Copyright (C) 2011 David Linsin <dlinsin@gmail.com>
 
 All rights reserved. This program and the accompanying materials
 are made available under the terms of the Eclipse Public License v1.0
 which accompanies this distribution, and is available at
 http://www.eclipse.org/legal/epl-v10.html
 
 */

#import "DLStarRatingControl.h"
#import "DLStarView.h"
#import "UIView+Subviews.h"


@implementation DLStarRatingControl

@synthesize star, highlightedStar, delegate, isFractionalRatingEnabled;

#pragma mark -
#pragma mark Initialization

- (void)setupView {
  self.clipsToBounds = YES;
  currentIdx = -1;
  for (UIView *subview in self.subviews) {
    [subview removeFromSuperview];
  }
  for (int i=0; i<numberOfStars; i++) {
    DLStarView *v = [[DLStarView alloc] initWithDefault:self.star highlighted:self.highlightedStar position:i allowFractions:isFractionalRatingEnabled fractionNumber: _numberOfFractions];
    [self addSubview:v];
  }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    _numberOfFractions = defaultFractions;
    numberOfStars = kDefaultNumberOfStars;
    isFractionalRatingEnabled = true;
    if (isFractionalRatingEnabled)
      numberOfStars *=_numberOfFractions;
  }
  return self;
}

- (void)setKNumberOfFractions:(int)kNumberOfFractions {
  _numberOfFractions = kNumberOfFractions;
  numberOfStars = kDefaultNumberOfStars;
  if (isFractionalRatingEnabled) {
    numberOfStars *= _numberOfFractions;
  }
}

- (void)layoutSubviews {
  for (int i=0; i < numberOfStars; i++) {
    [(DLStarView*)[self subViewWithTag:i] centerIn:self.frame with:numberOfStars];
  }
}

#pragma mark -
#pragma mark Customization

- (void)setStar:(UIImage*)defaultStarImage andHighlightedStar:(UIImage*)highlightedStarImage {
    // check images for nil else use default stars
  defaultStarImage = (defaultStarImage) ? defaultStarImage : star;
  highlightedStarImage = (highlightedStarImage) ? highlightedStarImage : highlightedStar;
  star = defaultStarImage;
  highlightedStar = highlightedStarImage;
  [self setupView];
}

#pragma mark -
#pragma mark Touch Handling

- (UIButton*)starForPoint:(CGPoint)point {
  for (int i=0; i < numberOfStars; i++) {
    if (CGRectContainsPoint([self subViewWithTag:i].frame, point)) {
      return (UIButton*)[self subViewWithTag:i];
    }
  }
  return nil;
}

- (void)disableStarsDownToExclusive:(int)idx {
  for (int i=numberOfStars; i > idx; --i) {
    UIButton *b = (UIButton*)[self subViewWithTag:i];
    b.highlighted = NO;
  }
}

- (void)disableStarsDownTo:(int)idx {
  for (int i=numberOfStars; i >= idx; --i) {
    UIButton *b = (UIButton*)[self subViewWithTag:i];
    b.highlighted = NO;
  }
}


- (void)enableStarsUpTo:(int)idx {
  for (int i=0; i <= idx; i++) {
    UIButton *b = (UIButton*)[self subViewWithTag:i];
    b.highlighted = YES;
  }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint point = [touch locationInView:self];
  UIButton *pressedButton = [self starForPoint:point];
  if (pressedButton) {
    int idx = (int)pressedButton.tag;
    if (pressedButton.highlighted) {
      [self disableStarsDownToExclusive:idx];
    } else {
      [self enableStarsUpTo:idx];
    }
    currentIdx = idx;
  }
  return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
  [super cancelTrackingWithEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint point = [touch locationInView:self];
  
  UIButton *pressedButton = [self starForPoint:point];
  if (pressedButton) {
    int idx = (int)pressedButton.tag;
    UIButton *currentButton = (UIButton*)[self subViewWithTag:currentIdx];
    
    if (idx < currentIdx) {
      currentButton.highlighted = NO;
      currentIdx = idx;
      [self disableStarsDownToExclusive:idx];
    } else if (idx > currentIdx) {
      currentButton.highlighted = YES;
      pressedButton.highlighted = YES;
      currentIdx = idx;
      [self enableStarsUpTo:idx];
    }
  } else if (point.x < [self subViewWithTag:0].frame.origin.x) {
    ((UIButton*)[self subViewWithTag:0]).highlighted = NO;
    currentIdx = -1;
    [self disableStarsDownToExclusive:0];
  }
  return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  [self.delegate newRating:self :self.rating];
  [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark -
#pragma mark Rating Property

- (void)setRating:(float)_rating {
  if (isFractionalRatingEnabled) {
    _rating *=_numberOfFractions;
  }
  [self disableStarsDownTo:0];
  currentIdx = (int)_rating-1;
  [self enableStarsUpTo:currentIdx];
}

- (float)rating {
  if (isFractionalRatingEnabled) {
    return (float)(currentIdx+1)/_numberOfFractions;
  }
  return (NSUInteger)currentIdx+1;
}

@end
