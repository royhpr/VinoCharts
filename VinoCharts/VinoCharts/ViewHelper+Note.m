//
//  ViewHelper+Note.m
//  VinoCharts
//
//  Created by Lee Jian Yi David on 4/21/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ViewHelper+Note.h"
#import "ViewHelper.h"
#import "Note.h"

@implementation ViewHelper (Note)

+(CGRect)getTightestFrameThatCoversAllNotesIn:(NSArray*)noteArr{
    // Create a CGrect that is a snug basket around all the notes.
    // Determine the boundaries of the basket that is to snugly wrap the notes.
    // Initialise max's and min's.
    Note* firstNote = (Note*)[noteArr objectAtIndex:0];
    double overlayMinX = [firstNote getBodyTopLeftPoint].x;
    double overlayMaxX = [firstNote getBodyTopLeftPoint].x;
    double overlayMinY = [firstNote getBodyTopLeftPoint].y;
    double overlayMaxY = [firstNote getBodyTopLeftPoint].y;
    for (Note* eachNote in noteArr) {
        double nX = [eachNote getBodyTopLeftPoint].x;
        double nY = [eachNote getBodyTopLeftPoint].y;
        if (nX > overlayMaxX) {
            overlayMaxX = nX;
        }
        else if (nX < overlayMinX) {
            overlayMinX = nX;
        }
        else
            ;//do nth
        
        if (nY > overlayMaxY) {
            overlayMaxY = nY;
        }
        else if (nY < overlayMinY) {
            overlayMinY = nY;
        }
        else
            ;//do nth
    }
    //Using the max and min boundaries found, create the basket.
    double noteWidth = firstNote.view.bounds.size.width;
    double noteHeight = firstNote.view.bounds.size.height;
    double basketFrameWidth = overlayMaxX-overlayMinX+noteWidth;
    double basketFrameHeight = overlayMaxY-overlayMinY+noteHeight;
    
    return CGRectMake(overlayMinX, overlayMinY, basketFrameWidth, basketFrameHeight);
}

@end