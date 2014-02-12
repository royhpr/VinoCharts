//
//  DisplaySurveyViewController.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
This is the custom class of DisplaySurveyViewController. It is simply manages the display of survey title and survey details in non-editable mode.
Addtionall, it provides an navigation bar to allow user to navigate to different quesstion easily.
*/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DisplayQuestionViewController.h"
#import "Survey.h"
#import "QuestionPopoverViewController.h"


@class DisplaySurveyViewController;

@protocol DisplaySurveyViewControllerDelegate

-(void)createFeedbackWithTitle:(NSString*)title Question:(NSMutableArray*)questionArray Content:(NSMutableArray*)contentArray;
//REQUIRES: This method can only be called when title is not empty (white space), the questionArray and contentArray must not be empty
//EFFECTS: This method circulates the current quesiton and answer info to project level and notifys the current project to create a corresponding
//         Feedback object as well as save it to current database

@end

@interface DisplaySurveyViewController : UIViewController<DisplayQuestionViewControllerDelegate,QuestionPopoverViewControllerDelegate>
{
    //Instants variables
    DisplayQuestionViewController* firstQuestion;
    NSString* feedBackTitle;
    NSMutableArray* ansArray;
    NSMutableArray* QArray;
    
    UIPopoverController* popoverQuestionListController;
    NSMutableArray* questionList;
    
    NSMutableArray* warningList;
}

#pragma IBOutlets
//Subviews reference IBOutlets
@property (strong, nonatomic) IBOutlet UITextField *txtSurveyTitle;
@property (strong, nonatomic) IBOutlet UITextView *txtSurveyDetail;
#pragma end

//Used to retrieve the infomation of current survey
@property(nonatomic,readwrite)Survey* model;


//This delegate object is used to call methods in project level to save, update and generate feedbacks
@property (nonatomic,weak)IBOutlet id<DisplaySurveyViewControllerDelegate> delegate;

@end
