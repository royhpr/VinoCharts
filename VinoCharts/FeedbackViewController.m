//
//  ViewController.m
//  DelegationProblem
//
//  Created by Roy Huang Purong on 4/9/13.
//  Copyright (c) 2013 nus.3217. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)viewDidLoad
{
	//EFFECTS: 1) set up feedback view outlook
	//		   2) initialize diagram info
	//         3) set up a list of question and answer sections	
    [super viewDidLoad];
    questionArray = [[NSMutableArray alloc]initWithArray:self.model.questionArray];
    answerArray = [[NSMutableArray alloc]initWithArray:self.model.answerArray];
    feedbackTitle = self.model.title;
    
    self.myCanvasView.layer.borderWidth = 0.5f;
    self.myCanvasView.layer.borderColor = [[UIColor grayColor]CGColor];
    
    listOfDiagramInfo = [[self.delegate getListOfDiagrams] copy];
    
    QASectionView* previousSectionView;
    for(int i=0; i<questionArray.count; i++)
    {
        QASectionView* newSectionView = [[QASectionView alloc]initWithQuestion:[questionArray objectAtIndex:i] Answer:[answerArray objectAtIndex:i]];
        if(previousSectionView != nil)
        {
            newSectionView.frame = CGRectMake(previousSectionView.frame.origin.x, previousSectionView.frame.origin.y + previousSectionView.frame.size.height + 20.0,newSectionView.frame.size.width, newSectionView.frame.size.height);
        }
        else
        {
            newSectionView.frame = CGRectMake(50.0, 50.0, newSectionView.frame.size.width, newSectionView.frame.size.height);
        }
        newSectionView.delegate = self;
        [self.myCanvasView addSubview:newSectionView];
        previousSectionView = newSectionView;
    }
    
    self.myCanvasView.contentSize = CGSizeMake(self.myCanvasView.contentSize.width, previousSectionView.frame.origin.y + previousSectionView.frame.size.height + 30.0);
    self.title = feedbackTitle;
    
    //Set the diagram info
    [self initializeAndDisplayDiagramInfo];
    
    //Set the background image
    self.myCanvasView.backgroundColor = [UIColor whiteColor];
}

-(void)initializeAndDisplayDiagramInfo
{
	//EFFECTS: generate diagram info
    if(listOfDiagramInfo != nil)
    {
        [self.numberOfNotesLeft setHidden:NO];
        //Set the diagram button text
        [self updateButtonTitleWithIndex:0];
        //Set the note title and index
        currentDiagramIndex = 0;
        NSMutableString* noteInfo = [NSString stringWithFormat:@"You can create %@ more notes in the selected diagram. (Max. 100)", [NSMutableString stringWithString:[[listOfDiagramInfo objectAtIndex:1]objectAtIndex:0]]];
        [self.numberOfNotesLeft setText:noteInfo];
    }
    else
    {
        [self.numberOfNotesLeft setHidden:YES];
        [self.btnDiagram setTitle:@"No Diagram (Create 1?)"];
    }
}

#pragma QASectionView delegate methods
-(void)CreateNoteWithText:(NSString*)selectedString
{
	//EFFECTS: 1) check if there exists at least one diagram
	//		   2) if yes, check if there still exists some available notes
	//		   3) if yes, ask project level to create a new note with content provided		
    if(listOfDiagramInfo == nil)
    {
        [self showEmptyDiagramWarning];
    }
    else
    {
        int currentNumberOfNotesLeft = [[[listOfDiagramInfo objectAtIndex:1]objectAtIndex:currentDiagramIndex] intValue];
        if(currentNumberOfNotesLeft == 0)
        {
            [self showReachNumberOfNoteLimitWarning];
        }
        else
        {
            currentNumberOfNotesLeft--;
            [[listOfDiagramInfo objectAtIndex:1]replaceObjectAtIndex:currentDiagramIndex withObject:[NSString stringWithFormat:@"%d",currentNumberOfNotesLeft]];
            
            NSMutableString* noteInfo = [NSString stringWithFormat:@"You can create %@ more notes in the selected diagram. (Max. 100)", [NSMutableString stringWithString:[[listOfDiagramInfo objectAtIndex:1]objectAtIndex:currentDiagramIndex]]];
            [self.numberOfNotesLeft setText:noteInfo];
            
            [self.delegate CreateNoteWithContent:selectedString InDiagramIndex:currentDiagramIndex];
            [self showSuccessfulCreationMessageWithNoteContent:selectedString];
        }
    }
}

-(void)showEmptyDiagramWarning
{
	//REQUIRES: only called when there is no diagram in current projects
	//EFFECTS: a pop up box shown to indicate that there is no diagram in curren project and ask user to create one
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"No Diagram Available"
                                                               message:@"Please enter a diagram name below to create one:"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Submit", nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    warningAlertView.tag = 2;
    [warningAlertView show];
}

-(void)showCreateNewDiagramMessage
{
	//EFFECTS: prompt user to enter a name for a new diagram and proceed to create one
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"Create New Diagram"
                                                               message:@"Please enter a diagram name:"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Submit", nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    warningAlertView.tag = 2;
    [warningAlertView show];
}

-(void)showReachNumberOfNoteLimitWarning
{
	//REQUIRES: this is only called when there is no available note in one diagram
	//EFFECTS: a message shows that no more notes available for current diagram
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"Note Not Created"
                                                               message:@"No more notes available for current diagram"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStyleDefault;
    warningAlertView.tag = 1;
    [warningAlertView show];
}

-(void)ShowMaximumContentSizeWarning
{
	//EFFECTS: a message shows that the number of characters in one note must be limited to 140 when user select a portion of charactor (>140) and try to create a note
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"Note Not Created"
                                                               message:@"Exceeded maximum number of characters: 140"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStyleDefault;
    warningAlertView.tag = 1;
    [warningAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* title;
    NSArray* returnedList;
    
    if(alertView.tag == 2)
    {
        switch (buttonIndex)
        {
            case 0:
                
                break;
            case 1:
                title = [[alertView textFieldAtIndex:0]text];
                returnedList = [self.delegate CreateAndReturnListOfDiagramsDiagramNamed:title];
                
                if(returnedList == nil)
                {
                    listOfDiagramInfo = nil;
                }
                else
                {
                    listOfDiagramInfo = [NSMutableArray arrayWithArray:returnedList];
                }
                [self initializeAndDisplayDiagramInfo];
                break;
                
            default:
                break;
        }
    }
}
#pragma end

-(void)showSuccessfulCreationMessageWithNoteContent:(NSString*)content
{
	//EFFECTS: a message shows that a note has been successfully created
    NSMutableString* message = [NSMutableString stringWithString:@"A note with content: "];
    [message appendString:content];
    [message appendString:@" has been created"];
    
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"Note Created"
                                                               message:message
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStyleDefault;
    warningAlertView.tag = 1;
    [warningAlertView show];
}

#pragma update the title of diagram button
-(void)updateButtonTitleWithIndex:(int)index
{
	//EFFECTS: reflect the name of current selected diagram on the diagram button title
    NSMutableString* buttonTitle = [NSString stringWithFormat:@"Selected Diagram: %@",[[listOfDiagramInfo objectAtIndex:0]objectAtIndex:index]];
    
    
    if(buttonTitle.length > 35)
    {
        NSMutableString* newTitle = [NSMutableString stringWithString:[buttonTitle substringToIndex:32]];
        [newTitle appendString:@"..."];
        [self.btnDiagram setTitle:newTitle];
    }
    else
    {
        [self.btnDiagram setTitle:buttonTitle];
    }
    
    NSMutableString* noteInfo = [NSString stringWithFormat:@"You can create %@ more notes in the selected diagram. (Max. 100)", [NSMutableString stringWithString:[[listOfDiagramInfo objectAtIndex:1]objectAtIndex:index]]];
    [self.numberOfNotesLeft setText:noteInfo];
    [popoverDiagramList dismissPopoverAnimated:YES];
    
    currentDiagramIndex = index;
}

-(void)createNewDiagram
{
    [self showCreateNewDiagramMessage];
    [popoverDiagramList dismissPopoverAnimated:YES];
}
#pragma end

- (IBAction)backToMainInterface:(id)sender
{
    [popoverDiagramList dismissPopoverAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    [popoverDiagramList dismissPopoverAnimated:YES];
}

- (void)createNewDiagramListPopover
{
	//EFFECTS: update current diagram list in the popover
    DiagramListViewController* controller = [[DiagramListViewController alloc]initWithDiagramList:[listOfDiagramInfo objectAtIndex:0]];
    controller.delegate = self;
    
    popoverDiagramList = [[UIPopoverController alloc]initWithContentViewController:controller];
}

- (IBAction)showDiagramList:(id)sender
{
	//EFFECTS: a popover contains a list of diagram info is shown
    if(listOfDiagramInfo != nil)
    {
        if(!popoverDiagramList)
        {
            [self createNewDiagramListPopover];
            [popoverDiagramList presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            if([popoverDiagramList isPopoverVisible])
            {
                [popoverDiagramList dismissPopoverAnimated:YES];
            }
            else
            {
                popoverDiagramList = nil;
                
                [self createNewDiagramListPopover];
                [popoverDiagramList presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
    }
    else
    {
        [self showEmptyDiagramWarning];
    }
}

// Override to allow orientations other than the default portrait orientation.
// Rotation for v. 5.1.1
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setNumberOfNotesLeft:nil];
    [self setMyCanvasView:nil];
    [self setBtnDiagram:nil];
    [super viewDidUnload];
}

@end
