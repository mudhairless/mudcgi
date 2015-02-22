#include once "mudcgi.bi"

extern _LINKAGE_ QUERY_SEPERATOR as integer
common shared QUERY_METHOD as cgi.hMethod
common shared FORM_TYPE as cgi.hPost
common shared UECONTENT as string
common shared LAST_INDEX as integer

namespace Request

function Method() as cgi.hMethod
  return QUERY_METHOD
end function

function QueryString(byref p as string) as string
  return cgi.param(p)
end function

function Header(byref p as string) as string
  return environ("HTTP_"&ucase(p))
end function

function ServerVariable(byref p as string) as string
  return environ(ucase(p))
end function

end namespace
