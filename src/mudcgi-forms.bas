#include once "mudcgi.bi"
#ifndef fbext_nobuiltininstanciations
#define fbext_nobuiltininstanciations() 1
#endif
#include once "ext/strings/split.bi"
#include once "ext/strings/manip.bi"
#include once "ext/containers/list.bi"

extern _LINKAGE_ QUERY_SEPERATOR as integer
common shared QUERY_METHOD as cgi.hMethod
common shared FORM_TYPE as cgi.hPost
common shared UECONTENT as string
common shared LAST_INDEX as integer

'dim shared UECONTENT as string
dim shared FILEDATALIST as string

#ifdef __FB_LINUX__
extern "C" 'not in fb's headers
declare function mkstemp( byval template as zstring ptr ) as integer
end extern
#define tmpname_t "/tmp/mcgi101XXXXXX"
#else 'or defined at all on windows
#define mkstemp(x) mktemp( (x) )
#define tmpname_t "C:\temp\mcgiXXXXXX"
#endif



namespace cgi
declare function unencode( byref e as string ) as string
end namespace

enum content_type explicit
	form_data
	other
end enum

type multipartdata
	key as string
	value as string
	ctype as content_type
	filename as string
	declare destructor
	declare constructor
	declare constructor( byref key_ as const string, byref valu as const string, byval ctypes as content_type = content_type.form_data, byref filen as const string = "" )
	declare constructor( byref rhs as const multipartdata )
end type

declare operator = ( byref lhs as multipartdata, byref rhs as multipartdata ) as integer
declare operator <> ( byref lhs as multipartdata, byref rhs as multipartdata ) as integer


fbext_Instanciate( fbExt_List, ((multipartdata)) )

destructor multipartdata

	key = ""
	value = ""
	filename = ""

end destructor

constructor multipartdata
end constructor

constructor multipartdata( byref rhs as const multipartdata )
	key = rhs.key
	value = rhs.value
	ctype = rhs.ctype
	filename = rhs.filename
end constructor

constructor multipartdata( byref key_ as const string, byref valu as const string, byval ctypes as content_type = content_type.form_data, byref filen as const string = "" )

	key = key_
	value = valu
	ctype = ctypes
	filename = filen

end constructor

operator =( byref lhs as multipartdata, byref rhs as multipartdata ) as integer

	if lhs.key = rhs.key then return ext.true
	return ext.false

end operator

operator <>( byref lhs as multipartdata, byref rhs as multipartdata ) as integer

	if lhs.key = rhs.key then return ext.false
	return ext.true

end operator


namespace cgi.forms


function method() as hPost
	return FORM_TYPE
end function

private sub processform( )

	var conlen = valint(environ("CONTENT_LENGTH"))
	var content = ""
	var ff = FreeFile
	open cons for input as #ff

	dim as ubyte ib

	for n as integer = 1 to conlen

		get #ff, , ib
		content = content & chr(ib)

	next

	close #ff

	UECONTENT = content

end sub

private sub ParseMultiPart( formdata() as string )

	for n as integer = lbound(formdata) to ubound(formdata)

		var i = instr( formdata(n), !"name=\"" )

		i += 6

		UECONTENT = UECONTENT & chr(QUERY_SEPERATOR)

		while formdata(n)[i-1] <> asc(!"\"")
			UECONTENT = UECONTENT & chr(formdata(n)[i-1])
			i += 1
		wend

		var b = instr(i, formdata(n), "filename=" )
		if b > 0 then
			UECONTENT = UECONTENT & "="

			b += 9

			while formdata(n)[b-1] <> asc(!"\"")
				UECONTENT = UECONTENT & chr(formdata(n)[b-1])
				b += 1
			wend

		end if

	next

	print UECONTENT



end sub

	function param( byref key as string ) as string

		if FORM_TYPE = cgi.hPost.mNoFormData then return ""

			''x-url-encoded
			if FORM_TYPE = cgi.hPost.mUrlEncoded then

				if UECONTENT = "" then

					processform()

					UECONTENT = unencode(UECONTENT)

				end if

				return cgi.param( key, UECONTENT )

			end if

		if FORM_TYPE = cgi.hPost.mMultipart then

			var bound = cgi.param( "boundary", environ("CONTENT_TYPE") )

			if UECONTENT = "" then

				processform()
				redim fdata() as string
				ext.strings.explode( UECONTENT, bound, fdata() )

				ParseMultiPart( fdata() )

			end if

			return cgi.param( key, UECONTENT )

		end if

	end function

	function fileMIMEtype( byref key as string ) as string

		if UECONTENT = "" then
			processform
		end if
		redim fdata() as string
		var bound = cgi.param( "boundary", environ("CONTENT_TYPE") )

			ext.strings.explode( UECONTENT, bound, fdata() )

			for n as integer = lbound(fdata) to ubound(fdata)

				var i = instr( fdata(n), !"name=\"" & key & !"\"" )

				if i > 0 then

						var qs = QUERY_SEPERATOR

						QUERY_SEPERATOR = asc(!"\r")

						var ret = cgi.param( "Content-Type", fdata(n), ":" )

						QUERY_SEPERATOR = qs

						return ret

				end if

			next
	return ""

	end function

	function fileData( byref key as string ) as string
		return ""
	end function

end namespace
