/***********************************************************************/
/*                                                                     */
/*                              CamlIDL                                */
/*                                                                     */
/*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         */
/*                                                                     */
/*  Copyright 1999 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License.         */
/*                                                                     */
/***********************************************************************/

/* $Id: camlidlruntime.h,v 1.1 2003-10-28 18:52:36 ijtrotts Exp $ */

/* Helper functions for stub code generated by camlidl */

#include <stddef.h>
#include <caml/mlvalues.h>

/* Functions for allocating in the Caml heap */

#if !defined(CAMLVERSION) || CAMLVERSION >= 201
#define camlidl_alloc alloc
#define camlidl_alloc_small alloc_small
#else
value camlidl_alloc(mlsize_t size, tag_t tag);
#define camlidl_alloc_small alloc
#endif

/* Helper functions for conversion */

value camlidl_find_enum(int n, int *flags, int nflags, char *errmsg);
value camlidl_alloc_flag_list (int n, int *flags, int nflags);
mlsize_t camlidl_ptrarray_size(void ** array);

/* Malloc-like allocation with en masse deallocation */

typedef void (* camlidl_free_function)(void *);

struct camlidl_block_list {
  camlidl_free_function free_fn;
  void * block;
  struct camlidl_block_list * next;
};

struct camlidl_ctx_struct {
  int flags;
  struct camlidl_block_list * head;
};

#define CAMLIDL_TRANSIENT 1
#define CAMLIDL_ADDREF 2

typedef struct camlidl_ctx_struct * camlidl_ctx;

void * camlidl_malloc(size_t sz, camlidl_ctx ctx);
void camlidl_free(camlidl_ctx ctx);
char * camlidl_malloc_string(value mlstring, camlidl_ctx ctx);
void camlidl_register_allocation(camlidl_free_function free_fn,
                                 void * block,
                                 camlidl_ctx ctx);

/* Helper functions for handling COM interfaces */

#ifdef _WIN32
#include <objbase.h>
#else
#define interface struct
typedef struct {
  unsigned int Data1;
  unsigned short Data2, Data3;
  unsigned char Data4[8];
} GUID, IID;
typedef IID * REFIID;
typedef int HRESULT;
#define S_OK 0
typedef unsigned long ULONG;
#define SetErrorInfo(x,y)
#define STDMETHODCALLTYPE
#endif

typedef HRESULT HRESULT_int;
typedef HRESULT HRESULT_bool;

#if defined(__GNUC__)
#define DECLARE_VTBL_PADDING void * padding; void * constr;
#define VTBL_PADDING 0, 0,
#else
#define DECLARE_VTBL_PADDING
#define VTBL_PADDING
#endif

value camlidl_lookup_method(char * name);

void * camlidl_unpack_interface(value vintf, camlidl_ctx ctx);
value camlidl_pack_interface(void * intf, camlidl_ctx ctx);

struct camlidl_component;

struct camlidl_intf {
  void * vtbl;
  value caml_object;
  IID * iid;
  struct camlidl_component * comp;
  void * typeinfo;
};

struct camlidl_component {
  int numintfs;
  long refcount;
  struct camlidl_intf intf[1];
};

value camlidl_make_interface(void * vtbl, value caml_object, IID * iid,
                             int has_dispatch);

/* Basic methods (QueryInterface, AddRef, Release) for COM objects
   encapsulating a Caml object */

HRESULT STDMETHODCALLTYPE
camlidl_QueryInterface(struct camlidl_intf * self, REFIID iid,
                       void ** object);
ULONG STDMETHODCALLTYPE
camlidl_AddRef(struct camlidl_intf * self);
ULONG STDMETHODCALLTYPE
camlidl_Release(struct camlidl_intf * self);

/* Extra methods for the IDispatch interface */

#ifdef _WIN32
HRESULT STDMETHODCALLTYPE
camlidl_GetTypeInfoCount(struct camlidl_intf * self, UINT * count_type_info);
HRESULT STDMETHODCALLTYPE
camlidl_GetTypeInfo(struct camlidl_intf * self, UINT iTypeInfo,
                    LCID localization, ITypeInfo ** res);
HRESULT STDMETHODCALLTYPE
camlidl_GetIDsOfNames(struct camlidl_intf * self, REFIID iid,
                      OLECHAR** arrayNames, UINT countNames,
                      LCID localization, DISPID * arrayDispIDs);
HRESULT STDMETHODCALLTYPE
camlidl_Invoke(struct camlidl_intf * self, DISPID dispidMember, REFIID iid,
               LCID localization, WORD wFlags, DISPPARAMS * dispParams,
               VARIANT * varResult, EXCEPINFO * excepInfo, UINT * argErr);
#endif

/* Lookup a method in a method suite */
/* (Should be in mlvalues.h?) */

#define Lookup(obj, lab) \
  Field (Field (Field (obj, 0), ((lab) >> 16) / sizeof (value)), \
         ((lab) / sizeof (value)) & 0xFF)

/* Raise an error */
void camlidl_error(HRESULT errcode, char * who, char * msg);

/* Handle HRESULTs */

void camlidl_check_hresult(HRESULT hr);
value camlidl_c2ml_Com_HRESULT_bool(HRESULT_bool * hr, camlidl_ctx ctx);
void camlidl_ml2c_Com_HRESULT_bool(value v, HRESULT_bool * hr, 
                                   camlidl_ctx ctx);
value camlidl_c2ml_Com_HRESULT_int(HRESULT_int * hr, camlidl_ctx ctx);
void camlidl_ml2c_Com_HRESULT_int(value v, HRESULT_int * hr, camlidl_ctx ctx);

/* Handle uncaught exceptions in C-to-ML callbacks */

HRESULT camlidl_result_exception(char * methname, value exn_bucket);
void camlidl_uncaught_exception(char * methname, value exn_bucket);

/* Conversion functions for OLE Automation types */

#ifdef _WIN32
void camlidl_ml2c_Com_BSTR(value s, BSTR * res, camlidl_ctx ctx);
value camlidl_c2ml_Com_BSTR(BSTR * bs, camlidl_ctx ctx);
#endif


