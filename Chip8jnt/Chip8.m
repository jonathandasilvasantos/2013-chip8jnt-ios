//
//  Chip8.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "Chip8.h"
#import "DebugCell.h"

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
    debug = NO;
    
    // First, we need to initialize the cpu
    [self initialize];
    
    // Load the rom file
    [self loadGame:rom_name];
    
    if(debug) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"debugRefresh" object:nil];
    }

   if(!debug) [self cycle];
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
    
    self.op = [[Opcode alloc] initWithOpcode:opcode]; // create a opcode smart object;
    
    [self resetDisplay]; // Reset the display.
    [self resetVRegisters]; // Reset all V registers.
    [self resetStack]; // Reset all stack
    [self resetKeys]; // Reset all keys state
    [self resetMemory]; // Reset all memory of Chip-8
    
    [self loadFontSet];
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

    // Random key
    [self dPressRandomKey];
    
    opcode = memory[pc] << 8 | memory[pc + 1];
    [self.op setOpcode:opcode];
    [self.op recreate];

    [self dlogPrintOpcode];
    [self dclone];
    [self executeOpcode];
//    [self dlogCurrentState];
    [self dlogAffecteds];
    
    [self handleTimers];

    // Make a notification to debug manager;
    if(debug) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"debugRefresh" object:nil];
    }

    if(!debug) [self performSelector:@selector(cycle) withObject:nil afterDelay:0.005];
    
}
- (void)handleTimers {
    
    // All timers reaches zero
    if(delay_timer > 0) {
        delay_timer--;
    }
    
    if(sound_timer > 0) {
        sound_timer--;
    }

}

- (void)beep {
    NSLog(@"Beep!");
}

// Do a step in program counter.
- (void)step {
    pc = pc + 2;
}

// We identify and execute the current opcode
- (void)executeOpcode {
    
    int primaryCode = opcode & 0xF000;
    NSString *errorMessage = [NSString stringWithFormat:@"Error: Opcode %x not found", opcode];
    
    switch (primaryCode) {
            

        case 0x0000:
            [self handle00XXOpcodes];
            break;
            
        case 0x1000:
            // Jumps to address NNN.
            pc = self.op.address;
            break;
            
        case 0x2000:
            // Calls subroutine at NNN.
            if (sp >= 15) {
                NSLog(@"Error: Stack overflow.");
                break;
            }
            stack[sp] = pc;
            pc = self.op.address;
            sp++;
            break;
            
        case 0x3000:
            // Skips the next instruction if VX == NN
            if(V[self.op.x] == self.op.bit8) {
                [self step]; }
            [self step];
            break;
            
        case 0x4000:
            // Skips the next instruction if VX != NN
            if(V[self.op.x] != self.op.bit8) [self step];
            [self step];
            break;
            
        case 0x5000:
            // Skips the next instruction if VX equals VY.
            if(V[self.op.x] == V[self.op.y]) [self step];
            [self step];
            break;
            
        case 0x6000:
            // Sets VX to NN.
            V[self.op.x] = self.op.bit8;
            [self step];
            break;
            
        case 0x7000:
            // Sets VX to NN.
            V[self.op.x] += self.op.bit8;
            [self step];
            break;
            
        case 0x8000:
            [self handle8XXXOpcodes];
            break;
            
        case 0x9000:
            // Skips next instruction if VX != VY
            if (V[self.op.x] != V[self.op.y]) [self step];
            [self step];
            break;
            
            
        case 0xA000:
            // Sets i to the address NNN
            i = self.op.address;
            [self step];
            break;
            
        case 0xC000:
            // Sets VX to a random number and NN
            V[self.op.x] = (arc4random() % 0xFF) & self.op.bit8;
            [self step];
            break;
            
        case 0xD000:
            [self executeDXYN];
            [self step];
            break;
            
        case 0xE000:
            [self handleEXXXOpcodes];
            break;

        case 0xF000:
            [self handleFXXXOpcodes];
            break;
            
        default:
            [self interruptWithMessage:errorMessage];
            break;
    }
}

- (void)handle8XXXOpcodes {
    
    NSString *errorMessage = [NSString stringWithFormat:@"Error: Opcode %x not found", opcode];
    
    
    switch (opcode & 0xF00F) {
            
        case 0x8000:
            //Sets VX to the value of VY.
            V[self.op.x] = V[self.op.y];
            [self step];
            break;
            
        case 0x8001:
            //Sets VX to VX or VY
            V[self.op.x] = V[self.op.x] | V[self.op.y];
            [self step];
            break;
            
        case 0x8002:
            //Sets VX to VX and VY
            V[self.op.x] = V[self.op.x] & V[self.op.y];
            [self step];
            break;
            
        case 0x8003:
            // Sets VX to VX xor VY
            V[self.op.x] = V[self.op.x] ^ V[self.op.y];
            [self step];
            break;
            
        case 0x8004:
            // Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
            if((V[self.op.x] + V[self.op.y]) > 0xFF) V[0xF] = 1;
            else V[0xF] = 0;
            V[self.op.x] += V[self.op.y];
            [self step];
            break;
            
        case 0x8005:
            // VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
            if( V[self.op.x] > V[self.op.x]) V[0xF] = 0;
            else V[0xF] = 1;
            V[self.op.x] = V[self.op.x] - V[self.op.y];
            [self step];
            break;
            
        case 0x8006:
            // Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
            V[0xF] = V[self.op.x] & 0x0001;
            V[self.op.x] = V[self.op.x] >> 1;
            [self step];
            break;
            
        case 0x8007:
            // Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
            
            if(V[self.op.x] > V[self.op.y]) V[0xF] = 1;
            else V[0xF] = 0;
            V[self.op.x] = V[self.op.y] - V[self.op.x];
            [self step];
            break;
            
        case 0x800E:
            // Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift
            V[0xF] = (V[self.op.x] >> 7) & 1;
            V[self.op.x] = V[self.op.x] << 1;
            [self step];
            break;
            
        default:
            [self interruptWithMessage:errorMessage];
            break;
    }
}

- (void)handle00XXOpcodes {
    
    NSString *errorMessage = [NSString stringWithFormat:@"Error: Opcode %x not found", opcode];
    
    switch (opcode & 0x00FF) {
            
        case 0x00E0:
            [self resetDisplay];
            [self step];
            break;
            
        case 0x00EE:
            // Returns from a subroutine
            sp--;
            pc = stack[sp];
            stack[sp] = 0;
            [self step];
            break;
            
        default:
            [self interruptWithMessage:errorMessage];
            break;
    }
}

- (void)handleEXXXOpcodes {
    
    NSString *errorMessage = [NSString stringWithFormat:@"Error: Opcode %x not found", opcode];
    
    switch (opcode & 0xF0FF) {
        case 0xE0A1:
            // Skips the next instruction if the key stored in VX isn't pressed.

            if(key[self.op.x] != 1) [self step];
            [self step];
            break;
            
        case 0xE09E:
            // Skips the next instruction if the key stored in VX is pressed.
            
            if(key[self.op.x] == 1) [self step];
            [self step];
            break;
            
        default:
            [self interruptWithMessage:errorMessage];
            break;
    }
    
}

- (void)handleFXXXOpcodes {

    NSString *errorMessage = [NSString stringWithFormat:@"Error: Opcode %x not found", opcode];
    
    switch (opcode & 0xF0FF) {
            
        case 0xF00A:
            // A key press is awaited, and then stored in VX.
            V[self.op.x] = arc4random()%15;
            key[self.op.x] = V[self.op.x];
            [self step];
            break;
            
        case 0xF007:
            //Sets the VX to delay timer
            V[self.op.x] = delay_timer;
            [self step];
            break;
            
            
        case 0xF01E:
            // Adds VX to I
            i += V[self.op.x];
            [self step];
            break;
            

        case 0xF015:
            // Sets the delay timer to VX
            delay_timer = V[self.op.x];
            [self step];
            break;
            
        case 0xF018:
            // Sets the sound timer to VX.
            sound_timer = V[self.op.x];
            [self step];
            break;

        case 0xF033:
            /* Stores the Binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.)
             */
            memory[i] = V[self.op.x] / 100;
            memory[i+1] = (V[self.op.x] / 10) % 10;
            memory[i+2] = (V[self.op.x]) % 10;
            [self step];
            break;
            
        case 0xF029:
            /* Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
             FX33 	Stores the Binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location
             */
            i = V[self.op.x] * 5;
            [self step];
            break;

        case 0xF055:
            // Stores V0 to VX in memory starting at address I
            for(int pos=0; pos <= self.op.x; pos++)
                memory[i+pos] = V[i+pos];
            [self step];
            break;
            
        case 0xF065:
            // Fills V0 to VX with values from memory starting at address I
            for(int pos = 0; pos <= self.op.x; pos++)
                V[pos] = memory[i+pos];

            [self step];
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
            NSLog(@"V%x - old: %x new: %x", pos, d_V[pos], V[pos]);
        }
    }
    
    if (d_i != i) NSLog(@"i changed - old: %x new: %x", d_i, i);
    
    if (d_pc != pc) NSLog(@"pc changed - old: %x new: %x", d_pc, pc);
    
    if (d_delay_timer != delay_timer) NSLog(@"delay_timer changed - old: %x new: %x", d_delay_timer, delay_timer);
    
    if (d_sound_timer != sound_timer) NSLog(@"sound_timer changed - old: %x new: %x", d_sound_timer, sound_timer);
    
    
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
    NSLog(@"\n");
    NSLog(@"Current upcode: %x", opcode);
}

- (void)dPressRandomKey {
    
    if(!debug) return;
    
    int k = arc4random()%15;
    key[k] = !key[k];
}

// Interrupt cycle and print message
- (void)interruptWithMessage:(NSString*)message {
    
    NSLog(@"%@", message);

    
}

- (void)copyGFXinCanvas {
    for(int x = 0; x<64; x++) {
        for(int y = 0; y<32; y++) {
            [self.canvas setPixel:x y:y value:gfx[GFX_INDEXOF(x, y)] ];
        }
    }
}

- (void) executeDXYN {
    short xp = V[(opcode & 0x0F00) >> 8];
    short yp = V[(opcode & 0x00F0) >> 4];
    short h = opcode & 0x000F;
    

    V[0xF] = 0x0;
    for (int y = i; y < i + h; y++) {
        short row = memory[y];
        
        for (int x = 0; x < 8; x++) {
            short new_pixel = (row >> (7 - x)) & 1;
            short _x = xp + x;
            short _y = yp + y - i;
            if (_x >= 64 || _y >= 32)
                continue;
            if (new_pixel) {
                if ( gfx[GFX_INDEXOF(_x, _y)] == 1)
                    V[0xF] = 0x1;
                
                gfx[GFX_INDEXOF(_x, _y)] = !gfx[GFX_INDEXOF(_x, _y)];
                
            }
        }
    }
    [self copyGFXinCanvas];
    [self.canvas setNeedsDisplay];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    
{
    return 11;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
//    if(cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
//
//}
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DebugCell" owner:self options:nil];
    
    DebugCell *cell = (DebugCell *)[nib objectAtIndex:0];

    if(indexPath.row < 8) {
        cell.textLabel.text = [NSString stringWithFormat:@"V%x: %x    V%x: %x", indexPath.row, V[indexPath.row], 8+indexPath.row, V[8+indexPath.row]];
    }
    
    if(indexPath.row == 8) cell.textLabel.text =
        [NSString stringWithFormat:@"Sound:    %x", sound_timer];
    
    if(indexPath.row == 9) cell.textLabel.text =
        [NSString stringWithFormat:@"Delay:    %x", delay_timer];

    if(indexPath.row == 10) cell.textLabel.text =
        [NSString stringWithFormat:@"Opcode:    %x     Last:   %x", (memory[pc] << 8 | memory[pc + 1]), opcode ];
    
    if(indexPath.row == 0) cell.textLabel.text = [NSString stringWithFormat:@"%@    PC:  %x", cell.textLabel.text , pc];
    
    if(indexPath.row == 1) cell.textLabel.text = [NSString stringWithFormat:@"%@    I:   %x", cell.textLabel.text , i];
    
    return cell;
}

@end
