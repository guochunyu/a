//
//  IPAddress.h
//  demo123
//
//  Created by Dora.Lin on 14-1-17.
//  Copyright (c) 2014年 po.Li. All rights reserved.
//
#include <sys/types.h>
#include <sys/socket.h>
#include <net/ethernet.h>


#define MAXADDRS	32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
void GetHWAddresses();
