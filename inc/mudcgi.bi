'Mud's cgi helper library header for including
#inclib "mudcgi"
#ifndef fbext_nobuiltininstanciations
#define fbext_nobuiltininstanciations() 1
#endif
#include once "ext/detail/common.bi"
#ifdef MAKEDLL
    #define _LINKAGE_ import
#else
    #define _LINKAGE_
#endif

const MUDCGI_VERSION_MAJOR = 0
const MUDCGI_VERSION_MINOR = 2
const MUDCGI_VERSION_PATCH = 0
const MUDCGI_VERSION_STRING as string = "mudCGI Library Version " & MUDCGI_VERSION_MAJOR & "." & MUDCGI_VERSION_MINOR & "." & MUDCGI_VERSION_PATCH

namespace cgi


    enum hMethod explicit
        mGet
        mPost
        mOptions
        mPut
        mDelete
        mHead
        mTrace
        mPatch
        mUnknown
    end enum

    enum hPost explicit
        mNoFormData
        mMultipart
        mUrlEncoded
    end enum

    declare sub info()
    declare function shellToHTML( byref command_ as string ) as string
    declare sub shellToArray( byref command_ as string, array() as string )
    declare sub includeHTML( byref filename as string )
    declare sub nl2br( byref p as string )
    declare function isSet( byref p as string ) as ext.bool
    declare function param( byref p as string, byref f as string = "", byref s as string = "="  ) as string
    declare function method( ) as hMethod
    declare sub escape( byref p as string )
    declare sub unescape( byref p as string )



    namespace headers

        declare sub ContentType( byref x as string, byref charset as string = "utf-8" )
        declare sub setCookie( byref key as string, byref value as string, _
                    byref domain as string = "", byref path as string = "/", byval expire as long = 3600 )
        declare function getCookie( byref key as string ) as string
        declare sub clearCookie( byref key as string )
        declare sub addHeader( byref x as string )
        declare sub setStatus( byval stat as integer, byref message as string )
        declare sub endHeaders()

    end namespace

    namespace forms

        declare function method() as hPost
        declare function param( byref key as string ) as string
        declare function fileMIMEtype( byref key as string ) as string
        declare function fileData( byref key as string ) as string

    end namespace

end namespace

namespace Request
  declare function Method() as cgi.hMethod
  declare function QueryString(byref p as string) as string
  declare function Header(byref p as string) as string
  declare function ServerVariable(byref p as string) as string
end namespace

namespace Response
  declare sub AddHeader(byref h as string, byref p as string)
  declare sub Write(byref p as string)
  declare sub BinaryWrite(byval buf as ubyte ptr, byval buflen as uinteger)
  declare sub Clear()
  declare sub _End(byval endit as integer = 0)
end namespace

extern _LINKAGE_ QUERY_SEPERATOR as integer
