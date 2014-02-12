//
//  ProjectFeedbacksViewController.m
//  VinoCharts
//
//  Created by Hendy Chua on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ProjectFeedbacksViewController.h"
#define MAX_NOTES 100

@interface ProjectFeedbacksViewController ()

@end

@implementation ProjectFeedbacksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self reloadModelsArrayAndRepresentationArray];
    [self fillUpTiles];
}

-(void)setNavBar {
    NSString *navBarTitleString = @"Feedback Collected";
    UILabel *navBarTitle = (UILabel *)self.navigationItem.titleView;
    if (!navBarTitle) {
        navBarTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        navBarTitle.backgroundColor = [UIColor clearColor];
        navBarTitle.font = [UIFont boldSystemFontOfSize:20.0];
        navBarTitle.textColor = [UIColor whiteColor];
        [navBarTitle setText:navBarTitleString];
        [navBarTitle sizeToFit];
        self.tabBarController.navigationItem.titleView = navBarTitle;
    }
    
    [self setRightBarButtonToDefaultMode];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setNavBar];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"transitToViewFeedback"])
    {
        FeedbackViewController* currentFeedback = (FeedbackViewController*)[[segue destinationViewController] topViewController];
        currentFeedback.model = feedbackSelected;
        currentFeedback.delegate = self;
    }
}

// overriding superclass displaytilesviewcontroller methods

- (void)reloadModelsArrayAndRepresentationArray {
    self.modelsArray = [self.thisProject.feedbacks copy];
    
    if (self.modelsRepresentationArray != nil) {
        for (FeedbackOverviewViewController *f in self.modelsRepresentationArray) {
            [f.tileImageView removeFromSuperview];
        }
        [self.modelsRepresentationArray removeAllObjects];
        self.modelsRepresentationArray = nil;
    }
    self.modelsRepresentationArray = [NSMutableArray array];
    
    for (Feedback* fb in self.modelsArray) {
        FeedbackOverviewViewController *f = [[FeedbackOverviewViewController alloc] initWithModel:fb Delegate:self];
        [self.modelsRepresentationArray addObject:f];
    }
    
}

-(void)setRightBarButtonToDeletingMode {
    UIBarButtonItem *doneDeleting = [[UIBarButtonItem alloc] initWithTitle:@"Done Deleting"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(finishDeletingMode)];
    [doneDeleting setTintColor:[UIColor redColor]];
    [self.tabBarController.navigationItem setRightBarButtonItem:doneDeleting];
}

- (void)setRightBarButtonToDefaultMode {
    [self.tabBarController.navigationItem setRightBarButtonItem:nil];
}

// tileviewcontrollerdelegate methods

-(void)finishDeletingMode {
    [super finishDeletingMode];
    [self setRightBarButtonToDefaultMode];
}

-(void)tileSelected:(id)model {
    feedbackSelected = model;
    [self performSegueWithIdentifier:@"transitToViewFeedback" sender:self];
}

-(void)longPressActivated {
    [self setRightBarButtonToDeletingMode];
    [self showDeleteButtonOnTiles];
}

//need to change to index
-(void)deleteTile:(id)model {
    
    // delete the actual feedback object
    for (int i=0; i<[self.modelsArray count]; i++) {
        if([self.modelsArray objectAtIndex:i]==model){
            [self.thisProject removeFeedbackAtIndex:i];
            break;
        }
    }

    [self reloadModelsArrayAndRepresentationArray];
    [self fillUpTiles];
    
    if (self.modelsArray.count!=0) {
        [self showDeleteButtonOnTiles];
    } else {
        [self finishDeletingMode];
    }
}

//Feedback view controller callback method
-(void)CreateNoteWithContent:(NSString*)content InDiagramIndex:(NSInteger)index
{
    NoteM *newNote = [NoteM defaultModelWithContent:content];
        
    Diagram* thisDiagram = (Diagram*)[self.thisProject.diagrams objectAtIndex:index];
    [thisDiagram.unplacedNotes addObject:newNote];
    
    //save to thisproject
    [self.thisProject updateDiagramAtIndex:index With:thisDiagram];
}

-(NSArray*)CreateAndReturnListOfDiagramsDiagramNamed:(NSString*)name {
    // creates a new diagram with the name and return the list of diagrams in this project.
    
    Diagram *newDiagram = [Diagram defaultWithTitle:name];
    
    [self.thisProject addDiagramsObject:newDiagram];
    return [self getListOfDiagrams];
}

-(NSArray*)getListOfDiagrams {
    // returns an array of 2 arrays.
    // the first nested array is an array of diagram names
    // the second nested array is an array of number of notes that can be created in the diagram
    // the first and second nested arrays are matched by their indexes.
    // if it returns nil, that means there are currently no diagrams in this project.

    if (self.thisProject.diagrams.count == 0) {
        return nil;
    } else {
        NSMutableArray *diagramNames = [NSMutableArray array];
        NSMutableArray *noteCounts = [NSMutableArray array];

        for (int i=0; i<self.thisProject.diagrams.count; i++) {
            Diagram *d = (Diagram*)[self.thisProject.diagrams objectAtIndex:i];
            [diagramNames addObject:d.title];
            [noteCounts addObject:[NSString stringWithFormat:@"%d",(MAX_NOTES-d.placedNotes.count-d.unplacedNotes.count)]];
        }

        NSArray* retArray = [NSArray arrayWithObjects:diagramNames, noteCounts, nil];

        return retArray;
    }
}


@end
