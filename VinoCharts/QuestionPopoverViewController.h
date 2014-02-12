//
//  QuestionPopoverViewController.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
This class works as a popover which shows a list of questions available in a survey.
*/

#import <UIKit/UIKit.h>

@class QuestionPopoverViewController;

@protocol QuestionPopoverViewControllerDelegate

-(void)switchToQuestionWithIndex:(int)index;
//EFFECTS: switch to a question with specific location index

@end

@interface QuestionPopoverViewController : UITableViewController
{
    NSMutableArray* questionList;
}

#pragma delegate method
@property(nonatomic,weak)IBOutlet id<QuestionPopoverViewControllerDelegate> delegate;
#pragma end

#pragma methods
-(void)updateQuestionListWith:(NSMutableArray*)newList;
//EFFECTS: refresh current question list

-(id)initWithDiagramList:(NSMutableArray*)list;
//EFFECTS: initialize cells of current table view with a list of diagram strings

#pragma end

@end
