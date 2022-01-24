<# :
  @echo off
    powershell /nologo /noprofile /command ^
         "&{[ScriptBlock]::Create((cat """%~f0""") -join [Char[]]10).Invoke(@(&{$args}%*))}"
  exit /b
#>
Write-Host Hello, $args[0] -fo Green
#You programm...
pause