//
//  diagramTitleViewController.m
//  VinoCharts
//
//  Created by Lee Jian Yi David on 4/18/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "diagramTitleVC.h"
#import "Constants.h"
#import "ViewHelper.h"
#import "GzColors.h"

@interface diagramTitleVC ()

@property (readwrite, nonatomic, weak) UIView* sheet;
@property (readwrite) UITextView* view;
@property (readwrite) double topOffset;

@end

@implementation diagramTitleVC

@synthesize sheet = _sheet;

-(id)initDefaultOn:(UIView*)mySheet{
    
    _sheet = mySheet; //weak linking.
    
    //Set top offset.
    _topOffset = DIAGRAM_TITLE_DEFAULT_TOP_OFFSET;
    
    //Set frame.
    _view = [[UITextView alloc]initWithFrame:CGRectMake(0, DIAGRAM_TITLE_DEFAULT_TOP_OFFSET, _sheet.bounds.size.width, NOTE_DEFAULT_HEIGHT)];
    
    //Set delegate
    _view.delegate = self;
    
    //Set transparent bg.
    _view.backgroundColor = [UIColor clearColor];
    //Set font size.
    UIFont* dTFont = _view.font;
    UIFont* dtFontBig = [dTFont fontWithSize:40];
    _view.font = dtFontBig;
    //Set default text
    _view.text = @"Insert Title Here";
    
    // Set internal text alignment
    _view.textAlignment = UITextAlignmentCenter;
    // Set alignment on sheet
    _view.center = _sheet.center;
    // Push the frame of the text all the way to the top of sheet.
    _view.frame = CGRectMake(_sheet.frame.origin.x,
                                     0,
                                     _sheet.frame.size.width,
                                     _sheet.frame.size.height);
    // Set color of text
    _view.textColor = [ViewHelper invColorOf:_sheet.backgroundColor];
    
    //Housekeeping
    [self housekeep];
    
    // Show.
    if (_sheet != nil) {
        [_sheet addSubview:_view];
    }
    
    return self;
}


-(id)initWith:(NSString*)myText AndAllElseDefaultOn:(UIView*)mySheet{
    
    _sheet = mySheet; //weak linking.
    
    //Set top offset.
    _topOffset = DIAGRAM_TITLE_DEFAULT_TOP_OFFSET;
    
    //Set frame.
    _view = [[UITextView alloc]initWithFrame:CGRectMake(0, DIAGRAM_TITLE_DEFAULT_TOP_OFFSET, _sheet.bounds.size.width, NOTE_DEFAULT_HEIGHT)];
    
    //Set delegate
    _view.delegate = self;
    
    //Set transparent bg.
    _view.backgroundColor = [UIColor clearColor];
    //Set font size.
    UIFont* dTFont = _view.font;
    UIFont* dtFontBig = [dTFont fontWithSize:40];
    _view.font = dtFontBig;
    //Set default text
    _view.text = myText;
    
    // Set internal text alignment
    _view.textAlignment = UITextAlignmentCenter;
    // Set alignment on sheet
    _view.center = _sheet.center;
    // Push the frame of the text all the way to the top of sheet.
    _view.frame = CGRectMake(_sheet.frame.origin.x,
                                 0,
                                 _sheet.frame.size.width,
                                 _sheet.frame.size.height);
    // Set color of text
    _view.textColor = [ViewHelper invColorOf:_sheet.backgroundColor];
    
    //Housekeeping
    [self housekeep];
    
    // Show.
    if (_sheet != nil) {
        [_sheet addSubview:_view];
    }
    
    return self;
}


-(void)invitesUserToEdit{
    _view.frame = CGRectMake(0,
                             _topOffset,
                             _sheet.bounds.size.width,
                             _view.contentSize.height);
}


-(void)housekeep{
    //If the text field is empty
    if (_view.text.length == 0) {
        _view.text = @"Empty Title Is Unhappy";
    }
    
    
    // Find line of text that has the longest length.
    NSArray* splittedText = [_view.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    int lineNumberOfLongestLine=0;
    
    for (int i = 1; i<splittedText.count; ++i) {
        if (((NSString*)[splittedText objectAtIndex:i]).length > ((NSString*)[splittedText objectAtIndex:lineNumberOfLongestLine]).length) {
            lineNumberOfLongestLine = i;
        }
    }
    
    NSString* longestLineOfText = (NSString*)[splittedText objectAtIndex:lineNumberOfLongestLine];
    
    //Find the width required to hold the longest line. Set bounds.width to mirror this width.
    CGSize constrainedSize = [longestLineOfText sizeWithFont:_view.font];
    double constrainedWidth = constrainedSize.width + 20.0;
    CGRect bounds = _view.bounds;
    bounds.size.width = constrainedWidth;
    _view.bounds = bounds;
    
    //Keep view at the top, center of _sheet.
    _view.frame = CGRectMake(_sheet.bounds.size.width/2.0 - _view.bounds.size.width/2.0,
                                     _topOffset,
                                     _view.frame.size.width,
                                     _view.contentSize.height);
}


-(void)setTextColorWIthGZColorHexValue:(NSString*)mygzcolorhexvalue{
    _view.textColor = [GzColors colorFromHex:mygzcolorhexvalue];
    
}

-(void)setTextColor:(UIColor*)myColor{
    _view.textColor = myColor;
}

-(void)setBackgroundColor:(UIColor*)myColor{
    _view.backgroundColor = myColor;
}

-(BOOL)isFirstResponder{
    return [_view isFirstResponder];
}

-(NSString*)text{
    return _view.text;
}

-(void)remove{
    if ([_view superview]) {
        [_view removeFromSuperview];
    }
}

#pragma mark UITextView delegate methods

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self invitesUserToEdit];
}


-(BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSUInteger newLength = [textView.text length]+[text length] - range.length;
    
    /* Limit characters */
    if (newLength > DIAGRAM_TITLE_CHAR_LIM) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Cannot exceed %d characters.",DIAGRAM_TITLE_CHAR_LIM]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:nil];
        [alert show];
        [alert performSelector:@selector(dismissAnimated:) withObject:(BOOL)NO afterDelay:2.0f];
        
        return NO;
    }
    
    /* Limit height of title */
    if (textView.bounds.size.height > 300) {
        if (range.length > 0 && text.length ==0) {
            //indicates deleting a selection of text or backspacing.
            return YES;
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Stop. You're gonna overshoot the canvas."]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:nil];
        [alert show];
        [alert performSelector:@selector(dismissAnimated:) withObject:(BOOL)NO afterDelay:0.0f];
        
        return NO;
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    [self invitesUserToEdit];
}


-(void)textViewDidEndEditing:(UITextView *)textView{
    [self housekeep];
}

@end
