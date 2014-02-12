//
//  NewDiagramController.m
//  vinocharts_diagrams
//
//  Created by Lee Jian Yi David on 3/25/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "NewDiagramController.h"
#import "EditDiagramController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Diagram.h"


@interface NewDiagramController ()
@property (readwrite) NSNumberFormatter* formatter;
@end

@implementation NewDiagramController


- (void)viewDidLoad
{
    [super viewDidLoad]; // Do any additional setup after loading the view.
    
    [_widthIO setText:[NSString stringWithFormat:@"%d",CANVAS_DEFAULT_WIDTH]];
    [_heightIO setText:[NSString stringWithFormat:@"%d",CANVAS_DEFAULT_HEIGHT]];
    
    [_widthIO setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [_heightIO setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    
    [_widthIO setDelegate:self];
    [_heightIO setDelegate:self];
    [_titleIO setDelegate:self];
    [_titleIO becomeFirstResponder];
    
    _formatter = [[NSNumberFormatter alloc] init];
    [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSNumber* w = [_formatter numberFromString:_widthIO.text];
    NSNumber* h = [_formatter numberFromString:_heightIO.text];
    double w_dbl = [w doubleValue];
    double h_dbl = [h doubleValue];
    NSString* title = [_titleIO text];
    
    
    // If canvas dimensions are too small ...
    if (h_dbl < NOTE_DEFAULT_HEIGHT) {
        [self raiseUIAlert:[NSString stringWithFormat:@"Height is too small. Height should be larger than %d. Height has been automatically set to %d.",NOTE_DEFAULT_HEIGHT,NOTE_DEFAULT_HEIGHT]];
        h_dbl = NOTE_DEFAULT_HEIGHT;
    }
    if (w_dbl < NOTE_DEFAULT_WIDTH) {
        [self raiseUIAlert:[NSString stringWithFormat:@"Width is too small. Width should be larger than %d. Width has been automatically set to %d.",NOTE_DEFAULT_WIDTH,NOTE_DEFAULT_WIDTH]];
        w_dbl = NOTE_DEFAULT_WIDTH;
    }
    // If canvas dimensions are too big ...
    if (h_dbl > CANVAS_HEIGHT_UPPERLIM) {
        [self raiseUIAlert:[NSString stringWithFormat:@"Height is too big. Height should be smaller than %d. Height has been automatically set to %d.",CANVAS_HEIGHT_UPPERLIM,CANVAS_HEIGHT_UPPERLIM]];
        h_dbl = CANVAS_HEIGHT_UPPERLIM;
    }
    if (w_dbl > CANVAS_WIDTH_UPPERLIM) {
        [self raiseUIAlert:[NSString stringWithFormat:@"Width is too big. Width should be smaller than %d. Width has been automatically set to %d.",CANVAS_WIDTH_UPPERLIM,CANVAS_WIDTH_UPPERLIM]];
        w_dbl = CANVAS_HEIGHT_UPPERLIM;
    }
    // If title is too long ...
    if (title.length > DIAGRAM_TITLE_CHAR_LIM) {
        [self raiseUIAlert:[NSString stringWithFormat:@"Title cannot exceed %d characters. Title truncated.",DIAGRAM_TITLE_CHAR_LIM]];
        NSString* truncatedTitle = [title substringToIndex:DIAGRAM_TITLE_CHAR_LIM-1-3];
        truncatedTitle = [truncatedTitle stringByAppendingString:@"..."];
        title = truncatedTitle;
    }
    
    if ([segue.identifier isEqualToString:@"EditDiagramController"]) {
        EditDiagramController *eDC = [segue destinationViewController];
        Diagram* modelToPass = [[Diagram alloc]initDefaultWithTitle:title];
        [modelToPass setDimensionsWidth:w_dbl Height:h_dbl];
        eDC.requestedDiagram = modelToPass;
        eDC.requestToLoadDiagramModel = YES;
        eDC.delegate = _projectDiagramsVC;
    }
    
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if((toInterfaceOrientation == UIDeviceOrientationLandscapeRight) ||
       (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft))
        return YES;
    else
        return NO;
}


/******* UITextFieldDelegate method *******/
/*
 ** The delegate method below concerns editing of the text in the width and height I/O.
 ** Content is enforced here.
 */

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    if ([_heightIO isFirstResponder] || [_widthIO isFirstResponder]) {
        NSString* futureContentOfTextField = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSNumber* value = [_formatter numberFromString:futureContentOfTextField];
        
        // If input is not a number ...
        if (value == nil) {
            [self raiseUIAlert:@"Must be a number."];
            return NO;
        }
    }
    
    return YES;
}


-(void)raiseUIAlert:(NSString*)title{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}

- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    [self setHeightIO:nil];
    [self setWidthIO:nil];
    [self setTitleIO:nil];
    [super viewDidUnload];
}











#pragma mark - Don't Care
/* Don't care about stuff below this line */
/********************************************************************************/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
