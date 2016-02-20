#include <stdlib.h>

#include "types.h"
#include "pagetable.h"
#include "global.h"
#include "process.h"

/*******************************************************************************
 * Finds a free physical frame. If none are available, uses a clock sweep
 * algorithm to find a used frame for eviction.
 *
 * @return The physical frame number of a free (or evictable) frame.
 */
pfn_t get_free_frame(void) {

    /* See if there are any free frames */
    for (int i = 0; i < CPU_NUM_FRAMES; i++)
        if (rlt[i].pcb == NULL) return i;

    /* IMPLEMENT A CLOCK SWEEP ALGORITHM HERE */
    /* Note: Think of what kinds of frames can you return before you decide
      to evit one of the pages using the clock sweep and return that frame */

    /* First, let's check for invalid frames */
    for (int i = 0; i < CPU_NUM_FRAMES; i++) {

        pte_t *tempFrame = (rlt[i].pcb)->pagetable;

        if(!(tempFrame[rlt[i].vpn].valid)) return i;
    }

    while(1)
    {
        /* Let us iterate through each page table */
       	for(int i = 0; i < CPU_NUM_FRAMES; i++) {

       	    pte_t *tempFrame = (rlt[i].pcb)->pagetable;

       		/*check if it is used and then clear it for the next sweep */
       		if(tempFrame[rlt[i].vpn].used)
       			tempFrame[rlt[i].vpn].used = 0;
       		else
       			return i;
       	}
   }

   /* If all else fails, return a random frame */
   return rand() % CPU_NUM_FRAMES;
}
