
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "pagetable.h"

/*******************************************************************************
 * Current page table register, used by the processor to find the running
 * processes page table upon a TLB miss.
 */
pte_t   *current_pagetable; /* CPU page register */
