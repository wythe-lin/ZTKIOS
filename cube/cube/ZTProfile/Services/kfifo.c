/*
 ******************************************************************************
 * ZTProtrackNotify.h -
 *
 * Copyright (c) 2015-2016 by ZealTek Electronic Co., Ltd.
 *
 * This software is copyrighted by and is the property of ZealTek
 * Electronic Co., Ltd. All rights are reserved by ZealTek Electronic
 * Co., Ltd. This software may only be used in accordance with the
 * corresponding license agreement. Any unauthorized use, duplication,
 * distribution, or disclosure of this software is expressly forbidden.
 *
 * This Copyright notice MUST not be removed or modified without prior
 * written consent of ZealTek Electronic Co., Ltd.
 *
 * ZealTek Electronic Co., Ltd. reserves the right to modify this
 * software without notice.
 *
 * History:
 *	2015.01.16	T.C. Chiu	frist edition
 *
 ******************************************************************************
 */

#include <stdio.h>
#include "kfifo.h"





/*
 ******************************************************************************
 *
 * global functions
 *
 ******************************************************************************
 */
/**
 * kfifo_init -
 * @fifo: the fifo to be used.
 * @buffer: the data to be added.
 * @size: the length of the data to be added.
 *
 */
void kfifo_init(struct __kfifo *fifo, void *buffer, unsigned char size)
{
    fifo->buffer = buffer;
    fifo->size   = size;

    kfifo_reset(fifo);
}


/**
 * kfifo_in - puts some data into the FIFO
 * @fifo: the fifo to be used.
 * @from: the data to be added.
 * @len: the length of the data to be added.
 *
 * This function copies at most @len bytes from the @from buffer into
 * the FIFO depending on the free space, and returns the number of
 * bytes copied.
 */
unsigned char kfifo_in(struct __kfifo *fifo, const void *from, unsigned char len)
{
    len = min(kfifo_avail(fifo), len);

    __kfifo_in_data(fifo, from, len);
    __kfifo_add_in(fifo, len);
    return len;
}

/**
 * kfifo_out - gets some data from the FIFO
 * @fifo: the fifo to be used.
 * @to: where the data must be copied.
 * @len: the size of the destination buffer.
 *
 * This function copies at most @len bytes from the FIFO into the
 * @to buffer and returns the number of copied bytes.
 */
unsigned char kfifo_out(struct __kfifo *fifo, void *to, unsigned char len)
{
    len = min(kfifo_len(fifo), len);
    
    __kfifo_out_data(fifo, to, len);
    __kfifo_add_out(fifo, len);
    return len;
}

