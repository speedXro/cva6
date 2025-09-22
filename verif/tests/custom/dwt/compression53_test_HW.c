#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#include "compression.h"

void gccs(uint8_t label)
{
    uint32_t res;
    __asm__ volatile ("csrr %0, cycle" : "=r" (res));
    
    asm volatile (
		"add x6, x0, %0"
		: 
		: "r" (label)
	);
    
    asm volatile (
		"add x7, %0, x0"
		: 
		: "r" (res) 
	);  
}

static void make_text_1024(uint8_t *buf){
    const char *para =
        "To be, or not to be, that is the question—Whether 'tis nobler in the mind to suffer "
        "The slings and arrows of outrageous fortune, Or to take arms against a sea of troubles "
        "And by opposing end them. To die—to sleep, No more; and by a sleep to say we end "
        "The heart-ache and the thousand natural shocks That flesh is heir to: 'tis a consummation "
        "Devoutly to be wish'd. To die, to sleep—To sleep—perchance to dream: ay, there's the rub: "
        "For in that sleep of death what dreams may come, When we have shuffled off this mortal coil, "
        "Must give us pause—there's the respect That makes calamity of so long life.";
    size_t L = strlen(para);
    for (int i = 0; i < NBYTES; i++) buf[i] = (uint8_t)para[i % L];
}

int main(void){
    /* Prepare input */
    uint8_t text[NBYTES];
    make_text_1024(text);

    /* Encode per 16-byte block */    
    uint8_t stream[NBYTES * 4];
    uint8_t *p = stream;

    gccs(0x20);
    for (int b = 0; b < NBYTES/BLK; b++){
        /* Convert 16 input bytes to signed centered int8_t */
        int8_t blk[BLK];
        for (int i = 0; i < BLK; i++){
            blk[i] = (int8_t)((int)text[b*BLK + i] - 128);
        }
        size_t used = HW_encode_block_53_varbyte(blk, p, (size_t)(NBYTES*4 - (p - stream)));
        if (used == 0){
            //fprintf(stderr, "encode failed at block %d\n", b);
            //free(stream);
            return 1;
        }
        p += used;
    }
    size_t enc_size = (size_t)(p - stream);
    gccs(0x24);

    /* Decode back and verify */
    uint8_t *src = stream;
    uint8_t *end = stream + enc_size;
    gccs(0x28);
    for (int b = 0; b < NBYTES/BLK; b++){
        int8_t recon_blk[BLK];
        size_t used = HW_decode_block_53_varbyte(src, (size_t)(end - src), recon_blk);
        if (used == 0){
            //fprintf(stderr, "decode failed at block %d\n", b);
            //free(stream);
            return 1;
        }
        /* Convert back to bytes and compare */
        for (int i = 0; i < BLK; i++){
            int recon_byte = (int)recon_blk[i] + 128;
            if (recon_byte != (int)text[b*BLK + i]){
                //fprintf(stderr, "mismatch at block %d, i=%d: orig=%d recon=%d\n",
                //        b, i, (int)text[b*BLK+i], recon_byte);
                //free(stream);
                return 1;
            }
        }
        src += used;
    }
    gccs(0x2C);

    /* Report */
    printf("Original size: %d bytes\n", NBYTES);
    printf("Encoded size (per-block): %zu bytes\n", enc_size);
    printf("Compression ratio (orig/encoded): %.3f\n", (double)NBYTES / (double)enc_size);

    /* Preview first 64 chars */
    printf("Original preview: ");
    for (int i = 0; i < 64; i++) putchar(text[i]);
    putchar('\n');

    //free(stream);
    return 0;
}