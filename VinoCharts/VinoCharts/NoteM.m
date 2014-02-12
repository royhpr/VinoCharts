//
//  NoteM.m
//  VinoCharts
//
//  Created by Ang Civics on 11/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "NoteM.h"
#import "Constants.h"

@implementation NoteM

-(id)init{
    self = [super init];
    if(self){
        _content = [[NSString alloc]init];
        // _x and _y are primitive data types. Don't init.
        _fontColor = [[NSString alloc]init];
        _material = [[NSString alloc]init];
        _font = [[UIFont alloc]init];
    }
    return self;
}

-(id)initDefaultWithContent:(NSString*)noteContent{
    self = [super init];
    if(self){
        _content = noteContent;
        _x = 0;
        _y = 0;
        _fontColor = NOTE_DEFAULT_FONT_COLOR;
        _material = NOTE_DEFAULT_MATERIAL; //filename of pattern.
        _font = [UIFont fontWithName:NOTE_DEFAULT_FONT size:NOTE_DEFAULT_FONT_SIZE];
    }
    return self;
}

+(id)defaultModelWithContent:(NSString*)noteContent{
    NoteM* nM = [[NoteM alloc]initDefaultWithContent:noteContent];
    return nM;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.content forKey:kContent];
    [encoder encodeDouble:self.x forKey:kXLocation];
    [encoder encodeDouble:self.y forKey:kYLocation];
    [encoder encodeObject:self.font forKey:kFont];
    [encoder encodeObject:self.fontColor forKey:kFontColor];
    [encoder encodeObject:self.material forKey:kMaterial];
}

- (id)initWithCoder:(NSCoder *)decoder{
    self.content = [decoder decodeObjectForKey:kContent];
    self.x = [decoder decodeDoubleForKey:kXLocation];
    self.y = [decoder decodeDoubleForKey:kYLocation];
    self.font = [decoder decodeObjectForKey:kFont];
    self.fontColor = [decoder decodeObjectForKey:kFontColor];
    self.material = [decoder decodeObjectForKey:kMaterial];
    
    return  self;
}
@end
