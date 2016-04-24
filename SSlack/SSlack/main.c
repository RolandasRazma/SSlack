//
//  main.c
//  SSlack
//
//  Created by Rolandas Razma on 20/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


int main(int argc, char * argv[]) {
    
    if ( argc < 2 ) {
        printf("Usage: sslack path_to_slack [arguments]\n");
        
        return EXIT_SUCCESS;
    }
    
    // /Applications/Slack.app/Contents/MacOS/Slack
    
    putenv("DYLD_FORCE_FLAT_NAMESPACE=1");
    putenv("DYLD_INSERT_LIBRARIES=libsslack.dylib");
    
    execvp(argv[1], &argv[1]);
    
    perror("sslack can't load process....");
    
    return EXIT_SUCCESS;
}
