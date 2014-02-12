//
//  FontHelper.m
//  VinoCharts
//
//  Created by Lee Jian Yi David on 4/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "FontHelper.h"
#import "Constants.h"

@implementation FontHelper

+(BOOL)isBold:(UIFont*)f{
    NSString* name = [f fontName];
    if([name hasSuffix:fBOLD])
		return YES;
	else
		return NO;
}

+(BOOL)isOnlyItalics:(UIFont*)f{
	NSString* name = [f fontName];
    if([name hasSuffix:fITALIC])
		return YES;
	else
		return NO;
}

+(BOOL)isBoldAndItalics:(UIFont*)f{
	NSString* name = [f fontName];
    if([name hasSuffix:fBOLD_ITALIC])
		return YES;
	else
		return NO;
}

+(BOOL)isNotImbuedWithModifier:(UIFont*)f{
    if (![FontHelper isBold:f]
        && ![FontHelper isOnlyItalics:f]
        && ![FontHelper isBoldAndItalics:f]) {
        return YES;
    }
    else
        return NO;
}

+(UIFont*)addItalicsTo:(UIFont*)f{
	if ([FontHelper isOnlyItalics:f] || [FontHelper isBoldAndItalics:f])
		return f;
    else if ([FontHelper isBold:f]){
        NSString* name = [f fontName];
        return [UIFont fontWithName:[name stringByAppendingString:@"Italic"] size:NOTE_DEFAULT_FONT_SIZE];
    }
	else {
		NSString* name = [f fontName];
		return [UIFont fontWithName:[name stringByAppendingString:fITALIC] size:NOTE_DEFAULT_FONT_SIZE];
	}
}

+(UIFont*)addBoldTo:(UIFont*)f{
	if ([FontHelper isBold:f] || [FontHelper isBoldAndItalics:f])
		return f;
    else if ([FontHelper isOnlyItalics:f]){
        UIFont* g = [FontHelper removeModifiersOf:f];
        NSString* name = [g fontName];
        return [UIFont fontWithName:[name stringByAppendingString:fBOLD_ITALIC] size:NOTE_DEFAULT_FONT_SIZE];
    }
	else {
		NSString* name = [f fontName];
		return [UIFont fontWithName:[name stringByAppendingString:fBOLD] size:NOTE_DEFAULT_FONT_SIZE];
	}
}

+(UIFont*)minusItalicsFrom:(UIFont*)f{
	if ([FontHelper isOnlyItalics:f]) {
        return [FontHelper removeModifiersOf:f];
    }
    else if ([FontHelper isBoldAndItalics:f]){
        UIFont* g = [FontHelper removeModifiersOf:f];
        return [FontHelper addBoldTo:g];
    }
    else //f is not italicised to begin with.
    {
        return f;
    }
}

+(UIFont*)minusBoldFrom:(UIFont*)f{
    if ([FontHelper isBoldAndItalics:f]) {
        UIFont* g = [FontHelper removeModifiersOf:f];
        return [FontHelper addItalicsTo:g];
    }
    else if ([FontHelper isBold:f]) // Detecting only -Bold and not -BoldItalic
    {
        return [FontHelper removeModifiersOf:f];
    }
    else //f is not bold to begin with.
    {
        return f;
    }
}

+(UIFont*)removeModifiersOf:(UIFont*)f{
    NSString* name = [f fontName];
    if ([FontHelper isBold:f]) {
        name = [name substringToIndex:name.length-fBOLD.length];                          
        return [UIFont fontWithName:name size:NOTE_DEFAULT_FONT_SIZE];
    }
    else if ([FontHelper isOnlyItalics:f]) {
        name = [name substringToIndex:name.length-fITALIC.length];
        return [UIFont fontWithName:name size:NOTE_DEFAULT_FONT_SIZE];
    }
    else if ([FontHelper isBoldAndItalics:f]) {
        name = [name substringToIndex:name.length-fBOLD_ITALIC.length];
        return [UIFont fontWithName:name size:NOTE_DEFAULT_FONT_SIZE];
    }
    else{ // f has no modifiers to begin with.
        return f;
    }
        
}

+(UIFont*)modifyFont:(UIFont*)beforeFont WhileKeepingModifiersAndSizeToFontFamily:(NSString*)newFontFamily{
    
    // Create a font with desired font family but same size as beforeFont.
    UIFont* afterFont = [UIFont fontWithName:newFontFamily size:beforeFont.pointSize];
    
    // Observe modifiers of beforeFont and apply the same modifiers to afterFont.
    if ([FontHelper isBoldAndItalics:beforeFont]) {
        UIFont* g = [FontHelper addBoldTo:afterFont];
        g = [FontHelper addItalicsTo:g];
        return g;
    }
    else if ([FontHelper isOnlyItalics:beforeFont]) {
        UIFont* g = [FontHelper addItalicsTo:afterFont];
        return g;
    }
    else if ([FontHelper isBold:beforeFont]) //Only -Bold, since -BoldItalic has been checked in first conditional statement.
    {
        UIFont* g = [FontHelper addBoldTo:afterFont];
        return g;
    }
    else {
        return afterFont;
    }
}


@end
