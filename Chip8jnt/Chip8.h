//
// This file is part of Chip8jnt-iOS.
//
// Chip8jnt-iOS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Chip8jnt-iOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//
//
//  Chip8.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "Chip8Canvas.h"
#import "Chip8jntUtils.h"
#import "Opcode.h"


@interface Chip8 : NSObject <UITableViewDataSource> {
    
    SystemSoundID beepSound; // Audio identifier for beep.
    
    unsigned short opcode;
    unsigned char memory[4096]; // Chip-8 has a 4k memory
    unsigned char V[16]; // Chip-8 has 16 registers
    unsigned short i; // Index register
    unsigned short pc; // program counter register
    unsigned short gfx[64*32]; // Chip-8 has a monocromatic display 64x32 = 2048 px
    unsigned char delay_timer; // 60 to zero (Chip-8 runs at 60htz)
    unsigned char sound_timer; // 60 to zero; play a beep when timer reaches zero.
    
    unsigned short stack[16]; // 16 is the limit level supported for address stack;
    unsigned short sp; // store the current stack pointer level;
    unsigned char key[16]; // record the input key pressed: Range: 0 - F;

    // Now we have me same variables for debug use
    
    unsigned char d_memory[4096];
    unsigned char d_V[16];
    unsigned short d_i;
    unsigned short d_pc;
    unsigned char d_delay_timer;
    unsigned char d_sound_timer;
    
    unsigned short d_stack[16];
    unsigned short d_sp;
    unsigned char d_key[16];
    
    BOOL debug;
}

@property(nonatomic, strong) Chip8Canvas *canvas; // Canvas for draw method
@property(nonatomic, strong) Opcode *op; // Smart opcode object;

- (void) startWithRom:(NSString*)rom_name; // Start emulator cycle with a specific rom

- (void)loadGame:(NSString*)rom_name; // Load the rom in the memory (0x200 - 0xFFF)

- (void)initialize; // Reset all registers and memory;

- (void)loadSound; // Load the beep sound;

- (void)cycle; // Run a emulation cycle

- (void)step; // pc = pc + 2: runs the program counter;

- (void)dclone; // Clone current state of Chip-8 in debug variables
- (void)dlogCurrentState; // print all registers and flags.
- (void)dlogAffecteds; // print affecteds registers after a execute opcode.
- (void)dlogPrintOpcode; // print the current opcode;
- (void)dPressRandomKey; // press a random key for debug;
- (void)interruptWithMessage:(NSString*)message; // interrupt and print message;

- (void)loadFontSet; // Load constants font set in memory.

- (void)executeOpcode; // Execute the current opcode;

- (void)handle8XXXOpcodes;  // I prefered to create a method to handle
// those opcodes;

- (void)handleEXXXOpcodes;  // I prefered to create a method to handle
// those opcodes;

- (void)handleFXXXOpcodes;  // I prefered to create a method to handle
                            // those opcodes;

- (void)handleTimers; // Handle delay and sound timers

- (void)beep; // Play beep;

- (void)handle00XXOpcodes;  // I prefered to create a method to handle
// those opcodes;

- (void)resetDisplay; // Reset the gfx array.
- (void)resetStack; // Reset the stack array.
- (void)resetKeys; // Reset the keys state input.
- (void)resetVRegisters; // Reset all V registers [V0 - V16]
- (void)resetMemory; // Reset all the mmemory;

- (void)copyGFXinCanvas; // We make a copy from local DFX to Canvas;
- (void) executeDXYN;
@end
