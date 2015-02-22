#include once "mudcgi.bi"
#include once "datetime.bi"
#include once "string.bi"

extern _LINKAGE_ QUERY_SEPERATOR as integer
common shared QUERY_METHOD as cgi.hMethod
common shared FORM_TYPE as cgi.hPost
common shared UECONTENT as string
common shared LAST_INDEX as integer

namespace cgi.headers

sub endHeaders()
	print !"\r\n";
end sub

sub setStatus( byval stat as integer, byref message as string )
	print using !"Status: ### $\r\n\r\n"; stat; message;
end sub

sub ContentType( byref x as string, byref charset as string = "utf-8" )
	print "Content-type: " & x & "; charset=" & charset & !"\r\n";
end sub

sub addHeader( byref x as string )
	print x & !"\r\n";
end sub

sub clearCookie( byref key as string )

	setCookie( key, "" )

end sub

function getCookie( byref key as string ) as string

	var retval = ""
	var qstr = environ("HTTP_COOKIE")
	var i = instr( qstr, key )
	if i > 0 then

		if qstr[i+len(key)-1] = asc("=") then
			var x = i+len(key)
			while x < len(qstr) AND qstr[x] <> asc(";")
				retval = retval & chr(qstr[x])
				x += 1
			wend
		end if

	end if

	return trim(retval)

end function

sub setCookie( byref key as string, byref value as string, _
				byref domain as string = "", byref path as string = "/", byval expire as long = 3600 )

	var tdomain = domain
	if tdomain = "" then tdomain = environ("HTTP_HOST")

	var expires = Format( DateAdd( "s", expire, Now ), "ddd, dd-mm-yyy hh:mm:ss G\MT" )

	print using !"Set-Cookie: &=&; domain=&; expires=&; path=&; Version=1;\r\n"; key; value; tdomain; expires; path;

end sub

end namespace
