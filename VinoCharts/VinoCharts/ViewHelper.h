//
//  ViewHelper.h
//  Game
//
//  Created by Lee Jian Yi David on 3/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewHelper : NSObject

+ (UIView*) embedText:(NSString*)txt
         WithFrame:(CGRect)frame
         TextColor:(UIColor*)color
      DurationSecs:(double)t
                In:(UIView*)view1;
// MODIFIES: view1
// EFFECTS: embeds a text in a view for a specified amount of time.
//          returns a UILabel* that points to the label embedded in view1.
// NOTES: pass in t <= 0 to permanently embed the label.
//          You may disregard the returned UILabel pointer especially
//          if you've set the duration to a non-zero value.

+(UIView*)embedMark:(CGPoint)coord
     WithColor:(UIColor*)color
  DurationSecs:(double)t
            In:(UIView*)view1;
// MODIFIES: view1
// EFFECTS: embeds a small rectangle for a specified amount of time.
//          returns a UIView* that points to the rectangle embedded in view1.
// NOTES: pass in t <= 0 to permanently embed the rectangle.
//          You may disregard the return value especially
//          if you've set the duration to a non-zero value.


+(UIView*)embedRect:(CGRect)frame
          WithColor:(UIColor*)color
       DurationSecs:(double)t
                 In:(UIView*)view1;
// MODIFIES: view1
// EFFECTS: embeds a rectangle for a specified amount of time.
//          returns a UIView* that points to the rectangle embedded in view1.
// NOTES: pass in t <= 0 to permanently embed the rectangle.
//          You may disregard the return value especially
//          if you've set the duration to a non-zero value.


+(UIColor*)invColorOf:(UIColor*)aColor;
// EFFECT: Returns the inverted color of aColor.
//          For e.g., white is the inverse of black.

+(CGRect)centeredFrameForScrollViewWithNoContentInset:(UIScrollView *)sV AndWithContentView:(UIView *)cV;
//EFFECT: Returns a CGRect that you can apply to cV so that cV is orientated smack
//      right in the center of the scrollview it is in.
//REQUIRES: cV to be a subview of sV.

+(CGRect)visibleRectOf:(UIView*)aViewInSV
       thatIsSubViewOf:(UIScrollView*)sV
    withParentMostView:(UIView*)parentView;
//EFFECT: Returns a CGRect that has dimensions w.r.t. aViewInSV that is visible to the user.
//REQUIRES: aViewInSV MUST BE A SUBVIEW OF A SCROLLVIEW - sV.

+(BOOL)isView:(UIView*)subV completelyInside:(UIView*)superV;
// EFFECT: Returns YES if subV's entire frame is completely inside superV. Returns NO otherwise.
// REQUIRES: subV is a subview of superV. Or caller has to, on his own accord, ensure that this function computes something that is mathematically sound, by checking the implementation of this function.  The implementation of this function relies on the _frames_ of subV and superV.

+(BOOL)isPoint:(CGPoint)pt TouchingRect:(CGRect)frame1;
// EFFECT: Returns YES if pt is touching rect.
// REQUIRES: pt and frame1 to be in the same superview.

+(CGRect)boundsOf:(UIView*)view WithWidth:(double)w AndHeight:(double)h;
// EFFECT: Sets view's bounds width and height.

+(CGRect)frameOf:(UIView*)view WithWidth:(double)w AndHeight:(double)h;
// EFFECT: Sets view's frame width and height.

+ (UIImage *) imageWithView:(UIView *)view;
// EFFECT: returns an image that is converted from view.

+(void)raiseUIAlert:(NSString*)title;
//EFFECT: displays a UIAlert with an OK button. User has to dismiss this alert by pressing OK.


@end
