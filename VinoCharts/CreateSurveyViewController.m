//
//  CreateSurveyViewController.m
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a custom class for Create Survey Interface. It shows the survry title and details. It also manages the logic of updating surveys.
 One object of this class is created whenever user wants to create a new survey in porject level.
 */

#import "CreateSurveyViewController.h"

@interface CreateSurveyViewController ()

@end

@implementation CreateSurveyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    //EFFECTS:
    //1) set up the title, detail view
    //2) initialize instant variables
    //3) assign delegates of subviews
    //4) assign gesturerecognizer to dismiss keyboard
    //5) initialize navigation bar items
    //6) butify the outlook
    
    [super viewDidLoad];
    [self.txtTitleView becomeFirstResponder];
    
	//Initialize model
    self.model = [[Survey alloc]init];
    questionList = [[NSMutableArray alloc]init];
    firstQuestion = nil;

    //Assign delegate to self
    self.txtTitleView.delegate = self;
    self.txtDetailView.delegate = self;
    
    [self addGestureRecognizerToDismissKeyBoard];
    [self addNavigationButtons];
    [self setUpOutlook];
    
}


#pragma instant methods
- (void)setUpOutlook
{
    //EFFECTS: Set up outlook
    self.txtDetailView.layer.borderWidth = 0.5f;
    self.txtDetailView.layer.borderColor = [[UIColor grayColor]CGColor];
    self.txtDetailView.layer.cornerRadius = 5.0f;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Survey Details";
}

- (void)addNavigationButtons
{
    //EFFECTS: Add navigation button
    [self.navigationItem setHidesBackButton:YES animated:NO];
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc]initWithTitle:@"Add Question" style:UIBarButtonItemStylePlain target:self action:@selector(constructFirstQuestion)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(saveSurvey)];
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc]initWithTitle:@"All Questions" style:UIBarButtonItemStylePlain target:self action:@selector(viewListOfQuestions:)];
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    [closeButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:nextButton,doneButton, nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:closeButton, menuButton, nil];
}

- (void)addGestureRecognizerToDismissKeyBoard
{
    //EFFECTS: Add Tap gesture recognizer to the canvas
    UITapGestureRecognizer* singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.myBackgroundView addGestureRecognizer:singleTapGestureRecognizer];
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)createFirstQuestion
{
    //EFFECTS: Create first question for current survey
    CreateQuestionViewController* newQuestion = [[CreateQuestionViewController alloc]initWithQuestionIndex:0];
    newQuestion.delegate = self;
    firstQuestion = newQuestion;
    [self.model addEmptyQuestion];
    [self.navigationController pushViewController:newQuestion animated:YES];
}

- (void)constructFirstQuestion
{
    //EFFECTS:
    //1) construct the model of first question
    //2) a new question viewconstroller is initialized and pushed to the current navigation constroller stack
    if(self.txtTitleView.text.length == 0)
    {
        [self showEmptyWarning];
    }
    else
    {
        [self.model setTitle:self.txtTitleView.text];
        [self.model setDetail:self.txtDetailView.text];
        if(firstQuestion != nil)
        {
            [self.navigationController pushViewController:firstQuestion animated:YES];
        }
        else
        {
            [self createFirstQuestion];
        }
    }
}

- (void)buildQuestionList:(int)currentTotalNumberOfQuestion
{
    //EFFECTS:
    //1) a list of question numbers is builded for all questions popover (navigate from one question to another)
    //2) list looks like: Question 1
    //                    Question 2
    //                    Question 3
    for(int i=0; i<currentTotalNumberOfQuestion; i++)
    {
        NSMutableString* currentQuestion = [NSMutableString stringWithString:@"Question "];
        [currentQuestion appendString:[NSString stringWithFormat:@"%d",i+1]];
        
        [questionList addObject:currentQuestion];
    }
}

-(void)viewListOfQuestions:(id)sender
{
    //EFFECTS:
    //a popover contains a list of current questions available is shown
    if(!popoverQuestionListController)
    {
        int currentTotalNumberOfQuestion = [self.model getNumberOfQuestion];
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

-(void)hideKeyboard
{
    //EFFECTS:
    //dismiss current activated keyboard
    if([self.txtTitleView isFirstResponder])
    {
        [self.txtTitleView resignFirstResponder];
    }
    if([self.txtDetailView isFirstResponder])
    {
        [self.txtDetailView resignFirstResponder];
    }
}

-(void)saveSurvey
{
    //EFFECTS:
    //currenct survey object is updated and saved to database by calling deleage method in project level
    if(self.txtTitleView.text.length == 0)
    {
        [self showEmptyWarning];
    }
    else
    {
        self.model.title = self.txtTitleView.text;
        self.model.detail = self.txtDetailView.text;
        if(firstQuestion != nil)
        {
            if([self isMandotaryFieldsOfAllQuestionsFilled])
            {
                [firstQuestion saveCurrentQuestionAndSubsequentQuestions];
                [self.delegate saveSurvey:self.model];
                [self dismissModalViewControllerAnimated:YES];
            }
            else
            {
                [self showEmptyWarning];
            }
        }
        else
        {
            [self.delegate saveSurvey:self.model];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

-(BOOL)isMandotaryFieldsOfAllQuestionsFilled
{
    //EFFECTS:
    //currenct survey object is updated and saved to database by calling deleage method in project level
    return [firstQuestion isMandotaryFieldsOfAllQuestionsFilled];
}
#pragma end


#pragma show warnings
-(void)showEmptyWarning
{
    //REQUIRES:
    //at least one mandotary field is empty
    //EFFECTS:
    //currenct survey object is updated and saved to database by calling deleage method in project level
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"Mandatory Field Not Filled"
                                                               message:@"Please fill in mandatory fields before proceeding!"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStyleDefault;
    warningAlertView.tag = 1;
    [warningAlertView show];
}
#pragma end


#pragma delegation methods of CreateQuestionViewController
-(void)createEmptyQuestionModel
{
    //EFFECTS:
    //an empty question model is added to current survey model
    [self.model addEmptyQuestion];
}

-(void)removeCurrentQuestionModel:(int)index
{
    //EFFECTS:
    //an empty question model is added to current survey model
    [self.model deleteQuestionAtIndex:index];
}

-(void)updateQuestionToSurveyWithTitle:(NSString*)title Type:(NSString*)type Options:(NSMutableArray*)optionList Index:(int)index
{
    //EFFECTS:
    //a question is updated to current survey
    [self.model updateQuestionWithTitle:title Type:type Options:optionList Index:index];
}

-(void)finishEditingSuvey
{
    //REQUIRES: mandotary fields of all questions are filled
    //EFFECTS:current survey title, detail interface is dismissed and survey model is saved to current project
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate saveSurvey:self.model];
}

-(int)getNumberOfQuestion
{
    //EFFECTS:returns total number of questions created in current survey
    return [self.model getNumberOfQuestion];
}

-(void)changeFirstQuestion:(CreateQuestionViewController*)sender
{
    //EFFECTS:instant variable firstQuestion is assigned to another CreateQuestionViewController object
    firstQuestion = sender;
}

-(NSArray*)getQuestionInfoFromModelWithIndex:(int)index
{
    //EFFECTS: the info of specific question is extracted from current survey
    return [self.model getQuestionInfoWithIndex:index];
}

-(void)switchToQuestionWithIndex:(int)index
{
    //EFFECTS: a specific question interface is shown
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    NSMutableArray* result = [firstQuestion getTheMatchedControllerWithIndex:index controllerArray:resultArray];
    
    for(int i=0; i<result.count-1; i++)
    {
        [self.navigationController pushViewController:[result objectAtIndex:i] animated:NO];
    }
    
    [self.navigationController pushViewController:[result objectAtIndex:result.count-1] animated:YES];
    [popoverQuestionListController dismissPopoverAnimated:YES];
}
#pragma end


#pragma textField and textview delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtTitleView) {
        [self.txtDetailView becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //EFFECTS: limit the survey title length to 100 characters
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 100) ? NO : YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //EFFECTS: limit the survey detail length to 500 characters
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 500) ? NO : YES;
}
#pragma end


#pragma default
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTxtTitleView:nil];
    [self setTxtDetailView:nil];
    [self setMyBackgroundView:nil];
    [self setTxtTitleView:nil];
    [self setTxtDetailView:nil];
    [self setMyBackgroundView:nil];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
#pragma end

@end
