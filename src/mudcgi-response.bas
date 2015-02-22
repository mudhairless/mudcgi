#include once "mudcgi.bi"
#include once "ext/containers/hashtable.bi"

extern _LINKAGE_ QUERY_SEPERATOR as integer
common shared QUERY_METHOD as cgi.hMethod
common shared FORM_TYPE as cgi.hPost
common shared UECONTENT as string
common shared LAST_INDEX as integer

fbext_Instanciate( fbext_HashTable, ((string)))

using ext

dim shared __response_Headers as fbext_HashTable((string)) ptr
dim shared __response_buffer as string

namespace Response

  sub init_response constructor
    __response_Headers = new fbext_HashTable((string))(50)
    __response_Headers->insert("Content-type","text/html; charset=utf-8")
  end sub

  sub AddHeader(byref h as string, byref p as string)
    if(__response_Headers->find(h) = null) then
      __response_Headers->insert(h,p)
    else
      __response_Headers->remove(h)
      __response_Headers->insert(h,p)
    end if
  end sub

  sub Write(byref p as string)
    __response_buffer &= p
  end sub

  sub Clear()
    __response_buffer = ""
  end sub

  sub __header_printer(byref key as const string, byval value as string ptr)
    print key & ": " & *value & !"\r\n"
  end sub

  sub _End(byval endit as integer = 0)
    __response_Headers->forEach(@__header_printer)
    print !"\r\n"
    print __response_buffer
    __response_buffer = ""
    if(endit = 0) then
      system
    end if
  end sub

  sub deinit_response destructor
    _End(1)
    delete __response_Headers
  end sub

end namespace
