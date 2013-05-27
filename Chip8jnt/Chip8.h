//
//  Chip8.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chip8 : NSObject {

    unsigned short opcode;
    unsigned char memory[4096]; // Chip-8 has a 4k memory
    unsigned char V[16]; // Chip-8 has 16 registers
    unsigned short i; // Index register
    unsigned short pc; // program counter register
    unsigned char gfx[64*32]; // Chip-8 has a monocromatic display 64x32 = 2048 px
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
    unsigned char d_gfx[64*32];
    unsigned char d_delay_timer;
    unsigned char d_sound_timer;
    
    unsigned short d_stack[16];
    unsigned short d_sp;
    unsigned char d_key[16];
    
    BOOL debug;
}

- (void) startWithRom:(NSString*)rom_name; // Start emulator cycle with a specific rom

- (void)loadGame:(NSString*)rom_name; // Load the rom in the memory (0x200 - 0xFFF)

- (void)initialize; // Reset all registers and memory;

- (void)cycle; // Run a emulation cycle

- (void)setKeys; // Turn on or off the registers keys;

- (void)draw; // Draw the current display state;

- (void)dclone; // Clone current state of Chip-8 in debug variables
- (void)dlogCurrentState; // print all registers and flags.
- (void)dlogAffecteds; // print affecteds registers after a execute opcode.
- (void)dlogPrintOpcode; // print the current opcode;
- (void)interruptWithMessage:(NSString*)message; // interrupt and print message;

- (void)loadFontSet; // Load constants font set in memory.

- (void)executeOpcode; // Execute the current opcode;

- (void)handleFXXXOpcodes;  // I prefered to create a method to handle
                            // those opcodes;

- (void)resetDisplay; // Reset the gfx array.
- (void)resetStack; // Reset the stack array.
- (void)resetKeys; // Reset the keys state input.
- (void)resetVRegisters; // Reset all V registers [V0 - V16]
- (void)resetMemory; // Reset all the mmemory;
@end