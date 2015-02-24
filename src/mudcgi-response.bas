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
dim shared __response_bin_buffer as ubyte ptr
dim shared __response_bin_buffer_len as uinteger

namespace Response

  sub init_response constructor
    __response_Headers = new fbext_HashTable((string))(50)
    __response_Headers->insert("Content-type","text/html; charset=utf-8")
    __response_bin_buffer_len = 0
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
    if(__response_bin_buffer_len = 0) then
    __response_buffer &= p
    else
      print !"Status: 500 Internal Server Error\r\n\r\n"
      print "ERROR: Cannot combine Response.Write and Response.BinaryWrite"
      end 500
    end if
  end sub

  sub BinaryWrite(byval buf as ubyte ptr, byval buflen as uinteger)
    var cur_buf_len = __response_bin_buffer_len
    var new_buf_len = cur_buf_len + buflen
    var new_buf = new ubyte[new_buf_len]
    if(cur_buf_len > 0) then
      memcpy(new_buf,__response_bin_buffer,cur_buf_len)
      delete[] __response_bin_buffer
    end if
    memcpy(new_buf+cur_buf_len,buf,buflen)
    __response_bin_buffer = new_buf
  end sub

  sub Clear()
    if(__response_bin_buffer_len > 0) then
      delete[] __response_bin_buffer
      __response_bin_buffer_len = 0
    else
      __response_buffer = ""
    end if
    delete __response_Headers
    __response_Headers = new fbext_HashTable((string))(50)
    __response_Headers->insert("Content-type","text/html; charset=utf-8")
  end sub

  sub __header_printer(byref key as const string, byval value as string ptr)
    print key & ": " & *value & !"\r\n";
  end sub

  sub _End(byval endit as integer = 0)
    __response_Headers->forEach(@__header_printer)
    if(__response_Headers->find("Status") = ext.null) then
      print !"Status: 200 Ok\r\n";
    end if
    if(__response_bin_buffer_len > 0) then
      print "Content-Length: " & __response_bin_buffer_len & !"\r\n";
      print !"\r\n";
      var ff = freefile
      open CONS for output as #ff
        put #ff, *__response_bin_buffer, __response_bin_buffer_len
      close #ff
      delete[] __response_bin_buffer
      __response_bin_buffer_len = 0
    else
      print "Content-Length: " & len(__response_buffer) & !"\r\n";
      print !"\r\n";
      print __response_buffer
      __response_buffer = ""
    end if

    if(endit = 0) then
      system
    end if
  end sub

  sub deinit_response destructor
    _End(1)
    delete __response_Headers
  end sub

end namespace
