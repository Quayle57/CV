% terminal-cv.cls: one-page A4 CV with a terminal-window sidebar.
% Fonts are loaded from \cvfontdir (define it before \documentclass).
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{terminal-cv}[2026/10/30 Terminal-style CV]
\LoadClass[10pt]{article}

\RequirePackage[a4paper, margin=14mm]{geometry}
\RequirePackage{xcolor}
\RequirePackage{fontspec}
\RequirePackage{polyglossia}
\RequirePackage[most]{tcolorbox}
\RequirePackage{enumitem}
\RequirePackage{newunicodechar}
\RequirePackage{graphicx}
\RequirePackage{hyperref}

\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\hypersetup{hidelinks}

%%%%%%%%%%
% Colours %
%%%%%%%%%%
\definecolor{cvaccent}{HTML}{0B7A5C}
\definecolor{cvtext}{HTML}{232629}
\definecolor{cvmuted}{HTML}{5F6772}
\definecolor{cvborder}{HTML}{CDD0D4}
\definecolor{cvbar}{HTML}{F3F4F6}
\definecolor{cvred}{HTML}{FF5F56}
\definecolor{cvamber}{HTML}{FFBD2E}
\definecolor{cvgreen}{HTML}{27C93F}
\color{cvtext}

%%%%%%%%
% Fonts %
%%%%%%%%
\providecommand\cvfontdir{fonts/}
\setmainfont{NotoSans}[
  Path=\cvfontdir, Extension=.ttf,
  UprightFont=*-Regular, BoldFont=*-Bold,
  ItalicFont=*-Regular, BoldItalicFont=*-Bold] % the CV never uses italics
\setsansfont{NotoSans}[
  Path=\cvfontdir, Extension=.ttf,
  UprightFont=*-Regular, BoldFont=*-Bold,
  ItalicFont=*-Regular, BoldItalicFont=*-Bold] % the CV never uses italics
\newfontfamily\cvsemibold{NotoSans-SemiBold}[Path=\cvfontdir, Extension=.ttf]
\setmonofont{Hack}[
  Path=\cvfontdir, Extension=.ttf,
  UprightFont=*-Regular, BoldFont=*-Regular, % monospace is never bold
  ItalicFont=*-Regular, BoldItalicFont=*-Regular,
  Scale=MatchLowercase]
% Noto Sans has no arrows: take them from Hack
\newunicodechar{→}{{\ttfamily\symbol{8594}}}

%%%%%%%%%
% Layout %
%%%%%%%%%
\newlength{\cvsidewidth}
\setlength{\cvsidewidth}{0.29\textwidth}
\newlength{\cvgap}
\setlength{\cvgap}{10mm}

% Two top-aligned columns: \begin{cvsidebar}...\end{cvsidebar}\begin{cvmain}...\end{cvmain}
\newenvironment{cvsidebar}
  {\noindent\begin{minipage}[t]{\cvsidewidth}\vspace{0pt}}
  {\end{minipage}}
\newenvironment{cvmain}
  {\hfill\begin{minipage}[t]{\dimexpr\textwidth-\cvsidewidth-\cvgap\relax}\vspace{0pt}%
   \fontsize{10}{13.6}\selectfont\raggedright}
  {\end{minipage}}

%%%%%%%%%%%%%%%%%%%
% Terminal window %
%%%%%%%%%%%%%%%%%%%
\newcommand\cv@dot[1]{\tikz[baseline=-0.55ex]\fill[#1] (0,0) circle (2.1pt);}
\newcommand\cv@dots{\cv@dot{cvred}\hspace{2.5pt}\cv@dot{cvamber}\hspace{2.5pt}\cv@dot{cvgreen}}

\newif\ifcv@firstcmd
% Kept out of the tcolorbox keys: an `=' inside a key value breaks key parsing
\newcommand\cv@windowtext{%
  \ttfamily\fontsize{7.8}{10.6}\selectfont\raggedright
  \hyphenpenalty=10000 \exhyphenpenalty=10000 \cv@firstcmdtrue}
\newtcolorbox{cvwindow}[1]{
  enhanced, rounded corners, arc=2pt,
  colback=white, colframe=cvborder, boxrule=0.4pt,
  colbacktitle=cvbar, coltitle=cvmuted, titlerule=0.4pt,
  fonttitle=\ttfamily\fontsize{6.6}{8}\selectfont,
  title={\cv@dots\hspace{5pt}#1},
  toptitle=2pt, bottomtitle=2pt, lefttitle=5pt,
  left=6.5pt, right=6pt, top=8pt, bottom=8pt, boxsep=0pt,
  fontupper=\cv@windowtext,
}

% $ command
\newcommand\cvcmd[1]{%
  \par\ifcv@firstcmd\cv@firstcmdfalse\else\vspace{6.5pt}\fi
  {\color{cvaccent}\$}\nobreakspace#1\par}
% Command output line
\newcommand\cvout[1]{#1\par}
% Muted shell comment: # text
\newcommand\cvcomment[1]{{\color{cvmuted}\#\nobreakspace#1}}
% Name in large sans-serif, two lines, with a cursor
\newcommand\cvname[2]{%
  \par\vspace{2pt}%
  {\sffamily\bfseries\fontsize{24}{25}\selectfont#1\\#2}%
  {\color{cvaccent}\fontsize{24}{25}\selectfont\_}\par\vspace{3pt}}
% Links: never hyphenated or broken
\newcommand\cvlink[2]{\href{https://#1}{\mbox{#2}}}
\newcommand\cvmail[1]{\href{mailto:#1}{\mbox{#1}}}
% Final prompt with a block cursor
\newcommand\cvprompt{%
  \par\vspace{6.5pt}{\color{cvaccent}\$\nobreakspace█}\par}

%%%%%%%%%%%%%%%%
% Main column %
%%%%%%%%%%%%%%%%
\newcommand\cvsummary[1]{{\fontsize{10.6}{14.4}\selectfont#1\par}}

\newcommand\cvsection[1]{%
  \par\addvspace{20pt}%
  {\ttfamily\fontsize{13}{15}\selectfont{\color{cvaccent}\#}\nobreakspace#1}%
  \par\addvspace{5pt}}

% \cventry{Role — Company}{[dates]}{meta line}
\newcommand\cventry[3]{%
  \par\addvspace{12pt}%
  {\cvsemibold\fontsize{10.8}{13.6}\selectfont#1}%
  \hfill{\ttfamily\fontsize{8.8}{13.6}\selectfont\color{cvmuted}#2}\par
  {\fontsize{9.2}{12}\selectfont\color{cvmuted}#3\par}}

% Country flag after a location line, looked up as flags/<code>.png
\newcommand\cvflag[1]{\hspace{3pt}\raisebox{-0.28em}{\includegraphics[height=1.35em]{flags/#1.png}}}

\newlist{cvitems}{itemize}{1}
\setlist[cvitems]{
  label={\color{cvmuted}\textbullet}, leftmargin=9pt, labelsep=4pt,
  nosep, topsep=3.5pt, itemsep=1.6pt}

\newtcbox{\cvtag}{
  on line, colback=white, colframe=cvborder, boxrule=0.4pt, arc=1.5pt,
  left=2.2pt, right=2.2pt, top=0.6pt, bottom=0.6pt, boxsep=0pt,
  fontupper=\ttfamily\fontsize{7.6}{9}\selectfont\color{cvtext}}
% \cvtags{\cvtag{a} \cvtag{b} ...}: spaces between tags allow line breaks
\newcommand\cvtags[1]{\par\addvspace{5pt}{\lineskip=2.5pt #1\par}}
