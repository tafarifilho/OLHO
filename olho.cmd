echo off

set versao=1.0.3

TITLE DGJUD Utilitario de PDF

REM Definicao de Variaveis Path
set TMP=%~dp0temp
set TEMP=%~dp0temp
Set path=%~dp0bin;%~dp0bin\ImageMagick;%~dp0bin\Tesseract\;%~dp0bin\ScanTailor\
Set TESSDATA_PREFIX=%~dp0bin\Tesseract\
Set MAGICK_HOME=%~dp0bin\ImageMagick
Set MAGICK_CONFIGURE_PATH=%~dp0bin\ImageMagick\config
Set MAGICK_CODER_FILTER_PATH=%~dp0bin\ImageMagick\modules\filters
Set MAGICK_CODER_MODULE_PATH=%~dp0bin\ImageMagick\modules\coders
Set LD_LIBRARY_PATH=%~dp0bin\ImageMagick

REM Criacao de Diretorios se nao existirem
IF NOT EXIST "%~dp0in" MKDIR "%~dp0in"
IF NOT EXIST "%~dp0completed" MKDIR "%~dp0completed"
IF NOT EXIST "%~dp0out" MKDIR "%~dp0out"
IF NOT EXIST "%~dp0log" MKDIR "%~dp0log"
IF NOT EXIST "%~dp0temp" MKDIR "%~dp0temp"

REM Iniciar o ScanTailor
cls
echo ________________________________________________________________________________
chgcolor A
echoj $09 
chgcolor f9
echoj "...AGUARDANDO TERMINO DO SCANTAILOR..." $0a
chgcolor A
chgcolor 7
echo ________________________________________________________________________________
echo.

scantailor
cd %~dp0in/out
move *.tif %~dp0out/ > NUL 2>&1
cd %~dp0

REM Exibicao de informacoes basicas
cls
echo ________________________________________________________________________________
chgcolor A
echoj $09 
chgcolor f9
echoj " DGJUD Utilitario de PDF %versao% " $0a $0a
chgcolor A
echoj $09 "Adaptado, atualizado e modificado a partir do PDFx." $0a
echoj $09 "Mantida licenca GNU GPL v3" $0a
echoj $09 "(c) 2013 Lime Consultants [www.limeconsultants.com]" $0a
echoj $09 "(c) 2016 Tafarifilho [github.com/tafarifilho]" $0a $0a
chgcolor D
echoj $09 "As imagens processadas e o arquivo do projeto do ScanTailor sera" $0a
echoj $09 "automaticamente copiado da pasta" $0a
chgcolor A
echoj $09 "                                'in'" $0a
chgcolor D
echoj $09 "para dentro da pasta" $0a
chgcolor A
echoj $09 "                                'out'" $0a
chgcolor D
echoj $09 "para inicio do aplicativo que ira gerar o arquivo PDF dentro da" $0a
echoj $09 "pasta" $0a
chgcolor A 
echoj $09 "                              'completed'." $0a 
chgcolor 7
echo ________________________________________________________________________________
echo.

REM Iniciando o menu
goto menu

:menu
  ECHO.
  ECHO 1 - Iniciar a conversao das imagens para PDF com OCR
  ECHO 2 - Sair do aplicativo

  ECHO.
  SET /P M=Digite 1 ou 2 e pressione ENTER: 
  IF (%M%) == () GOTO menuerror
  IF %M%==1 GOTO dometa
  IF %M%==2 GOTO killme
  IF DEFINED (%M%) GOTO menuerror

REM Erro na escolha da opcao retorna ao menu
:menuerror
  echo. 
  chgcolor c
  echoj "Voce inseriu uma opcao invalida." 
  chgcolor 7
  echo.
  goto menu

REM Meta informacoes do PDF Title, Author, Subject, and Keywords
:dometa
  cls
  echo ________________________________________________________________________________
  chgcolor A
  echoj $09 
  chgcolor A
  echoj "Insira as informacoes para o PDF" $0a
  chgcolor 7
  echo ________________________________________________________________________________
  echo.

  SET /P pfilename=Insira o NOME FINAL DO ARQUIVO:  
  
  cd %~dp0out
  echo Title^: ^"DIGITALIZACAO^" >  metadata.txt
  echo Author^: ^"PRODUZIDO POR DGJUD^" >>  metadata.txt
  echo Subject^: ^"%pfilename%^" >>  metadata.txt
  echo Keywords^: ^"%pfilename%^" >>  metadata.txt
  echo Application^: ^"DGJUD - OLHO %versao%^" >>  metadata.txt
  cd %~dp0
  goto setlang

REM Definir a Linguagem do OCR
:setlang
  cls
  echo ________________________________________________________________________________
  chgcolor A
  echoj $09 
  chgcolor A
  echoj "Escolha a opcao da Lingua do Texto" $0a
  chgcolor 7
  echo ________________________________________________________________________________
  echo.

  echo 1 - Portuguesa
  echo 2 - Francesa
  echo 3 - Italiana
  echo 4 - Espanhola
  echo 5 - Outra (exibir a lista)
  ECHO.
  SET /P L=Digite o valor e pressione ENTER: 
  IF (%L%) == () GOTO setlang
  IF %L%==1 (SET lang=por)
  IF %L%==2 (SET lang=fra)
  IF %L%==3 (SET lang=ita)
  IF %L%==4 (SET lang=spa)
  IF %L%==5 (GOTO alllang)
  GOTO doocr

REM Escolha a lingua a partir da lista das linguas disponiveis
:alllang
  echo.
  tesseract.exe --list-langs
  echo.
  SET /P lang=Entre o codigo da lingua para o OCR: 
  IF (%lang%) == () GOTO setlang
  GOTO doocr

REM Inicio do reconhecimento de OCR pelo Tesseract
:doocr
  cls
  IF NOT EXIST %~dp0bin\Tesseract\tessdata\%lang%.traineddata GOTO setlang
  cd %~dp0out

  REM ------------------------------------------
  REM BUG - WINDOWS LIMITA A QUANTIDADE DE START
  REM CRIADO UM CONTADOR QUE IDENTIFICA A QUANTIDADE DE IMAGENS NA PASTA
  REM QUANDO FOR MAIOR IGUAL A 70 ARQUIVOS, O SISTEMA NÃO FAZ EM PARALELO, MAS EM SERIE
  REM ------------------------------------------

  SET count=0 & for %%a in (*.tif) do @(SET /a count+=1 >nul)

  if %count% GEQ 70 (
    FOR %%a in (*.tif) DO (
      echoj $0a "Reconhendo o texto de %%a com" $0a
      tesseract.exe -l %lang% %%a %%~na hocr
    )
  ) else (
    FOR %%a in (*.tif) DO (
      start tesseract.exe -l %lang% %%a %%~na hocr
    )
  )

  cd ..
  cls
  echo ________________________________________________________________________________
  chgcolor A
  echoj $09 
  chgcolor A
  echoj "CUIDADO!!! SOMENTE continue se TODAS as janelas do OCR ja fecharam!!!" $0a
  chgcolor 7
  echo ________________________________________________________________________________
  echo.  
  pause
  goto dopdf

REM Criando o PDF a partir das imagens e do reconhecimento do OCR
:dopdf
  cls
  echo ________________________________________________________________________________
  chgcolor A
  echoj $09 
  chgcolor A
  echoj "O PDF ESTA SENDO GERADO, AGUARDE!!!" $0a
  chgcolor 7
  echo ________________________________________________________________________________
  echo.  
  cd %~dp0out
  pdfbeads.exe --pagelayout SinglePage --meta metadata.txt *.tif > out.pdf
  move out.pdf %~dp0completed/%pfilename%.pdf > NUL 2>&1
  ECHO.
  cd %~dp0
  goto dofinal

REM Conclusão se o PDF ficou bom para apagar os arquivos temporários ou cancelar
:dofinal
  cls
  echo ________________________________________________________________________________
  chgcolor A
  echoj $09 
  chgcolor A
  echoj "O PDF gerado ficou perfeito? Se nao ficou, interrompa agora para " $0a
  echoj "preservar as imagens." $0a $0a
  echoj "Caso contrario. Continue." $0a
  chgcolor 7
  echo ________________________________________________________________________________
  echo.

  echo 1 - Continuar
  echo 2 - Interromper e preservar imagens
  ECHO.
  SET /P L=Digite 1 para CONTINUAR ou 2 para INTERROMPER e pressione ENTER: 
  IF (%L%) == () GOTO dofinal
  IF %L%==1 GOTO dodelete
  IF %L%==2 GOTO doend

REM Apagando os arquivos do IN e OUT
:dodelete
  cd %~dp0
  busybox rm -r %~dp0in
  busybox sleep 2
  mkdir %~dp0in
  goto doend

REM Here we finish the process.
:doend
  echo ________________________________________________________________________________
  chgcolor A
  echoj $09 
  chgcolor A
  echoj "AGUARDE O FECHAMENTO DA JANELA " $0a
  chgcolor 7
  echo ________________________________________________________________________________
  echo.
  cd %~dp0
  busybox rm -r %~dp0out
  busybox sleep 2
  mkdir %~dp0out
  busybox rm -r %~dp0temp
  busybox sleep 2
  mkdir %~dp0temp
  exit