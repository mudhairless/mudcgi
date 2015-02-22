#include once "mudcgi.bi"
#ifndef fbext_nobuiltininstanciations
#define fbext_nobuiltininstanciations() 1
#endif
#include once "ext/detail/common.bi"
#include once "ext/strings/manip.bi"
#include once "ext/strings/split.bi"
#include once "ext/xml.bi"
#include once "mudcgi/html.bi"
#include once "crt/stdio.bi"

extern _LINKAGE_ QUERY_SEPERATOR as integer
common shared QUERY_METHOD as cgi.hMethod
common shared FORM_TYPE as cgi.hPost
common shared UECONTENT as string
common shared LAST_INDEX as integer

dim shared QUERY_SEPERATOR as integer

namespace cgi

private sub method_select(byref xmthd as string)

  var emethod = ucase(xmthd)

  select case emethod
    case "GET":
      QUERY_METHOd = hMethod.mGet

    case "PUT":
      QUERY_METHOD = hMethod.mPut

    case "POST":
      QUERY_METHOD = hMethod.mPost

    case "OPTIONS":
      QUERY_METHOD = hMethod.mOptions

    case "HEAD":
      QUERY_METHOD = hMethod.mHead

    case "TRACE":
      QUERY_METHOD = hMethod.mTrace

    case "PATCH":
      QUERY_METHOD = hMethod.mPatch

    case "DELETE":
      QUERY_METHOD = hMethod.mDelete

    case else:
      QUERY_METHOD = hMethod.mUnknown

  end select

end sub

sub init constructor

    QUERY_SEPERATOR = asc("&")
    FORM_TYPE = cgi.hPost.mNoFormData

    method_select(environ("REQUEST_METHOD"))

    UECONTENT = ""

    if(QUERY_METHOD = hMethod.mPost) then
      if instr(environ("CONTENT_TYPE"), "multipart/form-data;") > 0 then
          FORM_TYPE = cgi.hPost.mMultipart
      end if
      if environ("CONTENT_TYPE") = "application/x-www-form-urlencoded" then
          FORM_TYPE = cgi.hPost.mUrlEncoded
      end if
      var methodOverride = forms.param("_METHOD")
      if(methodOverride <> "") then
        method_select(methodOverride)
      else
        methodOverride = environ("HTTP_X_HTTP_METHOD_OVERRIDE")
        if(methodOverride <> "") then
          method_select(methodOverride)
        end if
      end if
    end if

end sub

#ifdef __FB_WIN32__
extern "windows" lib "kernel32"
    declare function GetEnvironmentStringsA () as zstring ptr
    'declare function FreeEnvironmentStrings ( byval as any ptr ) as integer
end extern
#endif

sub info()

    headers.ContentType("text/html")
    headers.EndHeaders

    var doc = new html.Document("MudCGI Information")
    doc->body()->appendChild("h2",ext.xml.text)->setText = "mudCGI Version:"
    doc->body()->appendChild("p",ext.xml.text)->setText = MUDCGI_VERSION_STRING
    doc->body()->appendChild("h2",ext.xml.text)->setText = "FreeBASIC Version:"
    redim fbvera() as string
    shellToArray("fbc -version", fbvera() )
    for n as integer = lbound(fbvera) to ubound(fbvera)
        if len(fbvera(n)) > 0 then doc->body()->appendChild("p",ext.xml.text)->setText = fbvera(n)
    next
    doc->body()->appendChild("h2",ext.xml.text)->setText = "FreeBASIC Extended Library Version:"
    doc->body()->appendChild("p",ext.xml.text)->setText = ext.FBEXT_VERSION_STRING
    doc->body()->appendChild("h2",ext.xml.text)->setText = "Environment:"
    #ifdef __FB_WIN32__

    var env = GetEnvironmentStringsA()
    var i = 0
    var tmp_s = ""
    var num_0 = 0

    var list = doc->body()->appendChild("ul")
    while 1
        select case env[i][0]
        case 0
            num_0 += 1
            if num_0 = 1 then
                if len(tmp_s) > 0 then
                    list->appendChild("li",ext.xml.text)->setText = tmp_s
                    tmp_s = ""
                end if
            else
                exit while
            end if
        case else
            num_0 = 0
            tmp_s = tmp_s & chr(env[i][0])
        end select
        i += 1
    wend
    'FreeEnvironmentStrings(env)
    #else
    doc->body()->appendChild("p",ext.xml.text)->setText =   "PATH: " & environ("PATH")
    doc->body()->appendChild("p",ext.xml.text)->setText =   "CGI Program: " & command(0)
    doc->body()->appendChild("p",ext.xml.text)->setText =   "Current Directory: " & curdir()
    doc->body()->appendChild("p",ext.xml.text)->setText =   "Server: " & environ("SERVER_SOFTWARE")
    doc->body()->appendChild("p",ext.xml.text)->setText =   "Host: " & environ("HTTP_HOST")
    doc->body()->appendChild("p",ext.xml.text)->setText =   "Remote Address: " & environ("REMOTE_ADDR")
    #endif
    print *doc
    end

end sub

sub nl2br( byref p as string )

    if instr(p, chr(13)) > 0 then
        ext.strings.replace( p, chr(13,10), "<br/>" )
    else
        ext.strings.replace( p, chr(10), "<br/>" )
    end if

end sub

function shellToHTML( byref command_ as string ) as string

    var ret = ""
    var temp = ""
    var ff = freefile

    open pipe command_ for input access read as #ff
    while not eof(ff)
        line input #ff, temp
        ret = ret & !"<br/>\n" & temp
        temp = ""
    wend

    close #ff
    temp = ""

    return ret

end function

sub shellToArray( byref command_ as string, array() as string )

    var ret = ""
    var temp = ""
    var ff = freefile

    open pipe command_ for input access read as #ff
    while not eof(ff)

        line input #ff, temp
        ret = ret & !"\n" & trim(temp)
        temp = ""

    wend

    close #ff
    ext.strings.explode( ret, !"\n", array() )
    ret = ""

end sub

function method( ) as hMethod
    return QUERY_METHOD
end function

sub escape( byref p as string )
    var temp = ext.xml.encode_entities( p )
    p = temp
end sub

sub unescape( byref p as string )
    var temp = ext.xml.decode_entities( p )
    p = temp
end sub

function unencode( byref e as string ) as string

    var ret = ""
    var index = 0

    while index < len(e)

        if(e[index] = asc("+") ) then
            ret = ret & " "

        elseif(e[index] = asc("%")) then
            var code = 0
            if(sscanf(cast(zstring ptr,@e[index+1]), "%2x", @code) <> 1) then code = asc("?")
            ret = ret & chr(code)
            index +=2

        else
            ret = ret & chr(e[index])

        end if

    index += 1

    wend

    ret = ret & !"\n"
    return ret

end function

function isSet( byref p as string ) as ext.bool

    var qstr = environ("QUERY_STRING")
    if len(qstr) < 1 then return ext.false
    var i = instr( qstr, p )
    var b = instr( qstr, chr(QUERY_SEPERATOR) & p )
    if b > 0 AND i > 0 then
        return ext.true
    else
        if p[0] = qstr[0] then return ext.true
        return ext.false
    end if

end function

sub includeHTML( byref filename as string )

    var ff = freefile
    open filename for binary access read as #ff
    var temp = ""

    while not eof(ff)

        line input #ff, temp
        print temp

    wend

    close #ff

end sub

function param( byref p as string, byref f as string = "", byref s as string = "=" ) as string

    var retval = ""
    var qstr = ""
    if f = "" then
        qstr = environ("QUERY_STRING")
    else
        qstr = f
    end if

    var i = instr( qstr, p )
    LAST_INDEX = i
    if i > 0 then

        if qstr[i+len(p)-1] = asc(s) then
            var x = i+len(p)
            while x < len(qstr) AND qstr[x] <> QUERY_SEPERATOR
                retval = retval & chr(qstr[x])
                x += 1
            wend
        end if

    end if

    return trim(unencode(retval))

end function

end namespace
