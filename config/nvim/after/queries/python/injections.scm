; extends

(assignment
  left: (identifier) @_var
  right: (string
           (string_content) @injection.content)
  (#any-of? @_var "HTML" "HTML_TEMPLATE")
  (#set! injection.language "html"))
