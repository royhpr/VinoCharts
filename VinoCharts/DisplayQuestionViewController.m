//
//  DisplayQuestionViewController.m
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DisplayQuestionViewController.h"

@interface DisplayQuestionViewController ()

@end

@implementation DisplayQuestionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(id)initWithQuestionIndex:(int)index
{
    self = [super init];
    
    if(self != nil)
    {
        QuestionIndex = index;
        questionList = [[NSMutableArray alloc]init];
        self.txtOpenEndEntry.delegate = self;
        
        if(index == 0)
        {
            self.previousController = nil;
            self.nextController = nil;
        }
    }
    return self;
}

- (void)viewDidLoad
{
	//EFFECTS: 	1) set up question outlook in non-editable mode
	//			2) initialize instant variables

    [super viewDidLoad];
    NSArray* currentQuestionInfo = [self.delegate getQuestionInfoFromModelWithIndex:QuestionIndex];
    
    [self DisplayQuestionNumber];
    [self initializeInstantVariables:currentQuestionInfo];
    [self DisplayQuestionTitle];
    
    if([questionType isEqualToString:@"Open End"])
    {
        [self constructOpenEndArea];
        
    }
    else if([questionType isEqualToString:@"Radio Button"])
    {
        [self constructRadioButtonWithOptions:optionContentArray];
    }
    else
    {
        [self constructCheckBoxWithOptions:optionContentArray];
    }
    
    if([questionType isEqualToString:@"Open End"])
    {
        [answerList addObject:[NSNull null]];
        [self.txtOpenEndEntry becomeFirstResponder];
    }
    else
    {
        for(int i=0; i<optionContentArray.count; i++)
        {
            [answerList addObject:[NSNull null]];
        }
    }
    
    [self setUpInterfaceOutlook];
}

- (void)viewWillAppear:(BOOL)animated
{
	//EFFECTS: 1) set up navigation toolbar items
	//		   2) initialize interface title	
    int questionAmount = [self.delegate getNumberOfQuestion];
    
    if(questionAmount == QuestionIndex+1)
    {
        [self addNavigationBarItemForLastQuestion];
    }
    else
    {
        [self addNavigationBarItemForNormalQuestion];
    }

    [self updateInterfaceTitle];
}


#pragma instant methods
- (void)addNavigationBarItemForNormalQuestion
{
	//EFFECTS: add navigation toolbar items for normal questions
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self action:@selector(viewPreviousQuestion)];
     UIBarButtonItem* nextButton = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(viewNextQuestion)];
    UIBarButtonItem* submitButton = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(generateFeedback)];
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc]initWithTitle:@"All Questions" style:UIBarButtonItemStylePlain target:self action:@selector(viewListOfQuestions:)];
    UIBarButtonItem* quitButton = [[UIBarButtonItem alloc]initWithTitle:@"Quit" style:UIBarButtonItemStylePlain target:self action:@selector(quitCurrentSurvey)];
    [quitButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:submitButton,nextButton,backButton, nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:quitButton, menuButton, nil];
}

- (void)addNavigationBarItemForLastQuestion
{
	//EFFECTS: add navigation toolbar items for last question
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self action:@selector(viewPreviousQuestion)];
    UIBarButtonItem* submitButton = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(generateFeedback)];
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc]initWithTitle:@"All Questions" style:UIBarButtonItemStylePlain target:self action:@selector(viewListOfQuestions:)];
    UIBarButtonItem* quitButton = [[UIBarButtonItem alloc]initWithTitle:@"Quit" style:UIBarButtonItemStylePlain target:self action:@selector(quitCurrentSurvey)];
    [quitButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:submitButton,backButton, nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:quitButton, menuButton, nil];
}

- (void)initializeInstantVariables:(NSArray *)currentQuestionInfo
{
    questionTitle = [currentQuestionInfo objectAtIndex:0];
    questionType = [currentQuestionInfo objectAtIndex:1];
    optionContentArray = [[NSMutableArray alloc]initWithArray:[currentQuestionInfo objectAtIndex:2]];
    answerList = [[NSMutableArray alloc]init];
}

- (void)DisplayQuestionNumber
{
	//EFFECTS: update the displayed question number
    NSMutableString* currentQuestionNumber = [NSMutableString stringWithString:@"Q"];
    NSString* number = [NSString stringWithFormat:@"%d",QuestionIndex+1];
    [currentQuestionNumber appendString:number];
    [currentQuestionNumber appendString:@": "];
    self.lblQuestionNumber.text = currentQuestionNumber;
}

- (void)DisplayQuestionTitle
{
    //EFFECTS: update the displayed question title
    self.txtQuestionTitle.text = questionTitle;
    CGRect frame = CGRectMake(self.txtQuestionTitle.frame.origin.x, self.txtQuestionTitle.frame.origin.y, self.txtQuestionTitle.frame.size.width, self.txtQuestionTitle.contentSize.height);
    self.txtQuestionTitle.frame = frame;
}

- (void)constructOpenEndArea
{
	//EFFECTS: show the open ended textview and configure the position and outlook of it
    CGRect textViewFrame = CGRectMake(self.txtQuestionTitle.frame.origin.x, self.txtQuestionTitle.frame.origin.y + self.txtQuestionTitle.frame.size.height + SPACE_BETWEEN_TITLE_AND_FREEENTRYBOX, self.txtOpenEndEntry.frame.size.width, self.txtOpenEndEntry.frame.size.height);
    self.txtOpenEndEntry.frame = textViewFrame;
    [self.txtOpenEndEntry setHidden:NO];
    self.txtOpenEndEntry.layer.borderWidth = 1.0f;
    self.txtOpenEndEntry.layer.borderColor = [[UIColor blackColor]CGColor];
    
    //Assign Gesturerecognizer to scroll view (hide keyboard)
    UITapGestureRecognizer* singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.vwCanvas addGestureRecognizer:singleTapGestureRecognizer];
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)setUpInterfaceOutlook
{
    //EFFECTS: Set up outlook
    self.txtQuestionTitle.layer.borderWidth = 0.5f;
    self.txtQuestionTitle.layer.borderColor = [[UIColor grayColor]CGColor];
    self.txtQuestionTitle.layer.cornerRadius = 5.0f;
    
    self.txtOpenEndEntry.layer.borderWidth = 0.5f;
    self.txtOpenEndEntry.layer.borderColor = [[UIColor grayColor]CGColor];
    self.txtOpenEndEntry.layer.cornerRadius = 5.0f;
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)constructRadioButtonWithOptions:(NSMutableArray*)options
{
	//EFFECTS: construct radio button options with a list of option content
    for(int i=0; i<options.count; i++)
    {
        [self addRadioButtonWithTitle:[options objectAtIndex:i] OptionIndex:i];
    }
}

-(void)addRadioButtonWithTitle:(NSString*)optionString OptionIndex:(int)index
{
	//EFFECTS: add radio button options
    RadioButton* newOption = [[RadioButton alloc]initWithFrame:CGRectMake(self.lblQuestionNumber.frame.origin.x, self.txtQuestionTitle.frame.origin.y + self.txtQuestionTitle.frame.size.height + index*OPTION_HEIGHT + (index+1)*OPTION_SPACE, OPTION_WITH, OPTION_HEIGHT) AndGroupID:QuestionIndex AndID:index AndTitle:optionString];
    newOption.delegate = self;
    [newOption setEditable:NO];
    
    [self.vwCanvas addSubview:newOption];
}

-(void)constructCheckBoxWithOptions:(NSMutableArray*)options
{
	//EFFECTS: construct check box options with a list of option content
    for(int i=0; i<options.count; i++)
    {
        [self addCheckBoxWithTitle:[options objectAtIndex:i] OptionIndex:i];
    }
}

-(void)addCheckBoxWithTitle:(NSString*)optionString OptionIndex:(int)index
{
	//EFFECTS: add check box options
    CheckBox* newOption = [[CheckBox alloc]initWithFrame:CGRectMake(self.lblQuestionNumber.frame.origin.x, self.lblQuestionNumber.frame.origin.y + self.lblQuestionNumber.frame.size.height + index*OPTION_HEIGHT + (index+1)*OPTION_SPACE, OPTION_WITH, OPTION_HEIGHT) AndID:index AndSelected:NO AndTitle:optionString];
    newOption.delegate = self;
    [newOption setEditable:NO];
    
    [self.vwCanvas addSubview:newOption];
}

- (void)updateInterfaceTitle
{
    //EFFECTS: Initialize viewcontroller title
    NSMutableString* currentQuestionNumber = [NSMutableString stringWithFormat:@"%d",QuestionIndex + 1];
    NSString* totalQuestionNumber = [NSString stringWithFormat:@"%d",[self.delegate getNumberOfQuestion]];
    [currentQuestionNumber appendString:@" of "];
    [currentQuestionNumber appendString:totalQuestionNumber];
    self.title = currentQuestionNumber;
}

-(NSMutableArray*)getTheMatchedControllerWithIndex:(int)index controllerArray:(NSMutableArray*)currentControllerArray
{
    if(QuestionIndex == index)
    {
        [currentControllerArray addObject:self];
        return currentControllerArray;
    }
    else if(QuestionIndex < index)
    {
        [currentControllerArray addObject:self];
        return [self.nextController getTheMatchedControllerWithIndex:index controllerArray:(NSMutableArray*)currentControllerArray];
    }
    [currentControllerArray addObject:self];
    return [self.previousController getTheMatchedControllerWithIndex:index controllerArray:(NSMutableArray*)currentControllerArray];
}

-(void)pushToDestinatedControllerWithIndex:(int)index
{
    if(self.nextController != nil)
    {
        if(QuestionIndex+1 == index)
        {
            [self.navigationController pushViewController:self.nextController animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:self.nextController animated:NO];
            [self.nextController pushToDestinatedControllerWithIndex:index];
        }
    }
    else
    {
        DisplayQuestionViewController* newQuestion = [[DisplayQuestionViewController alloc]initWithQuestionIndex:(QuestionIndex + 1)];
        self.nextController = newQuestion;
        newQuestion.previousController = self;
        newQuestion.delegate = self.delegate;
        
        if(QuestionIndex+1 == index)
        {
            [self.navigationController pushViewController:newQuestion animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:newQuestion animated:NO];
            [self.nextController pushToDestinatedControllerWithIndex:index];
        }
    }
}

-(void)popToDestinationControllerWithIndex:(int)index
{
    if(QuestionIndex-1 == index)
    {
        [self.navigationController popToViewController:self.previousController animated:YES];
    }
    else
    {
        [self.navigationController popToViewController:self.previousController animated:NO];
        //keep poping here
        [self.previousController popToDestinationControllerWithIndex:index];
    }
}

-(void)switchToQuestionWithIndex:(int)index
{
    //Update open ended answer
    if([questionType isEqualToString:@"Open End"])
    {
        NSString* ansContent = self.txtOpenEndEntry.text;
        [answerList replaceObjectAtIndex:0 withObject:ansContent];
        [self.delegate addAnswerWith:answerList WithIndex:QuestionIndex];
    }
    if(index > QuestionIndex)
    {
        [self pushToDestinatedControllerWithIndex:index];
    }
    
    else if(index < QuestionIndex)
    {
        [self popToDestinationControllerWithIndex:index];
    }
    
    [popoverQuestionListController dismissPopoverAnimated:YES];
}

-(void)hideKeyboard
{
	//EFFECTS: dismiss keyboard
    if([self.txtOpenEndEntry isFirstResponder])
    {
        [self.txtOpenEndEntry resignFirstResponder];
    }
}
#pragma end


#pragma navigation boolbar callback methods
-(void)viewPreviousQuestion
{
	//EFFECTS: navigate to previous question
    if([questionType isEqualToString:@"Open End"])
    {
        NSString* ansContent = self.txtOpenEndEntry.text;
        [answerList replaceObjectAtIndex:0 withObject:ansContent];
        [self.delegate addAnswerWith:answerList WithIndex:QuestionIndex];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showNextQuestion
{
	//EFFECTS: display next question
    DisplayQuestionViewController* newQuestion = [[DisplayQuestionViewController alloc]initWithQuestionIndex:QuestionIndex+1];
    newQuestion.previousController = self;
    self.nextController = newQuestion;
    newQuestion.delegate = self.delegate;
    
    [self.navigationController pushViewController:newQuestion animated:YES];
}

-(void)viewNextQuestion
{
    //EFFECTS: show next question when the next question controller is not nil, otherwise configure next question controller and show it
    if(self.nextController != nil)
    {
        [self.navigationController pushViewController:self.nextController animated:YES];
    }
    else
    {
        [self showNextQuestion];
    }
    
    if([questionType isEqualToString:@"Open End"])
    {
        NSString* ansContent = self.txtOpenEndEntry.text;
        [answerList replaceObjectAtIndex:0 withObject:ansContent];
    }
    [self.delegate addAnswerWith:answerList WithIndex:QuestionIndex];
}

-(void)generateFeedback
{
	//EFFECTS: circulate a list question title info, a list of answer info and a title to project level to create a feedback
    if([questionType isEqualToString:@"Open End"])
    {
        NSString* ansContent = self.txtOpenEndEntry.text;
        [answerList replaceObjectAtIndex:0 withObject:ansContent];
    }
    [self.delegate addAnswerWith:answerList WithIndex:QuestionIndex];
    
    if([self isAllQuestionAnswered])
    {
        [self showSubmissionRequest];
    }
    else
    {
        [self showUncompletedQuestionAlert];
    }
}
       
-(BOOL)isAllQuestionAnswered
{
   //EFFECTS: check if all the questions are answered
   returnedUnansweredQuestionList = [self.delegate isAllAnswered];
    
    if(returnedUnansweredQuestionList.count == 0)
    {
        return YES;
    }
    return NO;
}

-(void)showUncompletedQuestionAlert
{
	//EFFECTS: pop up and warning with indication of uncompleted questions
    NSMutableString* warningMessage = [NSMutableString stringWithString:@"Please answer questions: "];
    
    for(int i=0; i<returnedUnansweredQuestionList.count; i++)
    {
        [warningMessage appendString:[returnedUnansweredQuestionList objectAtIndex:i]];
        if(i != returnedUnansweredQuestionList.count-1)
        {
            [warningMessage appendString:@", "];
        }
    }
    [warningMessage appendString:@" before submission"];
    
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"Questions Not Completed"
                                                               message:warningMessage
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStyleDefault;
    warningAlertView.tag = 1;
    [warningAlertView show];
}

-(void)showSubmissionRequest
{
	//EFFECTS: ask for a title for a new feedback
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"FeedBack Name"
                                                               message:@"Please enter a name for the Feedback."
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Submit", nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    warningAlertView.tag = 2;
    [warningAlertView show];
}

- (void)buildQuestionList:(int)currentTotalNumberOfQuestion
{
	//EFFECTS: generate a list of currently available questions in the survey
    for(int i=0; i<currentTotalNumberOfQuestion; i++)
    {
        NSMutableString* currentQuestion = [NSMutableString stringWithString:@"Question "];
        [currentQuestion appendString:[NSString stringWithFormat:@"%d",i+1]];
        
        [questionList addObject:currentQuestion];
    }
}

-(void)viewListOfQuestions:(id)sender
{
	//EFFECTS: show a popover which contains a list of availabel questions
    if(!popoverQuestionListController)
    {
        int currentTotalNumberOfQuestion = [self.delegate getNumberOfQuestion];
        [self buildQuestionList:currentTotalNumberOfQuestion];
        
        QuestionPopoverViewController* controller = [[QuestionPopoverViewController alloc]initWithDiagramList:questionList];
        controller.delegate = self;
        popoverQuestionListController = [[UIPopoverController alloc]initWithContentViewController:controller];
    }
    
    if([popoverQuestionListController isPopoverVisible])
    {
        [popoverQuestionListController dismissPopoverAnimated:YES];
    }
    else
    {
        [popoverQuestionListController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)quitCurrentSurvey
{
    [self.delegate returnToMainInterface];
}
#pragma end


#pragma option delegate methods
- (void)stateChangedForGroupID:(NSUInteger)indexGroup WithSelectedButton:(NSUInteger)indexID
{
	//EFFECTS: update the answer for current question when user tap on an radio button
    NSString* currentAns = [optionContentArray objectAtIndex:indexID];
    [answerList replaceObjectAtIndex:0 withObject:currentAns];
    [self.delegate addAnswerWith:answerList WithIndex:QuestionIndex];
}

- (void)stateChangedForID:(NSUInteger)index WithCurrentState:(BOOL)currentState
{
	//EFFECTS: update the answer for current question when user tap on a check box
    if(currentState)
    {
        if([[answerList objectAtIndex:index]isEqual:[NSNull null]])
        {
            [answerList replaceObjectAtIndex:index withObject:[optionContentArray objectAtIndex:index]];
        }
    }
    else
    {
        if(![[answerList objectAtIndex:index]isEqual:[NSNull null]])
        {
            [answerList replaceObjectAtIndex:index withObject:(id)[NSNull null]];
        }
    }
    [self.delegate addAnswerWith:answerList WithIndex:QuestionIndex];
}
#pragma end


#pragma UITextView delegate methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	//EFFECTS: limit the number of characters in the open ended textview to 1000
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 1000) ? NO : YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* title;
    if(alertView.tag == 2)
    {
        switch (buttonIndex)
        {
            case 0:
                
                break;
            case 1:
                title = [[alertView textFieldAtIndex:0]text];
                
                [self.delegate finishSurveyWithFeedBackTitle:title];
                break;
                
            default:
                break;
        }
    }
}
#pragma end


#pragma default
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTxtOpenEndEntry:nil];
    [self setTxtQuestionTitle:nil];
    [self setLblQuestionNumber:nil];
    [self setVwCanvas:nil];
    [self setLblQuestionNumber:nil];
    [self setTxtQuestionTitle:nil];
    [self setTxtOpenEndEntry:nil];
    [self setVwCanvas:nil];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
#pragma end

@end
