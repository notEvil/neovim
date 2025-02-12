
" Use a different file name for each run.
let s:sequence = 1

" Check that "lines" inside a legacy function has no error.
func CheckLegacySuccess(lines)
  let cwd = getcwd()
  let fname = 'XlegacySuccess' .. s:sequence
  let s:sequence += 1
  call writefile(['func Func()'] + a:lines + ['endfunc'], fname)
  try
    exe 'so ' .. fname
    call Func()
  finally
    delfunc! Func
    call chdir(cwd)
    call delete(fname)
  endtry
endfunc

" Check that "lines" inside a legacy function results in the expected error
func CheckLegacyFailure(lines, error)
  let cwd = getcwd()
  let fname = 'XlegacyFails' .. s:sequence
  let s:sequence += 1
  call writefile(['func Func()'] + a:lines + ['endfunc', 'call Func()'], fname)
  try
    call assert_fails('so ' .. fname, a:error)
  finally
    delfunc! Func
    call chdir(cwd)
    call delete(fname)
  endtry
endfunc

" Execute "lines" in a legacy function, translated as in
" CheckLegacyAndVim9Success()
func CheckTransLegacySuccess(lines)
  let legacylines = a:lines->deepcopy()->map({_, v ->
                              \ v->substitute('\<VAR\>', 'let', 'g')
                              \  ->substitute('\<LET\>', 'let', 'g')
                              \  ->substitute('\<LSTART\>', '{', 'g')
                              \  ->substitute('\<LMIDDLE\>', '->', 'g')
                              \  ->substitute('\<LEND\>', '}', 'g')
                              \  ->substitute('\<TRUE\>', '1', 'g')
                              \  ->substitute('\<FALSE\>', '0', 'g')
                              \  ->substitute('#"', ' "', 'g')
                              \ })
  call CheckLegacySuccess(legacylines)
endfunc

" Execute "lines" in a legacy function
" Use 'VAR' for a declaration.
" Use 'LET' for an assignment
" Use ' #"' for a comment
" Use LSTART arg LMIDDLE expr LEND for lambda
" Use 'TRUE' for 1
" Use 'FALSE' for 0
func CheckLegacyAndVim9Success(lines)
  call CheckTransLegacySuccess(a:lines)
endfunc

" Execute "lines" in a legacy function
" Use 'VAR' for a declaration.
" Use 'LET' for an assignment
" Use ' #"' for a comment
func CheckLegacyAndVim9Failure(lines, error)
  if type(a:error) == type('string')
    let legacyError = error
  else
    let legacyError = error[0]
  endif

  let legacylines = a:lines->deepcopy()->map({_, v ->
                              \ v->substitute('\<VAR\>', 'let', 'g')
                              \  ->substitute('\<LET\>', 'let', 'g')
                              \  ->substitute('#"', ' "', 'g')
                              \ })
  call CheckLegacyFailure(legacylines, legacyError)
endfunc
