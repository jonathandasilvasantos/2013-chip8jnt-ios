//
//  Opcode.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 5/28/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "Opcode.h"

@implementation Opcode

- (id)initWithOpcode:(unsigned short)op {
    
    if ( self = [super init] ) {
        self.opcode = op;
        self.x = (self.opcode & 0x0F00) >> 8;
        self.y = (self.opcode & 0x00F0) >> 4;
        self.address = (self.opcode & 0x0FFF);
        self.bit8 = (self.opcode & 0x00FF);
        self.bit4 = (self.opcode & 0x000F);
        return self;

    }
    return nil;
}

- (void)recreate {

    self.x = (self.opcode & 0x0F00) >> 8;
    self.y = (self.opcode & 0x00F0) >> 4;
    self.address = (self.opcode & 0x0FFF);
    self.bit8 = (self.opcode & 0x00FF);
    self.bit4 = (self.opcode & 0x000F);
 
}

@end