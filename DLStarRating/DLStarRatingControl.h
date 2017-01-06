/*
 
 DLStarRating
 Copyright (C) 2011 David Linsin <dlinsin@gmail.com>
 
 All rights reserved. This program and the accompanying materials
 are made available under the terms of the Eclipse Public License v1.0
 which accompanies this distribution, and is available at
 http://www.eclipse.org/legal/epl-v10.html
 
 */

#import <UIKit/UIKit.h>

#define kDefaultNumberOfStars 5
#define defaultFractions 10

@protocol DLStarRatingDelegate;

@interface DLStarRatingControl : UIControl {
  int numberOfStars;
  int currentIdx;
  UIImage *star;
  UIImage *highlightedStar;
  BOOL isFractionalRatingEnabled;
}
@property (strong,nonatomic) UIImage *star;
@property (strong,nonatomic) UIImage *highlightedStar;
@property (nonatomic) float rating;
@property (assign,nonatomic) id<DLStarRatingDelegate> delegate;
@property (nonatomic,assign) BOOL isFractionalRatingEnabled;
@property (nonatomic, assign) int numberOfFractions;

- (void)setStar:(UIImage*)defaultStarImage andHighlightedStar:(UIImage*)highlightedStarImage;
@end

@protocol DLStarRatingDelegate

-(void)newRating:(DLStarRatingControl *)control :(float)rating;

@end
