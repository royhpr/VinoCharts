//
//  ProjectDiagramsViewController.m
//  VinoCharts
//
//  Created by Hendy Chua on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ProjectDiagramsViewController.h"
#import "EditDiagramController.h"
#import "NewDiagramController.h"

@interface ProjectDiagramsViewController ()

@end

@implementation ProjectDiagramsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadModelsArrayAndRepresentationArray];
    [self fillUpTiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNavBar {
    NSString *navBarTitleString = @"Diagrams in Project";
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"transitToViewSelectedDiagram"]) {
        EditDiagramController* eDC = (EditDiagramController*)[segue destinationViewController];
        eDC.delegate = self;
        eDC.requestToLoadDiagramModel = YES;
        eDC.requestedDiagram = diagramSelected;
    }
    if ([[segue identifier] isEqualToString:@"transitToCreateDiagram"]) {
        ((NewDiagramController*)[[segue destinationViewController] topViewController]).projectDiagramsVC=self;
    }
}

- (void)showCreateDiagramView {
    [self performSegueWithIdentifier:@"transitToCreateDiagram" sender:self];
}

// overriding superclass displaytilesviewcontroller methods

- (void)reloadModelsArrayAndRepresentationArray {
    self.modelsArray = [self.thisProject.diagrams copy];
    
    if (self.modelsRepresentationArray != nil) {
        for (DiagramOverviewViewController *d in self.modelsRepresentationArray) {
            [d.tileImageView removeFromSuperview];
        }
        [self.modelsRepresentationArray removeAllObjects];
        self.modelsRepresentationArray = nil;
    }
    self.modelsRepresentationArray = [NSMutableArray array];
    
    for (Diagram* d in self.modelsArray) {
        DiagramOverviewViewController *dovc = [[DiagramOverviewViewController alloc] initWithModel:d Delegate:self];
        [self.modelsRepresentationArray addObject:dovc];
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
    // Set the right bar button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Create Diagram +" style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(showCreateDiagramView)];
    [self.tabBarController.navigationItem setRightBarButtonItem:addButton];
}

-(void)finishDeletingMode {
    [super finishDeletingMode];
    [self setRightBarButtonToDefaultMode];
}

// TileControllerDelegate methods

-(void)tileSelected:(id)model {
    diagramSelected = model;
    [self performSegueWithIdentifier:@"transitToViewSelectedDiagram" sender:self];
}

-(void)longPressActivated {
    [self setRightBarButtonToDeletingMode];
    [self showDeleteButtonOnTiles];
}



#pragma mark - EditDiagramControlleDelegate Methods

-(void)saveANewDiagram:(Diagram *)diagram{
    [self.thisProject addDiagramsObject:diagram];
    [self reloadModelsArrayAndRepresentationArray];
    [self fillUpTiles];
}

-(void)updateDiagram:(Diagram*)diagram
{
    NSArray* diagrams = self.thisProject.diagrams;
    
    BOOL foundSimilarDiagramToOverwrite = NO;
    
    for(int i=0 ; i<diagrams.count ; i++){
        if([diagrams objectAtIndex:i] == diagram){
            [self.thisProject updateDiagramAtIndex:i With:diagram];
            foundSimilarDiagramToOverwrite = YES;
            break;
        }
    }
    
    if (!foundSimilarDiagramToOverwrite) {
        [self saveANewDiagram:diagram];
    }
    
    [self reloadModelsArrayAndRepresentationArray];
    [self fillUpTiles];
}

-(NSString*)getProjectTitle {
    return self.thisProject.title;
}

//need to change to index
-(void)deleteTile:(id)model {

    // delete the actual diagram object
    for (int i=0 ; i<[self.modelsArray count] ; i++) {
        if([self.modelsArray objectAtIndex:i]==model){
            [self.thisProject removeDiagramAtIndex:i];
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

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
