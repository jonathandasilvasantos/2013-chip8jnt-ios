//
//  Chip8.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "Chip8.h"

static unsigned char fontset[80] =
{
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80  // F
};

@implementation Chip8


// THis method has the duty to start cpu.
- (void) startWithRom:(NSString*)rom_name {
    
    // We turn on the debug mode
    debug = YES;
    
    // First, we need to initialize the cpu
    [self initialize];
    
    // Load the rom file
    [self loadGame:rom_name];
    
    // For tests; we are using a limited cycle
    for(;;) {
        [self cycle];
    }
    
}

- (void)loadGame:(NSString*)rom_name {
    
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",
                          bundleRoot, rom_name];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:NULL];
    
    unsigned long long fileSize = [attributes fileSize];
    
    char const *path = [fileManager fileSystemRepresentationWithPath:fullPath];
    
    FILE *f = fopen(path, "rb+");
    if(f == NULL) {
        NSLog(@"Error: Cannot open the rom file: %@", rom_name);
    }
    else {
        
        fread(memory+0x200, fileSize, 1, f);
        NSLog(@"Loaded rom: %@", rom_name);
    }
    fclose(f);
    
}

// Here we reset all registers to default value;
- (void)initialize {
    
    pc = 0x200; // The first 512 bytes are reserved for font-set and font-sprites;
    opcode = 0; // Reset the opcode.
    i = 0; // Reset the index register.
    sp = 0; // Reset the stack pointer current level.
    
    [self resetDisplay]; // Reset the display.
    [self resetVRegisters]; // Reset all V registers.
    [self resetStack]; // Reset all stack
    [self resetKeys]; // Reset all keys state
    [self resetMemory]; // Reset all memory of Chip-8
    
}

// Here we load the font set in memory
- (void)loadFontSet {
    
    for(int pos=0; pos<80; pos++)
    {
        memory[pos] = fontset[pos];
    }
}

// Here we loop all the gfx array setting the display to black (0)
- (void)resetDisplay {
    
    for(int pos=0; pos < 64*32; pos++) gfx[pos] = 0;
}

// Here we clean all statck setting to zero value
- (void)resetStack {
    
    // We need to remember that the max supported levels for the stack is 16.
    for(int pos=0; pos<16; pos++) stack[pos] = 0;
}

// Here we clean all the keys state setting to zero value.
- (void)resetKeys {
    
    // We need to remember that the Chip-8 only work with 16 keys (0 - F)
    for(int pos=0; pos<16; pos++) key[pos] = 0;
}

// Here we clean all V registers
- (void)resetVRegisters {
    
    // We need to remember that there are only 16 registers: V0 - VF.
    for(int pos=0; pos<16; pos++) V[pos] = 0;
}

// Here we clean all Chip-8 memory
- (void)resetMemory {
    
    // We need to remember that the Chip-8 has 4k memory (4096 bytes)
    for (int pos=0; pos<4096; pos++) memory[pos] = 0;
}

// CPU Cycle: fetch, decode and execute opcodes
- (void)cycle {
    
    opcode = memory[pc] << 8 | memory[pc + 1];
    [self executeOpcode];

}

// We identify and execute the current opcode
- (void)executeOpcode {
    
    int primaryCode = opcode & 0xF000;
    unsigned short x, y, z, tmp, height, pixel;
    NSString *errorMessage = [NSString stringWithFormat:@"Error: Opcode %x not found", opcode];
    
    switch (primaryCode) {
            
            
        case 0x2000:
            // Calls subroutine at NNN.
            [self dlogPrintOpcode];
            [self dclone];
            stack[sp] = pc;
            pc = opcode & 0x0FFF;
            [self dlogAffecteds];
            break;
            
        case 0x6000:
            // Sets VX to NN.
            [self dclone];
            [self dlogPrintOpcode];
            V[opcode & 0x0F00 >> 8] = opcode & 0x00FF;
            pc = pc + 2;
            [self dlogAffecteds];
            break;
            
        case 0xA000:
            // Sets i to the address NNN
            [self dlogPrintOpcode];
            [self dclone];
            i = opcode & 0x0FFF;
            pc = pc + 2;
            [self dlogAffecteds];
            break;
            
        case 0xD000:
            [self dlogPrintOpcode];
            [self dclone];
            
            x = opcode & 0x0F00 >> 8;
            y = opcode & 0x00F0 >> 4;
            height = opcode & 0x000F;
            
            V[0xF] = 0;
            for (int yline = 0; yline < height; yline++)
            {
                pixel = memory[i + yline];
                for(int xline = 0; xline < 8; xline++)
                {
                    if((pixel & (0x80 >> xline)) != 0)
                    {
                        if(gfx[(x + xline + ((y + yline) * 64))] == 1)
                            V[0xF] = 1;
                        gfx[x + xline + ((y + yline) * 64)] ^= 1;
                    }
                }
            }
            pc = pc + 2;
            [self dlogAffecteds];
            
            break;

        case 0xF000:
            [self handleFXXXOpcodes];
            break;
            
        default:
            [self interruptWithMessage:errorMessage];
            break;
    }
}

- (void)handleFXXXOpcodes {

    NSString *errorMessage = [NSString stringWithFormat:@"Error: Opcode %x not found", opcode];
    
    switch (opcode & 0xF0FF) {
            /* Stores the Binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.)
             */

        case 0xF033:
            [self dlogPrintOpcode];
            [self dclone];
            
            memory[i] = V[opcode & 0x0F00 >> 8] / 100;
            memory[i+1] = (V[opcode & 0x0F00 >> 8] / 10) % 10;
            memory[i+2] = (V[opcode & 0x0F00 >> 8] / 1) % 10;
            pc = pc + 2;
            [self dlogAffecteds];
            break;
            
        default:
            [self interruptWithMessage:errorMessage];
            break;
    }

}

#pragma mark -
#pragma Debug methods

- (void)dlogCurrentState {
    
    if(!debug) return;
    
    for(int pos=0; pos<16; pos++) {
        NSLog(@"V%d %x %d", pos, V[pos], V[pos]);
    }
    
    NSLog(@"i %d", i);
    
    NSLog(@"pc %x", pc);
    
    NSLog(@"sp %d", sp);
}

// Here we clone all variables for debug use
- (void)dclone {
    
    if(!debug) return;
    // Here we clone the memory
    for(int pos=0; pos<4096; pos++) {
        d_memory[pos] = memory[pos];
    }
    
    // Here we clone the V's registers
    for(int pos=0; pos<16; pos++) {
        d_V[pos] = V[pos];
    }
    
    d_i = i;
    d_pc = pc;
    
    // Here we clone the gfx
    for(int pos=0; pos<(64*32); pos++) {
        d_gfx[pos] = gfx[pos];
    }
    
    d_delay_timer = delay_timer;
    d_sound_timer = sound_timer;
    
    // Here we clone the stack
    for(int pos=0; pos<16; pos++) {
        d_stack[pos] = stack[pos];
    }
    
    // Here we clone the keys
    for(int pos=0; pos<16; pos++) {
        d_key[pos] = key[pos];
    }
    
    d_sp = sp;
}

- (void)dlogAffecteds {
    if(!debug) return;
    // Here we identify changes in memory
    for(int pos=0; pos<4096; pos++) {
        if(d_memory[pos] != memory[pos]) {
            NSLog(@"Memory changed at address: %x - old: %x new: %x", pos, d_memory[pos], memory[pos]);
        }
    }
    
    // Here we identify changes in V's registers
    for(int pos=0; pos<16; pos++) {
        if(d_V[pos] != V[pos]) {
            NSLog(@"V%d - old: %x new: %x", pos, d_V[pos], V[pos]);
        }
    }
    
    if (d_i != i) NSLog(@"i changed - old: %x new: %x", d_i, i);
    
    if (d_pc != pc) NSLog(@"pc changed - old: %x new: %x", d_pc, pc);
    
    // Here we identify changes in gfx array
    for(int pos=0; pos< (64*32); pos++) {
        
        int d_x, d_y; // we need to convert vetor to matriz
        d_y = pos/64;
        d_x = pos%64;
        
        if(d_gfx[pos] != gfx[pos]) {
            NSLog(@"gfx[%d][%d] - old: %x new: %x", d_x, d_y, d_gfx[pos], gfx[pos]);
        }
    }
    
    if (d_delay_timer != delay_timer) NSLog(@"delay_timer changed - old: %d new: %d", d_delay_timer, delay_timer);
    
    if (d_sound_timer != sound_timer) NSLog(@"sound_timer changed - old: %d new: %d", d_sound_timer, sound_timer);
    
    
    // Here we identify changes in stack
    for(int pos=0; pos<16; pos++) {
        if(d_stack[pos] != stack[pos]) {
            NSLog(@"changed stack[%d] - old: %x new: %x", pos, d_stack[pos], stack[pos]);
        }
    }
    
    if (d_sp != sp) NSLog(@"sp changed - old: %x new: %x", d_sp, sp);
    
    // Here we identify changes in key
    for(int pos=0; pos<16; pos++) {
        if(d_key[pos] != key[pos]) {
            NSLog(@"changed key[%d] - old: %x new: %x", pos, d_key[pos], key[pos]);
        }
    }
    
}

- (void)dlogPrintOpcode {
    if(!debug) return;
    NSLog(@"Current upcode: %x", opcode);
}

// Interrupt cycle and print message
- (void)interruptWithMessage:(NSString*)message {
    
    NSLog(@"%@", message);
    
}

@end
