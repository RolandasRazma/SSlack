//
//  Tests.m
//  Tests
//
//  Created by Rolandas Razma on 24/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

@import XCTest;
#import "SSlackSec.h"


@interface Tests : XCTestCase

@end


@implementation Tests


- (void)testLoadPublickKey {

    {
        SSlackSecKey *publicSecKey = [SSlackSecKey secKeyWithKey:@"-----BEGIN PUBLIC KEY-----\nMFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMRkcyKU840UteIVtF+vb4wUjmjJlN5O\nkGJHVYPpMpKrpBmL4L6fUI3AzzbUuBkLylW0N07BUyv3CtTn3C+m0a0CAwEAAQ==\n-----END PUBLIC KEY-----"];
        
        XCTAssertNotNil(publicSecKey);
        XCTAssertEqual(publicSecKey.format,   kSecFormatOpenSSL);
        XCTAssertEqual(publicSecKey.itemType, kSecItemTypePublicKey);
    }

    {
        SSlackSecKey *publicSecKey = [SSlackSecKey secKeyWithKey:@"-----BEGIN RSA PUBLIC KEY-----       \
                                      MIICCgKCAgEAuQXBssNm41WsRGINRlGmje/7vD5L1CDG/t3R2pshu5OimZuSCpe1  \
                                      LV3PseTxy/CyQdZ/eR69sFHRBJuy+06dWaPzhJ6/JsQn66pEoKeKiuOEdD4fW8TT  \
                                      F5xiKtW+mo4gzOKPoCve07YeNqtuMQ0eKj566UoKa+5PlBvC1lqXltWfE/fSwQkR  \
                                      Xed64yqndHz7BIOJvwnVpcVcWWEqoHzxHV77rpPzLMp63D4CQsH4U5v6f6Dakpgi  \
                                      tRLKeXZP/0FyjNRR72QtzWsBSlW8OUl8wnxvqgNLB5pOE+mPbaEJpL5YPaeuyLs+  \
                                      ncvJ0zFzfK/7v/Bk/U/uEkitUmHSO2qgrUp6XOuxhERFJhmCOXG4hyoTuzFjC1uc  \
                                      pLdJ2CowTmiHNSgecXNb7i+Uhv5qcBixWAhTHMGd3wZ+Q7HhAv7TZIyhAPgSr+MS  \
                                      Gc80Q6RUmneDWEKxV2mTTiRev65z1ESb4j8oH0RFhBXjWuDMVzjUhb+v/MLdu/yV  \
                                      nNg6c0v01xEjx6fkkeDIyuc9kHCWBplzwe/nNqwKMtW5j29m62t8a29rUslF7Zo+  \
                                      Yq3sdAR2iaMqcapSonXvRyfcgqR5ZSdnv6RzgGzuTIRtHnnUieIw3R3yxrErlzKj  \
                                      xWnJ/bAy7FR80rNPc0jTtEjjKjvfCyfqaAfAxtU7/IjJmRS1DSg/JgUCAwEAAQ==  \
                                      -----END RSA PUBLIC KEY-----"];
        
        XCTAssertNotNil(publicSecKey);
        XCTAssertEqual(publicSecKey.format,   kSecFormatBSAFE);
        XCTAssertEqual(publicSecKey.itemType, kSecItemTypePublicKey);
    }
    
}


- (void)testLoadPrivatekKey {
    
    {
        SSlackSecKey *privateSecKey = [SSlackSecKey secKeyWithKey:@"                                    \
                                       -----BEGIN RSA PRIVATE KEY-----                                  \
                                       MIIBOwIBAAJBAMRkcyKU840UteIVtF+vb4wUjmjJlN5OkGJHVYPpMpKrpBmL4L6f \
                                       UI3AzzbUuBkLylW0N07BUyv3CtTn3C+m0a0CAwEAAQJAARKjZl717aFdVPzVXWhx \
                                       7Yv3My9WttgrBb5qAyx08EQpTQPnZAAMmoRtUijuZR6h3GIyNjQmsqBycEEKJP3X \
                                       aQIhAPf4Sc1/Biqp2PlRkuPI7vH+SfqV1gfiXPKQ8iX1jUKnAiEAysCTTfQzLKLP \
                                       o2uDOGNmgzwzdxLCmtIUU9THqVVId4sCIQCzrL3VX+gY+88TAI+d65dv02DJaM6Y \
                                       EeZlgK9k3+MGWwIgBTwLkYuodpKNgc6YyK/oSaMYQQ6+73hVBgUMUpbdFBkCIQCv \
                                       EkxwTC3+ySHCgtan+9TSwr723zB2mBIvUnYGvAU6dw==                     \
                                       -----END RSA PRIVATE KEY-----"];
        
        XCTAssertNotNil(privateSecKey);
        XCTAssertEqual(privateSecKey.format,   kSecFormatOpenSSL);
        XCTAssertEqual(privateSecKey.itemType, kSecItemTypePrivateKey);
    }
    
    {
        SSlackSecKey *privateSecKey = [SSlackSecKey secKeyWithKey:@"                                    \
                                       -----BEGIN RSA PRIVATE KEY-----                                  \
                                       MIIByQIBAAJhAOlL3qMF9KFh59EPRBZMRpDGvSJNj8D54nHcquvr7avUNZ1Nbedz \
                                       reYYre4i219Q3mGWSFTmUEz7HslRWykqam4AcFmCoHvn+uQdRLvzIAS8uvPfDLpY \
                                       t31kPTtxeLL+wQIDAQABAmANZ/S1PYRfObcOhmgNN/jeHO2FaRuXpURj8qBHyljw \
                                       BNPH5EkqgbU+gbCM/KfKhGUG7qeqcpmznQUOAIRhOwxFf7+ll1eBBZbXP7ZN+i8Y \
                                       OHbrbhACvNW5lZvRvy4+p7kCMQD+RnOm2FbOkIHsFm0ojrR/hxAReDFdprdju7GS \
                                       oVNxXWlyBdvJ9u3Y/yfG7GR19VsCMQDq4Pz7qnJXfBr1mE27CgCrLQdG4swV4zF/ \
                                       qe6t1zt8bRutSWQAxlyUQwAEssKKqxMCMAVbrLI2WtXte59i9ZfmMe2CBheoJboo \
                                       ejLS0LIbTivUYRVzBCekWWy6K7doYdGOgwIwVIT3pBwWnzKShPP0bKzRxsciSjjM \
                                       lce2hSkCMV41ErY0cmvpZ3n50IQ3mnk1Fi8vAjBaMjBYAqaFk1bv/hEwy/i0Lelx \
                                       xTexHQ/czRWwJDwlFzy0l60m57Uzgp4C/8qOT4I=                         \
                                       -----END RSA PRIVATE KEY-----"];
        
        XCTAssertNotNil(privateSecKey);
        XCTAssertEqual(privateSecKey.format,   kSecFormatOpenSSL);
        XCTAssertEqual(privateSecKey.itemType, kSecItemTypePrivateKey);
    }

}


- (void)testCrypto {
    
    SSlackSecKey *publicSecKey = [SSlackSecKey secKeyWithKey:@"MCwwDQYJKoZIhvcNAQEBBQADGwAwGAIRANaVTtRcBWxk+ZecN+mTPtUCAwEAAQ=="];
    
    XCTAssertNotNil(publicSecKey);
    XCTAssertEqual(publicSecKey.format,   kSecFormatOpenSSL);
    XCTAssertEqual(publicSecKey.itemType, kSecItemTypePublicKey);
    
    NSError *error;
    NSString *encodedString = [SSlackSec encryptString:@"_STRING_" withKey:publicSecKey error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(encodedString);
    
    
    SSlackSecKey *privateSecKey = [SSlackSecKey secKeyWithKey:@"MGUCAQACEQDWlU7UXAVsZPmXnDfpkz7VAgMBAAECEQCJRajRNzEM/nsExLqBuZUhAgkA+2A0MZ9W2B0CCQDah9aGlud0GQIJAMcakxy+zWWNAgkAxydwfGveN1ECCQDishnarlm6iQ=="];
    
    XCTAssertNotNil(privateSecKey);
    XCTAssertEqual(privateSecKey.format,   kSecFormatOpenSSL);
    XCTAssertEqual(privateSecKey.itemType, kSecItemTypePrivateKey);
    
    NSString *decodedString = [SSlackSec decryptString:encodedString withKey:privateSecKey error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(decodedString);
    XCTAssertTrue([decodedString isEqualToString:@"_STRING_"]);
    
}


@end
