#include <ruby.h>

void rb_objspace_each_objects(
    int (*callback)(void *start, void *end, size_t stride, void *data),
    void *data);

struct os_heap_inspector_struct {
    size_t num;
    VALUE data;
};

static int
os_heap_mark_inspector(void *vstart, void *vend, size_t stride, void *data)
{
    struct os_heap_inspector_struct *ohis = (struct os_heap_inspector_struct *)data;
    struct RBasic *p = (struct RBasic *)vstart, *pend = (struct RBasic *)vend;
    volatile VALUE v;

    for (; p != pend; p = (size_t)p + stride) {
        if (p->flags) {
            if (p->flags & FL_MARK) {
                rb_ary_store(ohis->data, ohis->num, Qtrue);
            }
            else {
                rb_ary_store(ohis->data, ohis->num, Qfalse);
            }
        }
        else {
            rb_ary_store(ohis->data, ohis->num, Qnil);
        }
        ohis->num++;
    }

    return 0;
}


/*
 *  call-seq:
 *     HeapInspector.mark_inspect!(array) -> 100
 *
 *  Inspect for Heap.
 *  
 *  It args a array as:
 *  [true, false, ... nil, ..., 0]
 *
 *  It return value is heap objects count.
 *
 *  Element:
 *  True is marked. Flase is not marked. FREE RVALUE is nil.
 *  0(zero) is sentry.
 *
 */

VALUE
heap_inspector_mark_inspect(VALUE self, VALUE ary)
{
    struct os_heap_inspector_struct ohis;
    ohis.num = 0;
    ohis.data = ary;
    rb_objspace_each_objects(os_heap_mark_inspector, &ohis);
    rb_ary_store(ohis.data, ohis.num, SIZET2NUM(0));
    return SIZET2NUM(ohis.num);
}

void
Init_heap_inspector(void)
{
  VALUE rb_cHeapInspector;

  rb_cHeapInspector = rb_define_class("HeapInspector", rb_cObject);
  rb_define_singleton_method(rb_cHeapInspector, "mark_inspect!", heap_inspector_mark_inspect, 1);
}
