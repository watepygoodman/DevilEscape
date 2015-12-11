#if defined _bit_included
    #endinput
#endif
#define _bit_included
stock set_bit(num, bit)
{
    return (num | (1 << bit))
}
stock delete_bit(num, bit)
{
    return (num & ~(1 << bit))
}
stock get_bit(num, bit)
{
    new temp = (num & (1 << bit))
    if(temp) return 1
    return 0
}
stock clear_bit(num)
{
    return 0
}