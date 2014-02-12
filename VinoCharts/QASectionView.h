//
//  QASectionView.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
this class is a subview of feedback view. it appears as a section view which contains question and answer for a question in one survey.
*/

#import <UIKit/UIKit.h>

@class QASectionView;

@protocol QASectionViewDelegate

-(void)CreateNoteWithText:(NSString*)selectedString;
//EFFECTS: create a new note with highlighted string

-(void)ShowMaximumContentSizeWarning;
//EFFECTS: show warning when the number of chars of current selected string exceeds 140

@end

@interface QASectionView : UIView <UITextViewDelegate>
{
	//Instant variables
    NSString* questionContent;
    NSMutableArray* answerContent;
    
    UITextView* activedTextView;
    
    id observer;
}

@property(nonatomic,weak)IBOutlet id<QASectionViewDelegate> delegate;

-(id)initWithQuestion:(NSString*)question Answer:(NSMutableArray*)answer;
//EFFECTS: create a section view with specific question string and an array of answer string

@end
