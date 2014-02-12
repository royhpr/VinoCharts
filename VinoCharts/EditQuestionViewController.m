//
//  EditQuestionViewController.m
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EditQuestionViewController.h"

@interface EditQuestionViewController ()

@end

@implementation EditQuestionViewController

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
    //EFFECTS: 1) beautify outlook of interface
    //         2) initialize navigation toolbar items
    //         3) initialize keyboard
    [super viewDidLoad];
    [self addGestureRecognizerToDismissKeyboard];
    [self removeImageViews];
    [self.titleView becomeFirstResponder];
    self.optionArea.contentSize = CGSizeMake(self.optionArea.frame.size.width, self.optionArea.frame.size.height + 450.0);
    
    //Update title and content
    NSArray* currentQuestionInfo = [self.delegate getQuestionInfoFromModelWithIndex:QuestionIndex];
    
    //Initialize view content if current question is not a newly created one
    if(currentQuestionInfo.count != 0)
    {
        self.titleView.text = currentQuestionInfo[0];
        
        if([currentQuestionInfo[1] isEqualToString:@"Open End"])
        {
            [self setUpOpenEndedOption:currentQuestionInfo];
        }
        else if([currentQuestionInfo[1] isEqualToString:@"Radio Button"])
        {
            [self setUpRadioButtonOption:currentQuestionInfo];
        }
        else
        {
            [self setUPCheckBoxOption:currentQuestionInfo];
        }
    }
    [self setUpInterfaceOutlook];
    [self createInputAccessoryView];
    [self setKeyboardButtons];
}

- (void)viewWillAppear:(BOOL)animated
{
    //EFFECTS: register for keyboard notifications
    //         update interface title
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    //Update navigation bar items
    if((QuestionIndex + 1) == MAX_QUESTION)
    {
        [self addNavigationBarItemsWhenNumberOfQuestionReachesLimit];
    }
    else if((QuestionIndex + 1) == [self.delegate getNumberOfQuestion])
    {
        [self addNavigationBarItemsWhenCurrentQuestionIsLastQuestion];
    }
    else
    {
        [self addNavigationBarItemsInNormalCase];
    }
    [self updateInterfaceTitle];
}


#pragma instant methods
-(void)removeImageViews
{
    NSArray* subviews = [self.optionArea subviews];
    
    for(UIView* subview in subviews)
    {
        if([subview isKindOfClass:[UIImageView class]])
        {
            [subview removeFromSuperview];
        }
    }
}

- (void)setUPCheckBoxOption:(NSArray *)currentQuestionInfo
{
    //EFFECTS: change the current question type description when checkbox is tapped in segmented control
    [self.typePicker setSelectedSegmentIndex:2];
    questionTitle = currentQuestionInfo[0];
    questionType = @"Check Box";
    optionContentArray = [[NSMutableArray alloc]initWithArray:currentQuestionInfo[2]];
    
    [self loadOptionsWithArray:currentQuestionInfo[2]];
    [self.optionArea setHidden:NO];
    [self.lblDescription setText:@"Surveyees can select multiple options."];
}

- (void)setUpRadioButtonOption:(NSArray *)currentQuestionInfo
{
    //EFFECTS: change the current question type description when radio button is tapped in segmented control
    [self.typePicker setSelectedSegmentIndex:1];
    questionTitle = currentQuestionInfo[0];
    questionType = @"Radio Button";
    optionContentArray = [[NSMutableArray alloc]initWithArray:currentQuestionInfo[2]];
    
    [self loadOptionsWithArray:currentQuestionInfo[2]];
    [self.optionArea setHidden:NO];
    [self.lblDescription setText:@"Surveyees can only select 1 option."];
}

- (void)setUpOpenEndedOption:(NSArray *)currentQuestionInfo
{
    //EFFECTS: change the current question type description when open ended is tapped in segmented control
    [self.typePicker setSelectedSegmentIndex:0];
    questionTitle = currentQuestionInfo[0];
    questionType = @"Open End";
}

- (void)addGestureRecognizerToDismissKeyboard
{
    //EFFECTS: Assign Gesturerecognizer to scroll view (hide keyboard)
    UITapGestureRecognizer* singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.myCanvasView addGestureRecognizer:singleTapGestureRecognizer];
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)setUpInterfaceOutlook
{
    //EFFECTS: adjust the title outlook
    //         set up options outlook
    self.titleView.layer.borderWidth = 0.5f;
    self.titleView.layer.borderColor = [[UIColor grayColor]CGColor];
    self.titleView.layer.cornerRadius = 5.0f;
    
    //set up options outlook
    NSArray* subviews = [self.optionArea subviews];
    for(UITextView* subview in subviews)
    {
        subview.layer.borderWidth = 0.5f;
        subview.layer.borderColor = [[UIColor blackColor]CGColor];
        subview.layer.cornerRadius = 5.0f;
    }
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addNavigationBarItemsWhenNumberOfQuestionReachesLimit
{
    //EFFECTS: add navigation toobar items when number of question reaches 15
    UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteQuestion)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSurvey)];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousQuestion)];
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc]initWithTitle:@"All Questions" style:UIBarButtonItemStylePlain target:self action:@selector(viewListOfQuestions:)];
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    [closeButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:doneButton, backButton, deleteButton, nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:closeButton,menuButton, nil];
}

- (void)addNavigationBarItemsWhenCurrentQuestionIsLastQuestion
{
    //EFFECTS: add navigation toobar items when current question is last question
    UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteQuestion)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSurvey)];
    UIBarButtonItem* newButton = [[UIBarButtonItem alloc]initWithTitle:@"Add Question" style:UIBarButtonItemStylePlain target:self action:@selector(createNewQuestion)];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousQuestion)];
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc]initWithTitle:@"All Questions" style:UIBarButtonItemStylePlain target:self action:@selector(viewListOfQuestions:)];
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    [closeButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:newButton, backButton, doneButton, deleteButton, nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:closeButton,menuButton, nil];
}

- (void)addNavigationBarItemsInNormalCase
{
   //EFFECTS: add normal navigation toobar items
    UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteQuestion)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSurvey)];
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(loadNextQuestion)];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousQuestion)];
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc]initWithTitle:@"All Questions" style:UIBarButtonItemStylePlain target:self action:@selector(viewListOfQuestions:)];
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    [closeButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:nextButton, backButton, doneButton, deleteButton, nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:closeButton, menuButton, nil];
}

-(void)loadOptionsWithArray:(NSMutableArray*)currentArray
{
    //EFFECTS: current option area are filled up with option content
    NSMutableArray* tempArray = [[NSMutableArray alloc]initWithArray:currentArray];
    NSArray* subviews = [self.optionArea subviews];
    
    for(int i=0; i<tempArray.count; i++)
    {
        UITextView* currentOption = (UITextView*)[subviews objectAtIndex:i];
        currentOption.text = [tempArray objectAtIndex:i];
    }
}

- (void)passCurrentQuestionInfoToSurvey
{
    //EFFECTS: it's called when user want to save current question
    NSMutableArray* contentArray = [[NSMutableArray alloc]init];
    NSArray* subviews = [self.optionArea subviews];
    
    [optionContentArray removeAllObjects];
    for(UIView* subview in subviews)
    {
        UITextView* currentOption = (UITextView*)subview;
        if (currentOption.text.length != 0)
        {
            [contentArray addObject:currentOption.text];
            [optionContentArray addObject:currentOption.text];
        }
    }
    
    [self.delegate updateQuestionToSurveyWithTitle:questionTitle Type:questionType Options:contentArray Index:QuestionIndex];
}

-(void)saveCurrentQuestion
{
    //EFFECTS: save current question to current survey model
    //title
    questionTitle = self.titleView.text;
    
    switch (self.typePicker.selectedSegmentIndex)
    {
        case 0:
            questionType = @"Open End";
            break;
        case 1:
            questionType = @"Radio Button";
            break;
            
        case 2:
            questionType = @"Check Box";
            break;
            
        default:
            break;
    }
    
    [self passCurrentQuestionInfoToSurvey];
}

-(void)saveCurrentQuestionAndSubsequentQuestions
{
    [self saveCurrentQuestion];
    if(self.nextController != nil)
    {
        [self.nextController saveCurrentQuestionAndSubsequentQuestions];
    }
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
            //Keep pushing
            [self.nextController pushToDestinatedControllerWithIndex:index];
        }
    }
    else
    {
        EditQuestionViewController* newQuestion = [[EditQuestionViewController alloc]initWithQuestionIndex:(QuestionIndex + 1)];
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

-(void)createInputAccessoryView
{
    //EFFECTS: configure the items in input accessory view which is above keyboard
    self.inputAccView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 1024.0, 40.0)];
    [self.inputAccView setBackgroundColor:[UIColor  darkGrayColor]];
    
    self.btnPrev = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [self.btnPrev setFrame: CGRectMake(0.0, 0.0, 80.0, 40.0)];
    [self.btnPrev setTitle: @"Previous" forState: UIControlStateNormal];
    [self.btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents: UIControlEventTouchUpInside];
    
    self.btnNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.btnNext setFrame:CGRectMake(85.0f, 0.0f, 80.0f, 40.0f)];
    [self.btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [self.btnNext addTarget:self action:@selector(gotoNextTextfield) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.btnDone setFrame:CGRectMake(944.0, 0.0f, 80.0f, 40.0f)];
    [self.btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [self.btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    
    [self.inputAccView addSubview:self.btnPrev];
    [self.inputAccView addSubview:self.btnNext];
    [self.inputAccView addSubview:self.btnDone];
}

-(void)setKeyboardButtons
{
    //EFFECTS: add this input accessory view to each option text view
    NSArray* subviews = [self.optionArea subviews];
    
    for(UITextView* subview in subviews)
    {
        [subview setInputAccessoryView:self.inputAccView];
    }
}

#pragma end

#pragma keyboard navigation view
-(void)gotoPrevTextfield
{
    //EFFECTS: go to next option textview. it will focus first option when current option is 10th option
    NSArray* subviews = [self.optionArea subviews];
    
    if(activeView.tag == 1)
    {
        for(UITextView* subview in subviews)
        {
            if(subview.tag == 10)
            {
                [subview becomeFirstResponder];
                break;
            }
        }
    }
    else
    {
        for(UITextView* subview in subviews)
        {
            if(subview.tag == activeView.tag - 1)
            {
                [subview becomeFirstResponder];
                break;
            }
        }
    }
}

-(void)gotoNextTextfield
{
    //EFFECTS: go to previous option textview. it will focus 10th option when current option is first option
    NSArray* subviews = [self.optionArea subviews];
    
    if(activeView.tag == 10)
    {
        for(UITextView* subview in subviews)
        {
            if(subview.tag == 1)
            {
                [subview becomeFirstResponder];
                break;
            }
        }
    }
    else
    {
        for(UITextView* subview in subviews)
        {
            if(subview.tag == activeView.tag + 1)
            {
                [subview becomeFirstResponder];
                break;
            }
        }
    }
}

-(void)doneTyping
{
	//EFFECTS: dismiss keyboard
    [activeView resignFirstResponder];
}
#pragma end

#pragma Navigation Bar delegation methods
-(void)deleteQuestion
{
	//EFFECTS: current CreateQuestionViewController is removed from navigation controller stack
    //         the previous and next view controllers are changed accordingly
    if(self.previousController == nil)
    {
        [self.delegate changeFirstQuestion:self.nextController];
    }
    self.previousController.nextController = self.nextController;
    self.nextController.previousController = self.previousController;
    
    [self.delegate removeCurrentQuestionModel:QuestionIndex];
    
    //Update quesiton index
    [self.nextController updateQuestionIndex];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveSurvey
{
	//EFFECTS:current survey model is saved to database

    //Check if mandatory fields are filled
    if(![self isMandotaryFieldsOfAllQuestionsFilled])
    {
        [self showEmptyFieldAlert];
    }
    else
    {
        [self saveCurrentQuestionAndSubsequentQuestions];
        [self.delegate finishEditingSuvey];
    }
}

- (void)constructNewQuestion
{
    //EFFECTS: configure and show current question in edit mode
	
    EditQuestionViewController* newQuestion = [[EditQuestionViewController alloc]initWithQuestionIndex:(QuestionIndex + 1)];
    self.nextController = newQuestion;
    newQuestion.previousController = self;
    newQuestion.delegate = self.delegate;
    
    [self.navigationController pushViewController:newQuestion animated:YES];
}

-(void)createNewQuestion
{
	//EFFECTS: create a new question after save current question

    //Check if mandatory fields are filled
    if(![self isMandotaryFieldFilled])
    {
        [self showEmptyFieldAlert];
    }
    else
    {
        //Save current quesiton
        [self saveCurrentQuestion];
        
        //Create a new empty question model in survey model
        [self.delegate createEmptyQuestionModel];
        [self constructNewQuestion];
    }
}

-(void)backToPreviousQuestion
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)constructNextEditedQuestion
{
	//EFFECTS: a question is created in edit mode
	
    EditQuestionViewController* newQuestion = [[EditQuestionViewController alloc]initWithQuestionIndex:(QuestionIndex + 1)];
    self.nextController = newQuestion;
    newQuestion.previousController = self;
    newQuestion.delegate = self.delegate;
    
    [self.navigationController pushViewController:newQuestion animated:YES];
}

-(void)loadNextQuestion
{
	//EFFECTS: configure and show next editable question

    if(![self isMandotaryFieldFilled])
    {
        [self showEmptyFieldAlert];
    }
    else
    {
        [self constructNextEditedQuestion];
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
	//EFFECTS: show a list of question available in current survey
	
    if(!popoverQuestionListController)
    {
        //Build the items
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
#pragma end


#pragma Check mandotary fields
-(BOOL)isMandotaryFieldsOfAllQuestionsFilled
{
    if(![self isMandotaryFieldFilled])
    {
        return NO;
    }
    if(self.nextController != nil)
    {
        return [self.nextController isMandotaryFieldsOfAllQuestionsFilled];
    }
    return YES;
}

-(BOOL)isMandotaryFieldFilled
{
    if(self.titleView.text.length == 0)
    {
        return NO;
    }
    
    if(self.typePicker.selectedSegmentIndex == 0)
    {
        return YES;
    }
    
    if([self isThereAtLeastOneOption])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

-(BOOL)isThereAtLeastOneOption
{
    NSArray* subviews = [self.optionArea subviews];
    
    for(UIView* subview in subviews)
    {
        UITextView* currentOption = (UITextView*)subview;
        if(currentOption.text.length != 0)
        {
            return YES;
        }
    }
    return NO;
}
#pragma end


#pragma empty field alert
-(void)showEmptyFieldAlert
{
	//EFFECTS: shown whenever there is at least one empty mandotary field detected
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"Mandatory Field(s) Not Filled"
                                                               message:@"Please fill in all mandatory fills before proceeding."
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStyleDefault;
    warningAlertView.tag = 1;
    [warningAlertView show];
}

-(void)updateQuestionIndex
{
	//EFFECTS: update the subsequent question index when curren question is removed from survey model
    QuestionIndex--;
    if(self.nextController != nil)
    {
        [self.nextController updateQuestionIndex];
    }
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
#pragma end


#pragma keyboard events
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.optionArea.scrollEnabled = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //EFFECTS: scroll to first question and disable scrolling
    UITextView* firstOption = (UITextView*)[self.optionArea viewWithTag:1];
    CGPoint firstViewLocation = CGPointMake(0.0, firstOption.frame.origin.y);
    [self.optionArea setContentOffset:firstViewLocation animated:YES];
    
    self.optionArea.scrollEnabled = NO;
}

-(void)hideKeyboard
{
	//EFFECTS: dismiss keyboard
    if(activeView != nil)
    {
        [activeView resignFirstResponder];
    }
    if([self.titleView isFirstResponder])
    {
        [self.titleView resignFirstResponder];
    }
}
#pragma end


#pragma textView Deletation methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activeView = textView;
    
    //Change the scroll view position
    if(textView != self.titleView)
    {
        CGPoint currentOptionPosition = CGPointMake(0.0, activeView.frame.origin.y);
        [self.optionArea setContentOffset:currentOptionPosition animated:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    activeView = nil;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if(textView == self.titleView)
    {
        return (newLength > 500) ? NO : YES;
    }
    else
    {
        return (newLength > 100) ? NO : YES;
    }
}
#pragma end


#pragma Actions
- (IBAction)typePickerSelected:(id)sender
{
	//EFFECTS: update option description content when the segmented control is tapped
    switch (self.typePicker.selectedSegmentIndex)
    {
        case 0:
            [self.optionArea setHidden:YES];
            self.lblDescription.text = @"";
            break;
        case 1:
            [self.optionArea setHidden:NO];
            self.lblDescription.text = @"Surveyees can only select 1 option.";
            break;
        case 2:
            [self.optionArea setHidden:NO];
            self.lblDescription.text = @"Surveyees can select multiple options.";
            break;
            
        default:
            break;
    }
}
#pragma end


#pragma default
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setMyCanvasView:nil];
    [self setTitleView:nil];
    [self setTypePicker:nil];
    [self setOptionArea:nil];
    [self setLblDescription:nil];
    [self setOptionArea:nil];
    [super viewDidUnload];
}
#pragma end

@end
