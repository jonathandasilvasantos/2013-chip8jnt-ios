//
//  ViewController.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "ViewController.h"
#import "Chip8.h"
#import "Chip8jntUtils.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // We create a object to execute some utils functions
    Chip8jntUtils *utils = [[Chip8jntUtils alloc] init];
    [utils listAllRoms]; // Show all roms avaliable.
    
    Chip8 *ch8 = [[Chip8 alloc] init];
    ch8.canvas = self.canvas;
    [ch8 startWithRom:@"pong.ch8"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)bitwise {

}

@end
