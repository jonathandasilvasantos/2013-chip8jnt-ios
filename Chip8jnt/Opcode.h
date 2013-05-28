//
//  Opcode.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 5/28/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Opcode : NSObject

@property(nonatomic, assign) unsigned short opcode; // opcode 16bit
@property(nonatomic, assign) unsigned short x; // 0x0F00
@property(nonatomic, assign) unsigned short y; // 0x00F0
@property(nonatomic, assign) unsigned short address; // 0x0FFF
@property(nonatomic, assign) unsigned short bit8; // 0x00FF
@property(nonatomic, assign) unsigned short bit4; // 0x000F;

- (id)initWithOpcode:(unsigned short)op;
- (void)recreate; // Set all parameters for current opcode
@end
