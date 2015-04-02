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

#ifndef __CUBE_KFIFO_H__
#define __CUBE_KFIFO_H__

#include <stddef.h>
#include <string.h>

#define MIN(a, b)   ((a) < (b) ? (a) : (b))
#define MAX(a, b)   ((a) > (b) ? (a) : (b))

#define min         MIN


/*
 ******************************************************************************
 *
 * definitions
 *
 ******************************************************************************
 */
struct __kfifo {
    unsigned char	*buffer;	/* the buffer holding the data */
    unsigned char	size;		/* the size of the allocated buffer */
    unsigned char	in;		/* data is added at offset (in % size) */
    unsigned char	out;		/* data is extracted from off. (out % size) */
};



/*
 ******************************************************************************
 *
 * global functions
 *
 ******************************************************************************
 */
/**
 * kfifo_reset - removes the entire FIFO contents
 * @fifo: the fifo to be emptied.
 */
static inline void kfifo_reset(struct __kfifo *fifo)
{
    fifo->in = fifo->out = 0;
}

/**
 * kfifo_size - returns the size of the fifo in bytes
 * @fifo: the fifo to be used.
 */
static inline unsigned char kfifo_size(struct __kfifo *fifo)
{
    return fifo->size;
}

/**
 * kfifo_len - returns the number of used bytes in the FIFO
 * @fifo: the fifo to be used.
 */
static inline unsigned char kfifo_len(struct __kfifo *fifo)
{
    register unsigned char	out;

    out = fifo->out;
    return fifo->in - out;
}

/**
 * kfifo_is_empty - returns true if the fifo is empty
 * @fifo: the fifo to be used.
 */
static inline char kfifo_is_empty(struct __kfifo *fifo)
{
    return fifo->in == fifo->out;
}

/**
 * kfifo_is_full - returns true if the fifo is full
 * @fifo: the fifo to be used.
 */
static inline char kfifo_is_full(struct __kfifo *fifo)
{
    return kfifo_len(fifo) == kfifo_size(fifo);
}


/*
 * kfifo_add_out internal helper function for updating the out offset
 */
static inline void __kfifo_add_out(struct __kfifo *fifo, unsigned char off)
{
    fifo->out += off;
}

/*
 * kfifo_add_in internal helper function for updating the in offset
 */
static inline void __kfifo_add_in(struct __kfifo *fifo, unsigned char off)
{
    fifo->in += off;
}

/*
 * __kfifo_off internal helper function for calculating the index of a
 * given offeset
 */
static inline unsigned char __kfifo_off(struct __kfifo *fifo, unsigned char off)
{
    return off & (fifo->size - 1);
}

/**
 * kfifo_avail - returns the number of bytes available in the FIFO
 * @fifo: the fifo to be used.
 */
static inline unsigned char kfifo_avail(struct __kfifo *fifo)
{
    return kfifo_size(fifo) - kfifo_len(fifo);
}


static inline void __kfifo_in_data(struct __kfifo *fifo, const void *from, unsigned char len)
{
    unsigned char	l;
    unsigned char	off;

    /*
     * Ensure that we sample the fifo->out index -before- we
     * start putting bytes into the kfifo.
     */
    off = __kfifo_off(fifo, fifo->in);

    /* first put the data starting from fifo->in to buffer end */
    l = min(len, fifo->size - off);
    memcpy(fifo->buffer + off, from, l);

    /* then put the rest (if any) at the beginning of the buffer */
    memcpy(fifo->buffer, (char *) from + l, len - l);
}

static inline void __kfifo_out_data(struct __kfifo *fifo, void *to, unsigned char len)
{
    unsigned char	l;
    unsigned char	off;

    /*
     * Ensure that we sample the fifo->in index -before- we
     * start removing bytes from the kfifo.
     */
    off = __kfifo_off(fifo, fifo->out);

    /* first get the data from fifo->out until the end of the buffer */
    l = min(len, fifo->size - off);
    memcpy(to, fifo->buffer + off, l);

    /* then get the rest (if any) from the beginning of the buffer */
    memcpy((char *) to + l, fifo->buffer, len - l);
    
}



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
extern void             kfifo_init(struct __kfifo *fifo, void *buffer, unsigned char size);

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
extern unsigned char    kfifo_in(struct __kfifo *fifo, const void *from, unsigned char len);

/**
 * kfifo_out - gets some data from the FIFO
 * @fifo: the fifo to be used.
 * @to: where the data must be copied.
 * @len: the size of the destination buffer.
 *
 * This function copies at most @len bytes from the FIFO into the
 * @to buffer and returns the number of copied bytes.
 */
extern unsigned char    kfifo_out(struct __kfifo *fifo, void *to, unsigned char len);




#endif  /* __CUBE_KFIFO_H__ */
