'mudcgi-html.bas
#include once "mudcgi.bi"
#include once "mudcgi/html.bi"
#include once "ext/xml.bi"

namespace cgi.html

constructor Document( byref title as string, byref doctype_ as string = doctype.HTML4Transitional )

    m_doct = doctype_
    m_html = new ext.xml.tree
    var h = m_html->root->appendChild("html")

    select case doctype_
        case doctype.XHTML10Transitional, doctype.XHTML10Strict, doctype.XHTML10Frameset, doctype.XHTML11
            h->attribute("xmlns") = "http://www.w3.org/1999/xhtml"
    end select

    m_h = h->appendChild("head")

    m_h->appendChild("meta")
        m_h->child(0)->attribute("name") = "generator"
        m_h->child(0)->attribute("content") = MUDCGI_VERSION_STRING

    var t = m_h->appendChild("title", ext.xml.node_type_e.text)
    t->setText = title

    m_b = h->appendChild("body")

end constructor

operator Document.cast() as string
    return m_doct & !"\n" & *m_html
end operator

function Document.head() as ext.xml.node ptr

    return m_html->root->child(0)->child(0)

end function

function Document.body() as ext.xml.node ptr

    return m_html->root->child(0)->child(1)

end function

destructor Document()

    if m_html <> ext.null then delete m_html
    m_doct = ""

end destructor

end namespace
