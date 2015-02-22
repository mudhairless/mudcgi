'HTML generation helper functions

#include once "ext/xml.bi"

namespace cgi.html

    const as string br = "<br/>"

    namespace doctype
        const as string HTML4Transitional = !"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">"
        const as string HTML4Strict = !"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">"
        const as string HTML4Frameset = !"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">"
        const as string XHTML10Transitional = !"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
        const as string XHTML10Strict = !"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
        const as string XHTML10Frameset = !"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">"
        const as string XHTML11 = !"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">"
        const as string HTML5 = "<!DOCTYPE html>"
    end namespace

    type Document
        declare constructor( byref title as string, byref doctype_ as string = doctype.HTML4Transitional )
        declare destructor

        declare operator cast() as string

        declare function head() as ext.xml.node ptr

        declare function body() as ext.xml.node ptr

        private:
        as ext.xml.tree ptr m_html
        as ext.xml.node ptr m_b
        as ext.xml.node ptr m_h
        as string m_doct
    end type

end namespace
