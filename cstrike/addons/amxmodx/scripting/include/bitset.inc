#if defined _bitset_included
    #endinput
#endif
#define _bitset_included

#define set_bit(%1,%2) %1|=(1 << %2)
#define get_bit(%1,%2 %1&(1 << %2)?0:1
#define delete_bit(%1,%2) %1=%1&~(1<<%2)
#define clear_bit(%1) %1=0