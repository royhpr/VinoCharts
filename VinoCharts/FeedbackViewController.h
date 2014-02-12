//
//  ViewController.h
//  DelegationProblem
//
//  Created by Roy Huang Purong on 4/9/13.
//  Copyright (c) 2013 nus.3217. All rights reserved.
//

/*
This is a custom class of FeedbackViewController. It simply shows a list of sections of question and answers of
one survey. It also allows user to simply highlight a portion of answer to create note. Moreover, it allows user to 
create new diagrams.
*/

#import <UIKit/UIKit.h>
#import "Feedback.h"
#import <QuartzCore/QuartzCore.h>
#import "QASectionView.h"
#import "DiagramListViewController.h"

@class FeedbackViewController;
@protocol FeedbackViewControllerDelegate

@required
-(NSArray*)getListOfDiagrams;
//EFFECTS: get a list of diagram info (diagram name, number of notes available) from projects level

-(void)CreateNoteWithContent:(NSString*)content InDiagramIndex:(NSInteger)index;
//EFFECTS: ask project to create a new note with provided content and specific diagram location

-(NSArray*)CreateAndReturnListOfDiagramsDiagramNamed:(NSString*)name;
//EFFECTS: ask project to create a new diagram and get a list of currently available diagram info in current project
@end

@interface  FeedbackViewController : UIViewController<QASectionViewDelegate,DiagramListViewControllerDelegate>
{
	//Instant variables
    NSString* feedbackTitle;
    NSMutableArray* questionArray;
    NSMutableArray* answerArray;
    
    NSMutableArray* listOfDiagramInfo;
    CGFloat currentScrollViewHeight;
    
    UIPopoverController* popoverDiagramList;
    
    int currentDiagramIndex;
}

#pragma properties
//used to retrieve feedback data
@property(nonatomic,readwrite)Feedback* model;
//delegate object used to notify project level about creation of notes and diagrams
@property(nonatomic,weak)IBOutlet id<FeedbackViewControllerDelegate> delegate;
#pragma end

#pragma IBOutlet
//Subviews reference IBOutlets
@property (strong, nonatomic) IBOutlet UIScrollView *myCanvasView;
@property (strong, nonatomic) IBOutlet UILabel *numberOfNotesLeft;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDiagram;
#pragma end

#pragma controller methods
- (IBAction)backToMainInterface:(id)sender;
//EFFECTS: dismiss current feedback interface and return to single project interface

- (IBAction)showDiagramList:(id)sender;
//EFFECTS: show a popover which contains a list of available diagrams in current project
#pragma end

@end
