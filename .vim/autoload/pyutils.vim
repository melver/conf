python << EOL
import vim, cgi
def PyHtmlEscape(line1,line2):
  r = vim.current.buffer.range(int(line1),int(line2))
  output = [cgi.escape(l) for l in r]
  r[:] = output
EOL

function! pyutils#setup()
  command -range PyHtmlEscape python PyHtmlEscape(<f-line1>,<f-line2>)
endfunction
