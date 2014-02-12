//
//  ProjectDetailsViewController.m
//  VinoCharts
//
//  Created by Hendy Chua on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ProjectDetailsViewController.h"

#define MAX_TITLE_CHARS 50
#define MAX_DETAILS_CHARS 500

@interface ProjectDetailsViewController ()

@end

@implementation ProjectDetailsViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(userShowKeyboard) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(userHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(keyboardHidden) name:UIKeyboardDidHideNotification object:nil];
    
    self.detailsTextView.layer.borderWidth = 0.5f;
    self.detailsTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.detailsTextView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.detailsTextView.layer.cornerRadius = 5.0f;
    
    [self displayTitleAndDetails];
    if (wantToDisplayInEditMode == YES) {
        [self.titleTextField becomeFirstResponder];
        // dont have to call [self goIntoEditMode] because when a textfield is set to be firstresponder
        // the keyboard will show, and we call goIntoEditMode in the observer for that.
    } else {
        [self goIntoViewMode];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.surveyNumberLbl.text = [NSString stringWithFormat:@"Surveys Created: %d",self.thisProject.surveys.count];
    self.feedbackNumberLbl.text = [NSString stringWithFormat:@"Feedbacks Collected: %d",self.thisProject.feedbacks.count];
    self.diagramNumberLbl.text = [NSString stringWithFormat:@"Diagrams Drawn: %d",self.thisProject.diagrams.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleTextField:nil];
    [self setDetailsTextView:nil];
    [self setSaveBtn:nil];
    [self setFeedbackNumberLbl:nil];
    [self setDiagramNumberLbl:nil];
    [self setSurveyNumberLbl:nil];
    [super viewDidUnload];
}

-(void)displayTitleAndDetails {
    self.titleTextField.text = self.thisProject.title;
    self.detailsTextView.text = self.thisProject.details;
}

-(void)setNavBar {
    NSString *projectTitle = @"Project Details";
    UILabel *navBarTitle = (UILabel *)self.navigationItem.titleView;
    if (!navBarTitle) {
        navBarTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        navBarTitle.backgroundColor = [UIColor clearColor];
        navBarTitle.font = [UIFont boldSystemFontOfSize:20.0];
        navBarTitle.textColor = [UIColor whiteColor];
        [navBarTitle setText:projectTitle];
        [navBarTitle sizeToFit];
        self.tabBarController.navigationItem.titleView = navBarTitle;
    }
    
    [self setRightBarButton];
}

-(void)setRightBarButton {
    if([[DBSession sharedSession] isLinked]){
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Sync Project"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action:@selector(syncProject)];
        [self.tabBarController.navigationItem setRightBarButtonItem:addButton];
    } else {
        [self.tabBarController.navigationItem setRightBarButtonItem:nil];
    }
}

-(void)syncProject{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Syncing..."
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:nil];
    [self.tabBarController.navigationItem setRightBarButtonItem:addButton];
    
    self.thisProject.fileDelegate = self;
    [self.thisProject createSingleProjectFileInTemporaryDirectory];
}

-(void)fileCreated{
    //Project FileCreatedDelegate protocol implementation
    [[DropboxViewController sharedDropbox] setSyncDelegate:self];
    [[DropboxViewController sharedDropbox] uploadFileAtTemporaryDirectoryToFolder:self.thisProject.title];
}

-(void)syncDone{
    //DropboxSyncDelegate
    [self setRightBarButton];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [self.detailsTextView becomeFirstResponder];
    }
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self displayTitleAndDetails];
    [self setNavBar];
}

- (IBAction)saveNewDetails:(id)sender {
    BOOL saveSuccess = [self saveProject];

    if (saveSuccess == YES) {
        saveUnsuccessful = NO;
        [self goIntoViewMode];
    } else {
        [self goIntoEditMode];
    }
}

-(void)userShowKeyboard {
    [self goIntoEditMode];
}

-(void)userHideKeyboard {
    BOOL succ = [self saveProject];
    if (succ==YES) {
        saveUnsuccessful = NO;
        [self goIntoViewMode];
    } else {
        saveUnsuccessful = YES;
    }
}

-(void)keyboardHidden {
    if (saveUnsuccessful) {
        [self.titleTextField becomeFirstResponder];
    }
}

-(BOOL)saveProject {
    NSString *title = self.titleTextField.text;
    NSString *details = self.detailsTextView.text;
    
    BOOL succ = NO;
    
    if (title.length <= 0 || title.length > MAX_TITLE_CHARS) {
        [[[UIAlertView alloc] initWithTitle:@"Project title error"
                                    message:@"Project title cannot be empty and it cannot exceed 50 characters."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
        succ = NO;
        
    } else if (details.length > MAX_DETAILS_CHARS) {
        [[[UIAlertView alloc] initWithTitle:@"Project details error"
                                    message:@"Project details cannot exceed 500 characters."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
        succ = NO;
        
    } else if ([self.delegate projectTitleTaken:title  CompareWithThisProject:self.thisProject]==YES) {
        NSString *errorMsg = [NSString stringWithFormat:@"You already have an existing project titled %@. Please choose another title.", title];
        [[[UIAlertView alloc] initWithTitle:@"Project title taken."
                                    message:errorMsg
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
        succ = NO;
    } else {
        self.thisProject.title = title;        
        self.thisProject.details = details;
        succ = YES;
    }
    
    return succ;
}

-(void)goIntoEditMode {
    [self.tabBarController.navigationItem setHidesBackButton:YES];
    [self.saveBtn setHidden:NO];
}

-(void)goIntoViewMode {
    [self.tabBarController.navigationItem setHidesBackButton:NO];
    [self.saveBtn setHidden:YES];
    [self.view endEditing:YES];
}

-(void)setWantToDisplayInEditModeWithBool:(BOOL)b {
    wantToDisplayInEditMode = b;
}
@end
