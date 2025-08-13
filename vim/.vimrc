let mapleader = " "
" Reference specific files easily
nnoremap <leader>exp i~/.config/exponent/exponent.txt<Esc>
nnoremap <leader>py i~/.config/exponent/python.txt<Esc>

" make copy paste apply to vim
set clipboard=unnamed,unnamedplus

" Map common delete commands to black hole in normal mode
nnoremap dd "_dd
nnoremap D "_D
nnoremap dw "_dw
nnoremap diw "_diw
nnoremap daw "_daw
nnoremap x "_x

" Map common delete commands to black hole in visual mode
vnoremap d "_d
vnoremap x "_x
vnoremap c "_c

" Keep the original 'd' available with leader
nnoremap <leader>d d
vnoremap <leader>d d

call plug#begin('~/.vim/plugged')
" List your plugins here
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'tpope/vim-fugitive' " Example plugin
Plug 'scrooloose/nerdtree' " Another example
" ghosttext for firefox
Plug 'raghur/vim-ghost', {'do': ':GhostInstall'}
call plug#end()

" -----------------PROMPT INJECTION COMMANDS---------------
let g:xml_functions = {}

" Define individual functions
function! PreambleFunc(params)
    return 'Before ANYTHING ELSE; read `@$HOME/agent_context/DEVELOPMENT_STANDARDS.md`, and follow all guidelines contained therein.'
endfunction

function! GreetFunc(params)
    if has_key(a:params, 'name')
        return 'Hello, ' . a:params.name . '!'
    else
        return 'Hello, stranger!'
    endif
endfunction

function! RepeatFunc(params)
    if has_key(a:params, 'text') && has_key(a:params, 'count')
        return repeat(a:params.text . ' ', str2nr(a:params.count))
    else
        return 'Error: missing parameters'
    endif
endfunction

function! SetupXMLFunctions()
    " Register functions using function() references
    let g:xml_functions['pre'] = function('PreambleFunc')
    let g:xml_functions['greet'] = function('GreetFunc')
    let g:xml_functions['repeat'] = function('RepeatFunc')
endfunction

call SetupXMLFunctions()

function! TransformXMLBlocks()
    let l:save_pos = getpos('.')
    
    try
        silent! %s/<\(\w\+\)\s*\([^>]*\)\/>/\=TransformToFunction(submatch(1), submatch(2), submatch(0))/g
    catch
        echom "XML transformation encountered an error, saving original content"
    finally
        call setpos('.', l:save_pos)
    endtry
endfunction

function! TransformToFunction(funcname, params_str, original_text)
    try
        if has_key(g:xml_functions, a:funcname)
            let params = ParseParameters(a:params_str)
            return call(g:xml_functions[a:funcname], [params])
        else
            return a:original_text
        endif
    catch
        return a:original_text
    endtry
endfunction

function! ParseParameters(params_str)
    let params = {}
    
    try
        let param_pairs = split(a:params_str, ',')
        
        for pair in param_pairs
            let pair = substitute(pair, '^\s*\|\s*$', '', 'g')
            if pair != ''
                let parts = split(pair, '=')
                if len(parts) == 2
                    let key = substitute(parts[0], '^\s*\|\s*$', '', 'g')
                    let value = substitute(parts[1], '^\s*\|\s*$', '', 'g')
                    let params[key] = value
                endif
            endif
        endfor
    catch
        " Return empty dict on parsing failure
    endtry
    
    return params
endfunction

autocmd BufWritePre *.txt,*.md call TransformXMLBlocks()
