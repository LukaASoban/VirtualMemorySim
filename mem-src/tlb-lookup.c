#include <stdlib.h>
#include <stdio.h>
#include "tlb.h"
#include "pagetable.h"
#include "global.h" /* for tlb_size */
#include "statistics.h"

/*******************************************************************************
 * Looks up an address in the TLB. If no entry is found, attempts to access the
 * current page table via cpu_pagetable_lookup().
 *
 * @param vpn The virtual page number to lookup.
 * @param write If the access is a write, this is 1. Otherwise, it is 0.
 * @return The physical frame number of the page we are accessing.
 */
pfn_t tlb_lookup(vpn_t vpn, int write) {

    pfn_t pfn;

    /* Pointer to our victim page */
    tlbe_t *entry = NULL;

   /* 
    * Search the TLB for the given VPN. Make sure to increment count_tlbhits if
    * it was a hit!
    */
    for (int i = 0; i < tlb_size; i++) {

        if(tlb[i].valid && tlb[i].vpn == vpn) {

            count_tlbhits++;
            entry = &tlb[i];
            break;

        }
    }
    
   /* If it does not exist (it was not a hit), call the page table reader */
    if(entry == NULL)
        pfn = pagetable_lookup(vpn, write);
    else
        pfn = entry->pfn;

   /* 
    * Replace an entry in the TLB if we missed. Pick invalid entries first,
    * then do a clock-sweep to find a victim.
    */
    if(entry == NULL) {

        /* Look through the TLB to find valid victims */
        for(int i = 0; i < tlb_size; i++) {
            if(!tlb[i].valid) {
                entry = &tlb[i];
                break;
            }
        }

        /* Repeat and do a sweep through the TLB to find an unused entry*/
        if(entry == NULL) {
            while(1) {

                for(int i = 0; i < tlb_size; i++) {
                    if(!tlb[i].used) {
                        entry = &tlb[i];
                        break;
                    }

                    tlb[i].used = 0;
                }

                if(entry != NULL)
                    break;
            }
        }

        /* Set the Victim Page data*/
        entry->valid = 1;
        entry->pfn = pfn;
        entry->vpn = vpn;
    }
   /*
    * Perform TLB house keeping. This means marking the found TLB entry as
    * accessed and if we had a write, dirty. We also need to update the page
    * table in memory with the same data.
    *
    * We'll assume that this write is scheduled and the CPU doesn't actually
    * have to wait for it to finish (there wouldn't be much point to a TLB if
    * we didn't!).
    */

    if(write) {
      
        entry->dirty = write;
        current_pagetable[vpn].dirty = write;
    }

    entry->used = 1;
    current_pagetable[vpn].used = 1;

    return pfn;
}

