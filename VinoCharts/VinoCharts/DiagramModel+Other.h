//
//  DiagramModel+Other.h
//  VinoCharts
//
//  Created by Ang Civics on 7/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DiagramModel.h"
#import "CoreDataConstant.h"

#import "Diagram.h"
#import "NoteM.h"

@interface DiagramModel (Other)

-(id)copyDiagramData:(DiagramModel*)diagram;
//REQUIRES: self is created in the correct context and the DiagramModel is not nil
//EFFECTS: copy all DiagramModel data to replace self data

-(void)retrieveDiagramData:(Diagram*)value;
//REQUIRES: self is created in the correct context and the Diagram is not nil
//EFFECTS: translate Diagram class data to match core data saving type then modify self property

@end
