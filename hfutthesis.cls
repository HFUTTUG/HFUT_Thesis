%
% Copyright (C) 2015-2021 by USTC TeX Users Group <https://github.com/ustctug>
%
% hfutthesis developed by HFUT TeX Users Group <https://github.com/HFUTTUG> on the 
% base of ustcthesis <https://github.com/usthtug/ustcthesis>.
%
% This file may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3c
% of this license or (at your option) any later version.
% The latest version of this license is in
%    https://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2008 or later.
%

\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\newcommand\hfutthesisversion{v1.0.4}
\ProvidesClass{hfutthesis}[2022/04/09 {\hfutthesisversion} hfut thesis template]

% 报错和警告
\newcommand\hfut@error[1]{%
  \ClassError{hfutthesis}{#1}{}%
}
\newcommand\hfut@warning[1]{%
  \ClassWarning{hfutthesis}{#1}%
}

% 检查 \LaTeXe{} kernel 版本
\@ifl@t@r\fmtversion{2017/04/15}{}{
  \hfut@error{%
    TeX Live 2017 or later version is required to compile this document%
  }
}

% 检查编译引擎，要求使用 XeLaTeX。
\RequirePackage{iftex}
\ifXeTeX\else
  \hfut@error{XeLaTeX is required to compile this document}
\fi


% \subsection{处理选项}

\RequirePackage{kvdefinekeys}
\RequirePackage{kvsetkeys}
\RequirePackage{kvoptions}

% 提供一个 \cs{hfutsetup} 命令支持 \emph{key-value} 的方式来设置。
\let\hfut@setup@hook\@empty
\newcommand\hfutsetup[1]{%
  \let\hfut@setup@hook\@empty
  \kvsetkeys{hfut}{#1}%
  \hfut@setup@hook
}

% 同时用 \emph{key-value} 的方式来定义这些接口：
% \begin{latex}
%   \hfut@define@key{
%     <key> = {
%       name = <name>,
%       choices = {
%         <choice1>,
%         <choice2>,
%       },
%       default = <default>,
%       code = <code>,
%     },
%   }
% \end{latex}

% 其中 |choices| 设置允许使用的值，默认为第一个（或者 \meta{default}）；
% \meta{code} 是相应的内容被设置时执行的代码。

\newcommand\hfut@define@key[1]{%
  \kvsetkeys{hfut@key}{#1}%
}
\kv@set@family@handler{hfut@key}{%
%
% \cs{hfutsetup} 会将 \meta{value} 存到 \cs{hfut@\meta{key}}，
% 但是宏的名字包含 “-” 这样的特殊字符时不方便直接调用，比如 |key = math-style|，
% 这时可以用 |name| 设置 \meta{key} 的别称，比如 |key = math@style|，
% 这样就可以通过 \cs{hfut@math@style} 来引用。
% |default| 是定义该 \meta{key} 时默认的值，缺省为空。
%
  \@namedef{hfut@#1@@name}{#1}%
  \def\hfut@@default{}%
  \def\hfut@@choices{}%
  \kv@define@key{hfut@value}{name}{%
    \@namedef{hfut@#1@@name}{##1}%
  }%
  %
  % 由于在定义接口时，\cs{hfut@\meta{key}@@code} 不一定有定义，
  % 而且在文档类/宏包中还有可能对该 |key| 的 |code| 进行添加。
  % 所以 \cs{hfut@\meta{key}@@code} 会检查如果在定义文档类/宏包时则推迟执行，否则立即执行。
  %
  \@namedef{hfut@#1@@check}{}%
  \@namedef{hfut@#1@@code}{}%
  %
  % 保存下 |choices = {}| 定义的内容，在定义 \cs{hfut@\meta{name}} 后再执行。
  %
  \kv@define@key{hfut@value}{choices}{%
    \def\hfut@@choices{##1}%
    \@namedef{hfut@#1@@reset}{}%
    %
    % \cs{hfut@\meta{key}@check} 检查 |value| 是否有效，
    % 并设置 \cs{ifhfut@\meta{name}@\meta{value}}。
    %
    \@namedef{hfut@#1@@check}{%
      \@ifundefined{%
        ifhfut@\@nameuse{hfut@#1@@name}@\@nameuse{hfut@\@nameuse{hfut@#1@@name}}%
      }{%
        \hfut@error{Invalid value "#1 = \@nameuse{hfut@\@nameuse{hfut@#1@@name}}"}%
      }%
      \@nameuse{hfut@#1@@reset}%
      \@nameuse{hfut@\@nameuse{hfut@#1@@name}@\@nameuse{hfut@\@nameuse{hfut@#1@@name}}true}%
    }%
  }%
  \kv@define@key{hfut@value}{default}{%
    \def\hfut@@default{##1}%
  }%
  \kvsetkeys{hfut@value}{#2}%
  \@namedef{hfut@\@nameuse{hfut@#1@@name}}{}%
  %
  % 第一个 \meta{choice} 设为 \meta{default}，
  % 并且对每个 \meta{choice} 定义 \cs{ifhfut@\meta{name}@\meta{choice}}。
  %
  \kv@set@family@handler{hfut@choice}{%
    \ifx\hfut@@default\@empty
      \def\hfut@@default{##1}%
    \fi
    \expandafter\newif\csname ifhfut@\@nameuse{hfut@#1@@name}@##1\endcsname
    \expandafter\g@addto@macro\csname hfut@#1@@reset\endcsname{%
      \@nameuse{hfut@\@nameuse{hfut@#1@@name}@##1false}%
    }%
  }%
  \kvsetkeys@expandafter{hfut@choice}{\hfut@@choices}%
  %
  % 将 \meta{default} 赋值到 \cs{hfut@\meta{name}}，如果非空则执行相应的代码。
  %
  \expandafter\let\csname hfut@\@nameuse{hfut@#1@@name}\endcsname\hfut@@default
  \expandafter\ifx\csname hfut@\@nameuse{hfut@#1@@name}\endcsname\@empty\else
    \@nameuse{hfut@#1@@check}%
  \fi
  %
  % 定义 \cs{hfutsetup} 接口。
  %
  \kv@define@key{hfut}{#1}{%
    \@namedef{hfut@\@nameuse{hfut@#1@@name}}{##1}%
    \@nameuse{hfut@#1@@check}%
    \@nameuse{hfut@#1@@code}%
  }%
}

% 定义接口向 |key| 添加 |code|：

\newcommand\hfut@option@hook[2]{%
  \expandafter\g@addto@macro\csname hfut@#1@@code\endcsname{#2}%
}

\hfut@define@key{
  degree = {
    choices = {
      doctor,
      master,
      bachelor,
    },
    default = bachelor,
  },
  degree-type = {
    name = degree@type,
    choices = {
      academic,
      professional,
    },
    default = academic,
  },
  main-language = {
    name = main@language,
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  language = {
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  system = {
    choices = {
      auto,
      mac,
      unix,
      windows,
    },
    default = auto,
  },
  fontset = {
    choices = {
      auto,
      windows,
      mac,
      ubuntu,
      fandol,
      none,
    },
    default = auto,
  },
  font = {
    choices = {
      auto,
      times,
      termes,
      stix,
      xits,
      libertinus,
      newcm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  cjk-font = {
    name = cjk@font,
    choices = {
      auto,
      windows,
      mac,
      noto,
      fandol,
      none,
    },
    default = auto,
  },
  math-font = {
    name = math@font,
    choices = {
      auto,
      stix,
      xits,
      libertinus,
      newcm,
      cm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  math-style = {
    name = math@style,
    choices = {
      GB,
      ISO,
      TeX,
    },
  },
  uppercase-greek = {
    name = uppercase@greek,
    choices = {
      italic,
      upright,
    },
  },
  less-than-or-equal = {
    name = leq,
    choices = {
      slanted,
      horizontal,
    },
  },
  integral = {
    choices = {
      upright,
      slanted,
    },
  },
  integral-limits = {
    name = integral@limits,
    choices = {
      true,
      false,
    },
  },
  partial = {
    choices = {
      upright,
      italic,
    },
  },
  math-ellipsis = {
    name = math@ellipsis,
    choices = {
      centered,
      lower,
      AMS,
    },
  },
  real-part = {
    name = real@part,
    choices = {
      roman,
      fraktur,
    },
  },
  cite-style = {
    name = cite@style,
    choices = {
      super,
      inline,
      authoryear,
    },
    default = super,
  },
  output = {
    choices = {
      print,
      electronic,
    },
    default = print,
  },
  section-style = {
    name = section@style,
    choices = {
      chinese,
      arabic,
    },
    default = chinese,
  },
  badge-color = {
    name = badge@color,
    choices = {
      red,
      black,
    },
    default = red,
  },
}

\newif\ifhfut@degree@graduate
\newcommand\hfut@set@graduate{%
  \ifhfut@degree@bachelor
    \hfut@degree@graduatefalse
  \else
    \hfut@degree@graduatetrue
  \fi
}
\hfut@set@graduate
\hfut@option@hook{degree}{%
  \hfut@set@graduate
}

% 使用 \pkg{kvoptions} 提供的 key-value 接口，
\SetupKeyvalOptions{
  family  = hfut,
  prefix  = hfut@,
  setkeys = \kvsetkeys,
}

% 设置默认 \option{openany}。
\DeclareBoolOption[false]{openright}
\DeclareComplementaryOption{openany}{openright}

% 兼容旧版本的文档类选项。
% Reserved for compatibility until 2020-07-01.
\DeclareVoidOption{doctor}{\hfutsetup{degree=doctor}}
\DeclareVoidOption{master}{\hfutsetup{degree=master}}
\DeclareVoidOption{bachelor}{\hfutsetup{degree=bachelor}}
\DeclareVoidOption{chinese}{\hfutsetup{language=chinese}}
\DeclareVoidOption{english}{\hfutsetup{language=english}}
\DeclareVoidOption{academic}{\hfutsetup{degree-type=academic}}
\DeclareVoidOption{professional}{\hfutsetup{degree-type=professional}}
\DeclareVoidOption{print}{\hfutsetup{output=print}}
\DeclareVoidOption{pdf}{\hfutsetup{output=electronic}}
\newif\ifhfut@legacy@cite@style
\DeclareVoidOption{super}{\hfutsetup{cite-style=super}\hfut@legacy@cite@styletrue}
\DeclareVoidOption{numbers}{\hfutsetup{cite-style=inline}\hfut@legacy@cite@styletrue}
\DeclareVoidOption{authoryear}{\hfutsetup{cite-style=authoryear}\hfut@legacy@cite@styletrue}
\DeclareVoidOption{arabic}{\hfutsetup{section-style=arabic}}
\DeclareVoidOption{colorlogo}{\hfutsetup{badge-color=red}}
\DeclareVoidOption{bwlogo}{\hfutsetup{badge-color=black}}

% 载入 \cls{ctexbook}。
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessKeyvalOptions*


% \subsection{加载文档类和宏包}

\ifhfut@openright
  \PassOptionsToClass{openright}{book}
\else
  \PassOptionsToClass{openany}{book}
\fi

\ifhfut@output@electronic
  \PassOptionsToClass{oneside}{book}
\fi
\PassOptionsToPackage{no-math}{fontspec}

% 载入 \cls{ctexbook} 文档类，注意要求为 2.4.9 或更高的版本。
\LoadClass[UTF8,a4paper,scheme=plain,zihao=-4,fontset=none]{ctexbook}[2017/04/01]

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
% \pkg{hyperref} 一般在最后加载。
\RequirePackage{etoolbox}
\RequirePackage{amsmath}
\RequirePackage{fontspec}[2017/03/31]
\RequirePackage[driver=xetex]{geometry}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{color}
\RequirePackage{titletoc}
\RequirePackage{caption}
\RequirePackage[perpage]{footmisc}
\RequirePackage{url}
\RequirePackage{calc}
\RequirePackage[normalem]{ulem} % 提供排版可断行下划线的命令\uline
\RequirePackage{multirow} % 纵向合并单元格
\RequirePackage{enumitem} % enumberate
\RequirePackage[list=off]{bicaption} % 图表中英文标题

% 如果用户在导言区未调用 \pkg{biblatex}，则自动调用 \pkg{natbib}。
\AtEndPreamble{
  \@ifpackageloaded{biblatex}{}{
    \RequirePackage{natbib}
  }
}

% 对冲突的宏包报错。
\RequirePackage{filehook}
\newcommand\hfut@package@conflict[2]{
  \AtEndOfPackageFile*{#1}{%
    \AtBeginOfPackageFile*{#2}{%
      \hfut@error{The "#2" package is incompatible with "#1"}%
    }%
  }%
}

\hfut@package@conflict{biblatex}{bibunits}
\hfut@package@conflict{biblatex}{chapterbib}
\hfut@package@conflict{biblatex}{cite}
\hfut@package@conflict{biblatex}{multibib}
\hfut@package@conflict{biblatex}{natbib}

\hfut@package@conflict{bibunits}{biblatex}
\hfut@package@conflict{bibunits}{chapterbib}
\hfut@package@conflict{bibunits}{multibib}

\hfut@package@conflict{unicode-math}{amscd}
\hfut@package@conflict{unicode-math}{amsfonts}
\hfut@package@conflict{unicode-math}{amssymb}
\hfut@package@conflict{unicode-math}{bbm}
\hfut@package@conflict{unicode-math}{bm}
\hfut@package@conflict{unicode-math}{eucal}
\hfut@package@conflict{unicode-math}{eufrak}
\hfut@package@conflict{unicode-math}{mathrsfs}
\hfut@package@conflict{unicode-math}{newtxmath}
\hfut@package@conflict{unicode-math}{upgreek}

\hfut@package@conflict{natbib}{biblatex}
\hfut@package@conflict{natbib}{cite}

\hfut@package@conflict{newtxmath}{amsfonts}
\hfut@package@conflict{newtxmath}{amssymb}
\hfut@package@conflict{newtxmath}{unicode-math}
\hfut@package@conflict{newtxmath}{upgreek}


% \pkg{mathtools} 需要在 \pkg{unicode-math} 前载入，
% 参考 \url{https://tex.stackexchange.com/q/521394/82731}。
\AtBeginOfPackageFile*{mathtools}{
  \@ifpackageloaded{unicode-math}{
    \hfut@error{The "mathtools" package should be loaded before setting "math-font"}
  }{}
}%

% \pkg{amsthm} 需要在 \pkg{newtx} 前载入，参考 \pkg{newtx} 的文档。
\AtBeginOfPackageFile*{amsthm}{
  \@ifpackageloaded{newtxmath}{
    \hfut@error{The "amsthm" package should be loaded before setting "newtxmath"}
  }{}
}%



% \subsection{处理语言}

% 定义 \cs{hfut@main@language}，当在导言区修改 \option{language} 时，
% 保存为论文的主要语言；
% \cs{hfut@reset@main@language} 则用于正文中恢复为主要语言。
%    \begin{macrocode}
\hfutsetup{main-language=\hfut@language}%
\let\hfut@main@language\hfut@language

\hfut@option@hook{language}{%
  \ifx\@begindocumenthook\@undefined\else
    \hfutsetup{main-language=\hfut@language}%
    \let\hfut@main@language\hfut@language
  \fi
}
\newcommand\hfut@reset@main@language{%
  \hfutsetup{language = \hfut@main@language}%
  \let\hfut@language\hfut@main@language
}

% 带圈数字和星号使用中文字体。
\xeCJKDeclareCharClass{CJK}{"2460 -> "2473}
\xeCJKDeclareCharClass{CJK}{"2605}

% 由于 Unicode 的一些标点符号是中西文混用的：
% U+00B7、U+2013、U+2014、U+2018、U+2019、
% U+201C、U+201D、U+2025、U+2026、U+2E3A，
% 所以要根据语言设置正确的字体。
% https://github.com/CTeX-org/ctex-kit/issues/389
\newcommand\hfut@set@punctuations{%
  \ifhfut@language@chinese
    \xeCJKDeclareCharClass{FullLeft}{"2018, "201C}%
    \xeCJKDeclareCharClass{FullRight}{
      "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
    }%
  \else
    \xeCJKDeclareCharClass{HalfLeft}{"2018, "201C}%
    \xeCJKDeclareCharClass{HalfRight}{
      "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
    }%
  \fi
}
\hfut@set@punctuations
\hfut@option@hook{language}{\hfut@set@punctuations}

% 根据语言设置各章节的名称，只有在导言区设置 \option{language} 时会修改，
% 而在正文局部切换语言时则不变。

% 由于《撰写手册》中的“speciality”一词使用的是英式拼法，
% 所以“acknowledgements”也保持一致。
\newcommand\hfut@set@chapter@names{%
  \ifhfut@main@language@chinese
    \def\contentsname{目\hspace{\ccwd}录}%
    \def\listfigurename{插图清单}%
    \def\listtablename{表格清单}%
    \ctexset{
      chapter/name   = {第,章},
    }%
    \def\bibname{参考文献}%
    \def\appendixname{附录}%
    \ifhfut@degree@bachelor
      \def\hfut@acknowledgements@name{致谢}%
    \else
      \def\hfut@acknowledgements@name{致\hspace{\ccwd}谢}%
    \fi
    \ifhfut@degree@bachelor
      \def\hfut@publication@name{攻读学士学位期间的学术活动及成果情况}%
    \else
      \ifhfut@degree@master
        \def\hfut@publication@name{攻读硕士学位期间的学术活动及成果情况}%
      \else
        \def\hfut@publication@name{攻读博士学位期间的学术活动及成果情况}%
      \fi
    \fi
    \newcommand\hfut@notation@name{符号说明}%
  \else
    \def\contentsname{Contents}%
    \def\listfigurename{List of Figures}%
    \def\listtablename{List of Tables}%
    \ctexset{
      chapter/name   = {\chaptername\space},
    }%
    \def\bibname{Bibliography}%
    \def\appendixname{Appendix}%
    \def\hfut@acknowledgements@name{Acknowledgements}%
    \def\hfut@publication@name{Publications}%
    \def\hfut@notation@name{Notation}%
  \fi
}
\hfut@set@chapter@names
\hfut@option@hook{main-language}{\hfut@set@chapter@names}

% 这部分名称在正文中局部地修改语言时会发生变化。
\newcommand\hfut@set@names{%
  \ifhfut@language@chinese
    \def\figurename{图}%
    \def\tablename{表}%
  \else
    \def\figurename{Fig}%
    \def\tablename{Tab}%
  \fi
}
\hfut@set@names
\hfut@option@hook{language}{\hfut@set@names}


% \subsection{字体}

% 字号

% 正文字号12bp，研究生行距20bp，本科生行距22bp；
% 其他命令的行距按照相同的的比例设置，如表~\ref{tab:fontsize}。
% \begin{table}[htb]
%   \centering
%   \caption{标准字体命令与字号、行距的对应}
%   \label{tab:fontsize}
%   \begin{tabular}{lllll}
%     \toprule
%     字体命令          & 字号 & bp   & 研究生行距 & 本科生行距 \\
%     \midrule
%     \cs{tiny}         & 小六 & 6.5  & 10.83      & 11.92      \\
%     \cs{scriptsize}   & 六号 & 7.5  & 12.5       & 13.75      \\
%     \cs{footnotesize} & 小五 & 9    & 15         & 16.5       \\
%     \cs{small}        & 五号 & 10.5 & 17.5       & 19.25      \\
%     \cs{normalsize}   & 小四 & 12   & 20         & 22         \\
%     \cs{large}        & 小三 & 15   & 25         & 27.5       \\
%     \cs{Large}        & 小二 & 18   & 30         & 33         \\
%     \cs{LARGE}        & 二号 & 22   & 36.67      & 40.33      \\
%     \cs{huge}         & 小一 & 24   & 40         & 44         \\
%     \cs{Huge}         & 一号 & 26   & 43.33      & 47.67      \\
%     \bottomrule
%   \end{tabular}
% \end{table}
%
% 注意重定义 \normalsize 应在 \pkg{unicode-math} 的 \cs{setmathfont} 前。
\newcommand\hfut@set@font@size{%
  \ifhfut@degree@graduate
    \renewcommand\normalsize{%
      \@setfontsize\normalsize{12bp}{20bp}%
      \abovedisplayskip 12bp \@plus3bp \@minus7bp%
      \abovedisplayshortskip \z@ \@plus3bp%
      \belowdisplayshortskip 6.5bp \@plus3.5bp \@minus3bp%
      \belowdisplayskip \abovedisplayskip
      \let\@listi\@listI}%
    %
    % 注意第~\ref{sec:list} 节去掉了列表的间距，所以不再修改 \cs{@listi}。
  \else
    \renewcommand\normalsize{%
      \@setfontsize\normalsize{12bp}{22bp}%
      \abovedisplayskip 12bp \@plus3bp \@minus7bp%
      \abovedisplayshortskip \z@ \@plus3bp%
      \belowdisplayshortskip 6.5bp \@plus3.5bp \@minus3bp%
      \belowdisplayskip \abovedisplayskip
      \let\@listi\@listI}%
  \fi
  \normalsize
  \ifx\MakeRobust\@undefined \else
      \MakeRobust\normalsize
  \fi
}
\hfut@set@font@size
\hfut@option@hook{degree}{\hfut@set@font@size}

% 设置行距的倍数为 1。
\linespread{1}\selectfont


% 检测系统
\ifhfut@system@auto
  \IfFileExists{/System/Library/Fonts/Menlo.ttc}{
    \hfutsetup{system = mac}
  }{
    \IfFileExists{/dev/null}{
      \IfFileExists{null:}{
        \hfutsetup{system = windows}
      }{
        \hfutsetup{system = unix}
      }
    }{
      \hfutsetup{system = windows}
    }
  }
\fi

% 处理 \opt{fontset}
\ifhfut@fontset@auto
  \ifhfut@system@windows
    \hfutsetup{fontset = windows}
  \else
    \ifhfut@system@mac
      \hfutsetup{fontset = mac}
    \else
      \IfFontExistsTF{Noto Serif CJK SC}{
        \hfutsetup{fontset = ubuntu}
      }{
        \hfutsetup{fontset = fandol}
      }
    \fi
  \fi
\fi

% 《撰写手册》要求西文字体使用 Times New Roman 和 Arial，
% 但是在 Linux 下没有这两个字体，所以使用它们的克隆版 TeX Gyre Termes 和
% TeX Gyre Heros。
\ifhfut@font@auto
  \ifhfut@fontset@windows
    \hfutsetup{font=times}
  \else
    \ifhfut@fontset@mac
      \hfutsetup{font=times}
    \else
      \hfutsetup{font=termes}
    \fi
  \fi
\fi

% Times New Roman + Arial
\newcommand\hfut@set@font@times{%
  \setmainfont{Times New Roman}%
  \setsansfont{Arial}%
  \ifhfut@system@mac
    \setmonofont{Menlo}[Scale = MatchLowercase]%
  \else
    \setmonofont{Courier New}[Scale = MatchLowercase]%
  \fi
}

% TeX Gyre Termes
\newcommand\hfut@set@font@termes{%
  \setmainfont{texgyretermes}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \hfut@set@texgyre@sans@mono
}

\newcommand\hfut@set@texgyre@sans@mono{%
  \setsansfont{texgyreheros}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmonofont{texgyrecursor}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
    Ligatures      = CommonOff,
  ]%
}

% STIX Two 字体。
% STIX 文件名在 v2.10 2020-12-19 从
% \file{STIX2Text-Regular.otf}、\file{STIX2Math.otf} 分别改为
% \file{STIXTwoText-Regular.otf}、\file{STIXTwoMath-Regular.otf}。
\let\hfut@font@family@stix\@empty
\newcommand\hfut@set@stix@names{%
  \ifx\hfut@font@family@stix\@empty
    \IfFontExistsTF{STIXTwoText-Regular.otf}{%
      \gdef\hfut@font@family@stix{STIXTwoText}%
      \gdef\hfut@font@name@stix@math{STIXTwoMath-Regular}%
    }{%
      \gdef\hfut@font@family@stix{STIX2Text}%
      \gdef\hfut@font@name@stix@math{STIX2Math}%
    }%
  \fi
}

\newcommand\hfut@set@font@stix{%
  \hfut@set@stix@names
  \setmainfont{\hfut@font@family@stix}[
    Extension      = .otf,
    UprightFont    = *-Regular,
    BoldFont       = *-Bold,
    ItalicFont     = *-Italic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \hfut@set@texgyre@sans@mono
}

% XITS 字体。
% XITS 的文件名在 v1.109 2018-09-30
% 从 \file{xits-regular.otf}、\file{xits-math.otf} 分别改为
% \file{XITS-Regular.otf}、\file{XITSMath-Regular.otf}。
\let\hfut@font@family@xits\@empty
\newcommand\hfut@set@xits@names{%
  \ifx\hfut@font@family@xits\@empty
    \IfFontExistsTF{XITSMath-Regular.otf}{%
      \gdef\hfut@font@family@xits{XITS}%
      \gdef\hfut@font@style@xits@rm{Regular}%
      \gdef\hfut@font@style@xits@bf{Bold}%
      \gdef\hfut@font@style@xits@it{Italic}%
      \gdef\hfut@font@style@xits@bfit{BoldItalic}%
      \gdef\hfut@font@name@xits@math{XITSMath-Regular}%
    }{%
      \gdef\hfut@font@family@xits{xits}%
      \gdef\hfut@font@style@xits@rm{regular}%
      \gdef\hfut@font@style@xits@bf{bold}%
      \gdef\hfut@font@style@xits@it{italic}%
      \gdef\hfut@font@style@xits@bfit{bolditalic}%
      \gdef\hfut@font@name@xits@math{xits-math}%
    }%
  \fi
}

\newcommand\hfut@set@font@xits{%
  \hfut@set@xits@names
  \setmainfont{\hfut@font@family@xits}[
    Extension      = .otf,
    UprightFont    = *-\hfut@font@style@xits@rm,
    BoldFont       = *-\hfut@font@style@xits@bf,
    ItalicFont     = *-\hfut@font@style@xits@it,
    BoldItalicFont = *-\hfut@font@style@xits@bfit,
  ]%
  \hfut@set@texgyre@sans@mono
}

% Libertinus 的文件名在 v6.7 2019-04-03 从小写改为驼峰式，
% 在大小写敏感的平台上需要进行判断。
\let\hfut@font@family@libertinus\@empty
\newcommand\hfut@set@libertinus@names{%
  \ifx\hfut@font@family@libertinus\@empty
    \IfFontExistsTF{LibertinusSerif-Regular.otf}{%
      \gdef\hfut@font@family@libertinus@serif{LibertinusSerif}%
      \gdef\hfut@font@family@libertinus@sans{LibertinusSans}%
      \gdef\hfut@font@name@libertinus@math{LibertinusMath-Regular}%
      \gdef\hfut@font@style@libertinus@rm{Regular}%
      \gdef\hfut@font@style@libertinus@bf{Bold}%
      \gdef\hfut@font@style@libertinus@it{Italic}%
      \gdef\hfut@font@style@libertinus@bfit{BoldItalic}%
    }{%
      \gdef\hfut@font@family@libertinus@serif{libertinusserif}%
      \gdef\hfut@font@family@libertinus@sans{libertinussans}%
      \gdef\hfut@font@name@libertinus@math{libertinusmath-regular}%
      \gdef\hfut@font@style@libertinus@rm{regular}%
      \gdef\hfut@font@style@libertinus@bf{bold}%
      \gdef\hfut@font@style@libertinus@it{italic}%
      \gdef\hfut@font@style@libertinus@bfit{bolditalic}%
    }%
  \fi
}

\newcommand\hfut@set@font@libertinus{%
  \hfut@set@libertinus@names
  \setmainfont{\hfut@font@family@libertinus@serif}[
    Extension      = .otf,
    UprightFont    = *-\hfut@font@style@libertinus@rm,
    BoldFont       = *-\hfut@font@style@libertinus@bf,
    ItalicFont     = *-\hfut@font@style@libertinus@it,
    BoldItalicFont = *-\hfut@font@style@libertinus@bfit,
  ]%
  \setsansfont{\hfut@font@family@libertinus@sans}[
    Extension      = .otf,
    UprightFont    = *-\hfut@font@style@libertinus@rm,
    BoldFont       = *-\hfut@font@style@libertinus@bf,
    ItalicFont     = *-\hfut@font@style@libertinus@it,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% New Computer Modern
\newcommand\hfut@set@font@newcm{%
  \setmainfont{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setsansfont{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmonofont{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern
\newcommand\hfut@set@font@lm{%
  \setmainfont{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setsansfont{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

\newcommand\hfut@set@font@newtx{%
  \RequirePackage{newtxtext}%
}

\newcommand\hfut@set@font{%
  \@nameuse{hfut@set@font@\hfut@font}%
}
\hfut@set@font
\hfut@option@hook{font}{\hfut@set@font}

% 中文字体
\ifhfut@cjk@font@auto
  \ifhfut@fontset@mac
    \hfutsetup{cjk-font = mac}
  \else
    \ifhfut@fontset@windows
      \hfutsetup{cjk-font = windows}
    \else
      \ifhfut@fontset@ubuntu
        \hfutsetup{cjk-font = noto}
      \else
        \hfutsetup{cjk-font = fandol}
      \fi
    \fi
  \fi
\fi

% Windows 的中易字体。
\newcommand\hfut@set@cjk@font@windows{%
  \xeCJKsetup{EmboldenFactor=2}
  \setCJKmainfont{SimSun}[
    AutoFakeBold = true,
    ItalicFont   = KaiTi,
  ]%
  \setCJKsansfont{SimHei}[AutoFakeBold]%
  \setCJKmonofont{FangSong}%
  \setCJKfamilyfont{zhsong}{SimSun}[AutoFakeBold]%
  \setCJKfamilyfont{zhhei}{SimHei}[AutoFakeBold]%
  \setCJKfamilyfont{zhkai}{KaiTi}%
  \setCJKfamilyfont{zhfs}{FangSong}%
}

% macOS 的华文字体。
\newcommand\hfut@set@cjk@font@mac{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = Kaiti SC Regular,
    BoldItalicFont = Kaiti SC Bold,
  ]%
  \setCJKsansfont{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKmonofont{STFangsong}
  \setCJKfamilyfont{zhsong}{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{STFangsong}%
  \setCJKfamilyfont{zhkai}{Kaiti SC}[
    UprightFont    = * Regular,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhli}{Baoli SC}%
  \setCJKfamilyfont{zhyuan}{Yuanyi SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
}

% 思源字体。
% 注意 Noto CJK 的 regular 字重名字不带“Regular”。
\newcommand\hfut@set@cjk@font@noto{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Noto Serif CJK SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
    Script         = CJK,
  ]%
  \setCJKsansfont{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKmonofont{Noto Sans Mono CJK SC}[
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhsong}{Noto Serif CJK SC}[
    UprightFont    = * Light,
    UprightFont    = * Bold,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhhei}{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
}

% Fandol 字体。
\newcommand\hfut@set@cjk@font@fandol{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
    ItalicFont  = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
  ]%
  \setCJKsansfont{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKmonofont{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhsong}{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhhei}{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}

\ifhfut@cjk@font@none\else
  \providecommand\songti{\CJKfamily{zhsong}}
  \providecommand\heiti{\CJKfamily{zhhei}}
  \providecommand\fangsong{\CJKfamily{zhfs}}
  \providecommand\kaishu{\CJKfamily{zhkai}}
\fi

\newcommand\hfut@set@cjk@font{%
  \@nameuse{hfut@set@cjk@font@\hfut@cjk@font}%
}
\hfut@set@cjk@font
\hfut@option@hook{cjk-font}{\hfut@set@cjk@font}

% 数学字体

% 设置数学符号风格。
\newcommand\hfut@set@math@style{%
  \ifhfut@math@style@TeX
    \hfutsetup{
      uppercase-greek    = upright,
      less-than-or-equal = horizontal,
      integral           = slanted,
      integral-limits    = false,
      partial            = italic,
      math-ellipsis      = AMS,
      real-part          = fraktur,
    }%
  \else
    \hfutsetup{
      uppercase-greek = italic,
      integral        = upright,
      integral-limits = true,
      partial         = upright,
      real-part       = roman,
    }%
    \ifhfut@math@style@ISO
      \hfutsetup{
        less-than-or-equal = horizontal,
        math-ellipsis      = lower,
      }%
    \else
      \ifhfut@math@style@GB
        \hfutsetup{
          less-than-or-equal = slanted,
          math-ellipsis      = centered,
        }%
      \fi
    \fi
  \fi
}

\ifhfut@main@language@chinese
  \hfutsetup{math-style = GB}%
\else
  \hfutsetup{math-style = TeX}%
\fi

\hfut@set@math@style
\hfut@option@hook{math-style}{\hfut@set@math@style}
\hfut@option@hook{main-language}{%
  \ifhfut@main@language@chinese
    \hfutsetup{math-style = GB}%
  \else
    \hfutsetup{math-style = TeX}%
  \fi
}

% 针对 \pkg{unicode-math} 逐项配置数学符号。

\newcommand\hfut@set@unimath@leq{%
  \ifhfut@leq@horizontal
    \ifx\@begindocumenthook\@undefined
      \let\le\hfut@save@leq
      \let\ge\hfut@save@geq
      \let\leq\hfut@save@leq
      \let\geq\hfut@save@geq
    \else
      \AtBeginDocument{%
        \let\le\hfut@save@leq
        \let\ge\hfut@save@geq
        \let\leq\hfut@save@leq
        \let\geq\hfut@save@geq
      }%
    \fi
  \else
    \ifhfut@leq@slanted
      \ifx\@begindocumenthook\@undefined
        \let\le\leqslant
        \let\ge\geqslant
        \let\leq\leqslant
        \let\geq\geqslant
      \else
        \AtBeginDocument{%
          \let\le\leqslant
          \let\ge\geqslant
          \let\leq\leqslant
          \let\geq\geqslant
        }%
      \fi
    \fi
  \fi
}
\newcommand\hfut@set@unimath@integral@limits{%
  \ifhfut@integral@limits@true
    \removenolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \else
    \addnolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \fi
}
\newcommand\hfut@set@unimath@ellipsis{%
  \ifhfut@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodecdots}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodeellipsis}}%
  \fi
}
\newcommand\hfut@set@unimath@real@part{%
  \ifhfut@real@part@roman
    \AtBeginDocument{%
      \def\Re{\operatorname{Re}}%
      \def\Im{\operatorname{Im}}%
    }%
  \else
    \AtBeginDocument{%
      \let\Re\hfut@save@Re
      \let\Im\hfut@save@Im
    }%
  \fi
}

\newcommand\hfut@set@unimath@style{%
  \ifhfut@uppercase@greek@upright
    \unimathsetup{math-style = TeX}%
  \else
    \ifhfut@uppercase@greek@italic
      \unimathsetup{math-style = ISO}%
    \fi
  \fi
  \ifhfut@math@style@TeX
    \unimathsetup{bold-style = TeX}%
  \else
    \unimathsetup{bold-style = ISO}%
  \fi
  \hfut@set@unimath@leq
  \hfut@set@unimath@integral@limits
  \ifhfut@partial@upright
    \unimathsetup{partial = upright}%
  \else
    \ifhfut@partial@italic
      \unimathsetup{partial = italic}%
    \fi
  \fi
  \hfut@set@unimath@ellipsis
  \hfut@set@unimath@real@part
}

\newcommand\hfut@qed{\rule{1ex}{1ex}}
\newcommand\hfut@load@unimath{%
  \@ifpackageloaded{unicode-math}{}{%
    \RequirePackage{unicode-math}%
    \AtBeginDocument{%
      \let\hfut@save@leq\leq
      \let\hfut@save@geq\geq
      \let\hfut@save@Re\Re
      \let\hfut@save@Im\Im
    }%
    %
    % 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
    \DeclareRobustCommand\bm[1]{{\symbfit{##1}}}%
    \DeclareRobustCommand\boldsymbol[1]{{\symbfit{##1}}}%
    %
    % 兼容 \pkg{amsfonts} 和 \pkg{amssymb} 中的一些命令。
    \newcommand\square{\mdlgwhtsquare}%
    \newcommand\blacksquare{\mdlgblksquare}%
    \AtBeginDocument{%
      \renewcommand\checkmark{\ensuremath{✓}}%
    }%
    %
    % 兼容 \pkg{amsthm} 的 \cs{qedsymbol}。
    \renewcommand\hfut@qed{\ensuremath{\QED}}%
  }%
}

% STIX Two Math
\newcommand\hfut@set@math@font@stix{%
  \hfut@load@unimath
  \hfut@set@unimath@style
  \hfut@set@stix@names
  \setmathfont{\hfut@font@name@stix@math}[
    Extension    = .otf,
    StylisticSet = \hfut@xits@integral@stylistic@set,
  ]%
  \setmathfont{\hfut@font@name@stix@math}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
}

% XITS Math
\newcommand\hfut@xits@integral@stylistic@set{%
  \ifhfut@integral@upright
    8%
  \fi
}
\newcommand\hfut@set@math@font@xits{%
  \hfut@load@unimath
  \hfut@set@unimath@style
  \hfut@set@xits@names
  \setmathfont{\hfut@font@name@xits@math}[
    Extension    = .otf,
    StylisticSet = \hfut@xits@integral@stylistic@set,
  ]%
  \setmathfont{\hfut@font@name@xits@math}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {cal,bfcal},
  ]%
}

% Libertinus Math
\newcommand\hfut@libertinus@integral@stylistic@set{%
  \ifhfut@integral@slanted
    8%
  \fi
}
\newcommand\hfut@set@math@font@libertinus{%
  \hfut@load@unimath
  \hfut@set@unimath@style
  \hfut@set@libertinus@names
  \hfut@set@xits@names
  \setmathfont{\hfut@font@name@libertinus@math}[
    Extension    = .otf,
    StylisticSet = \hfut@libertinus@integral@stylistic@set,
  ]%
  \setmathfont{\hfut@font@name@xits@math}[
    Extension    = .otf,
    range        = {\checkmark},
  ]%
}

% New Computer Modern Math
\newcommand\hfut@newcm@integral@stylistic@set{%
  \ifhfut@integral@upright
    2%
  \fi
}
\newcommand\hfut@set@math@font@newcm{%
  \hfut@load@unimath
  \hfut@set@unimath@style
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = \hfut@newcm@integral@stylistic@set,
  ]%
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
  \setmathrm{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setmathsf{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmathtt{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern Math
\newcommand\hfut@set@math@font@lm{%
  \hfut@load@unimath
  \hfut@set@unimath@style
  \setmathfont{latinmodern-math}[Extension=.otf]%
  \setmathrm{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmathsf{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmathtt{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% NewTX Math
% 注意 NewTX Math 是 Type 1 字体，如果正文西文使用了 OpenType 字体时需要小心处理。
\newcommand\hfut@set@math@font@newtx{%
  \ifhfut@font@newtx\else
    \let\hfut@save@encodingdefault\encodingdefault
    \let\hfut@save@rmdefault\rmdefault
    \let\hfut@save@sfdefault\sfdefault
    \let\hfut@save@ttdefault\ttdefault
    \RequirePackage[T1]{fontenc}%
    \renewcommand{\rmdefault}{ntxtlf}%
    \renewcommand{\sfdefault}{qhv}%
    \renewcommand{\ttdefault}{ntxtt}%
  \fi
  \ifhfut@uppercase@greek@italic
    \PassOptionsToPackage{slantedGreek}{newtxmath}%
  \fi
  \ifhfut@integral@upright
    \PassOptionsToPackage{upint}{newtxmath}%
  \fi
  \RequirePackage{newtxmath}
  \let\hfut@save@leq\leq
  \let\hfut@save@geq\geq
  \ifhfut@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifhfut@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \let\hfut@save@partial\partial
  \ifhfut@partial@upright
    \let\partial\uppartial
  \fi
  \ifhfut@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\hfut@save@Re\Re
  \let\hfut@save@Im\Im
  \ifhfut@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \ifhfut@font@newtx\else
    \let\encodingdefault\hfut@save@encodingdefault
    \let\rmdefault\hfut@save@rmdefault
    \let\sfdefault\hfut@save@sfdefault
    \let\ttdefault\hfut@save@ttdefault
  \fi
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\upDelta%
  \renewcommand\hfut@qed{\openbox}%
}

% Computer Modern
% 使用 LaTeX 默认的 cm 字体
\newcommand\hfut@set@math@font@cm{%
  \RequirePackage{amssymb}
  \let\hfut@save@leq\leq
  \let\hfut@save@geq\geq
  \ifhfut@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifhfut@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \ifhfut@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\hfut@save@Re\Re
  \let\hfut@save@Im\Im
  \ifhfut@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\hfut@qed{\openbox}%
  \let\uppi\pi
}

% 不设置数学字体，仅提供兼容支持。
\newcommand\hfut@set@math@font@none{%
  \RequirePackage{amssymb}
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\hfut@qed{\openbox}%
  \let\uppi\pi
}

\newcommand\hfut@set@math@font{%
  \@nameuse{hfut@set@math@font@\hfut@math@font}%
}
\hfut@option@hook{math-font}{\g@addto@macro\hfut@setup@hook{\hfut@set@math@font}}
\newcommand\hfut@set@math@font@auto{%
  \ifhfut@math@font@auto
    \hfutsetup{math-font=xits}%
  \fi
}
\AtBeginOfPackageFile*{siunitx}{\hfut@set@math@font@auto}
\AtEndPreamble{%
  \hfut@set@math@font@auto
  \ifx\square\@undefined
    \RequirePackage{amssymb}%
  \fi
}



% \subsection{纸张和页面}
% 使用 \pkg{geometry} 宏包设置纸张和页面。

% 纸张：A4；

% 页面设置：上、下 2.54 cm，左、右 3 cm，页眉 1.5 cm，页脚 1.5 cm。

% 注意这里指的是页眉顶部到纸张顶部的距离为 1.5 cm，
% 所以应该是 2.54cm - 0.75cm - 0.29cm = 1.5cm
% 页脚 同理 2.54cm - 1.04cm = 1.5cm

\geometry{
  paper      = a4paper,
  vmargin    = 2.54cm,
  hmargin    = 3cm,
  headheight = 0.75cm,
  headsep    = 0.29cm,
  footskip   = 1.04cm,
}

% 使用 \pkg{fancy} 需要先调用 |\pagestyle{fancy}| 再修改 \cs{chaptermark} 和
% \cs{sectionmark}。
\pagestyle{fancy}
\let\sectionmark\@gobble
\renewcommand\headrulewidth{0.4\p@}
% 重定义默认的 |myheadings| page style，会显示页眉和页脚。
\fancypagestyle{myheadings}{%
  \fancyhf{}%
  %
  % 页眉与该部分的章标题相同，宋体 10.5 磅（五号）居中、1.5倍行距。
  % 页码：宋体 10.5 磅、页面下脚居中。
  % 页眉上下页边距1.5 cm
  \def\hfut@hf@font{\fontsize{10.5bp}{20.475bp}\selectfont}
  \renewcommand\headrulewidth{0.4\p@}
  \ifhfut@degree@graduate
    
    \fancyhead[OC]{\hfut@hf@font\leftmark}%
    \ifhfut@degree@doctor
      \fancyhead[EC]{\hfut@hf@font 合肥工业大学博士研究生学位论文}%
    \else
      \fancyhead[EC]{\hfut@hf@font 合肥工业大学\hfut@degreetype@name 研究生学位论文}%
    \fi
    \fancyfoot[C]{\hfut@hf@font\thepage}%
    \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markboth{\CTEXifname{\CTEXthechapter\quad}{}\hfut@spacetitle{##1}}{}%
    }%
    \let\sectionmark\@gobble
  \else
    %
    % 本科生要求在正文每面上部加页眉，
    % 用五号字（10.5 bp）标注“合肥工业大学毕业设计（论文）”，居中；
    % 从正文页开始在每面底部居中用小五宋体（10.5 bp）连续编页码。
    \fancyhead[C]{\hfut@hf@font 合肥工业大学毕业设计（论文）}%
    \fancyfoot[C]{\hfut@hf@font\thepage}%
    \let\@mkboth\@gobbletwo
    \let\chaptermark\@gobble
    \let\sectionmark\@gobble
  \fi
}
\pagestyle{myheadings}

% |headings| 只有页眉，没有页脚，用于研究生的符号说明和本科生的 front matter。
\fancypagestyle{headings}{
  \fancyfoot{}
}

% 重定义|plain|字体大小
\fancypagestyle{plain}{%
  \fancyhf{}
  \fancyhead{}
  \renewcommand\headrulewidth{0pt}
  \def\hfut@hf@font{\fontsize{10.5bp}{20.475bp}\selectfont}
  \fancyfoot[C]{\hfut@hf@font\thepage}%
}

% 设置特殊的 page style 不改变任何内容，用于每章首页。
\def\ps@chapter{}
\ctexset{chapter/pagestyle=chapter}

% 空白页不加页眉和页码。
\def\cleardoublepage{\clearpage\if@twoside \ifodd\c@page\else
  \hbox{}\thispagestyle{empty}\newpage\if@twocolumn\hbox{}\newpage\fi\fi\fi}
  %
  % 研究生要求从“中文摘要”开始页码用大写罗马数字，
  % 而本科生的 frontmatter不编页码，从正文开始页码用阿拉伯数字。
\renewcommand\frontmatter{%
  \cleardoublepage
  \@mainmatterfalse
  \pagestyle{plain}%
  \pagenumbering{Roman}%
}

% 研究生要求“第 1 章”要另页起，但是本科生要求另面起。
\renewcommand\mainmatter{%
  \ifhfut@degree@graduate
    \cleardoublepage
    \pagenumbering{arabic}%
  \else
    \clearpage
    \pagenumbering{arabic}%
  \fi
  \pagestyle{myheadings}%
  \@mainmattertrue
}

% 研究生要求"参考文献"起 无页眉，但是本科生仍然有页眉。
\renewcommand\backmatter{%
  \ifhfut@degree@graduate
    \clearpage
    \pagestyle{plain}%
  \else
    \clearpage
  \fi
  \hfut@appendixfalse
}

\g@addto@macro\appendix{
  \renewcommand\thechapter{\@arabic\c@chapter}
  \@mainmattertrue
  \hfut@appendixtrue
}%
% \subsection{附录}
% fakeTODO 处理附录编号问题
% 研究生附录按照附录1、附录2编号；[数学学院本科生附录不编号，请将以下`\renewcommand\appendix` 取消注释]
% \renewcommand\appendix{%
%   \ifhfut@degree@bachelor
%     \ctexset{
%       chapter/numbering=false,
%       chapter/format = \centering\rmfamily\bfseries\fontsize{18bp}{18bp}\selectfont,
%       chapter/beforeskip  = 9bp,
%       chapter/afterskip   = 27bp,
%     }
%     \setcounter{chapter}{1}
%   \else
%     \ctexset{appendix/number=\arabic{chapter}}
%   \fi
% }
\ctexset{appendix/number=\arabic{chapter}}

% \subsection{封面}

% 定义用户接口：
\hfut@define@key{
  ugtype = {
    default = {论文},
  },
  title = {
    default = {论文题目},
  },
  title* = {
    default = {Title},
    name    = title@en,
  },
  author = {
    default = {作者姓名},
  },
  stuID = {
    default = {学号},
  },
  clc  = {
    default = {分类号},
  },
  author* = {
    default = {Author Name},
    name    = author@en,
  },
  speciality = {
    default = {专业},
  },
  hfuteryear = {
    default = {2017级},
  },
  research = {
    default = {研究方向},
  },
  supervisor = {
    default = {导师姓名},
  },
  department = {
    default = {学院名称},
  },
  advisor = {
    default = {},
  },
  advisor* = {
    default = {},
    name    = advisor@en,
  },
  applydegree = {
    default = {理学博士},
  },
  school = {
    default = {合肥工业大学},
  },
  phdchairman = {
    default = {},
    name    = phd@chairman,
  },
  phdmember = {
    default = {},
    name    = phd@member,
  },
  date = {
    default = {\the\year-\two@digits{\month}},
  },
  defensedate = {
    default = {},
  },
  professional-type = {
    name = professional@type,
  },
  professional-type* = {
    name = professional@type@en,
  },
  secret-level = {
    default = {},
    name    = secret@level,
  },
  secret-level* = {
    name    = secret@level@en,
  },
  secret-year = {
    name    = secret@year,
  },
  signchairman = {
    default = {},
    name    = sign@chairman,
  },
  signmember = {
    default = {},
    name    = sign@member,
  },
  signsupervisor = {
    default = {},
    name    = sign@supervisor,
  },
  keywords,
  keywords* = {
    name    = keywords@en,
  },
}

% 导师一栏可能有多个姓名，所以用 \opt{supervisor} 进行收集，
% 然后使用本命令来输出要求的格式，
% 类似于 \LaTeX3 的 \cs{clist\_use:Nn}。
\newcommand\hfut@clist@count[1]{%
  \csname clist_count:N\endcsname{#1}%
}
\newcommand\hfut@clist@use[2]{%
  \csname clist_use:Nn\endcsname{#1}{#2}%
}
\newcommand\hfut@supervisor@names{%
  \hfut@clist@use{\hfut@supervisor}{\quad}
}
\newcommand\hfut@advisor@names{%
  \hfut@clist@use{\hfut@advisor}{\quad}
}

% 输出日期的给定格式：\cs{hfut@format@date}\marg{format}\marg{date}，
% 其中格式 \meta{format} 接受三个参数分别对应年、月、日，
% \meta{date} 是 （yyyy-m）。
\newcommand\hfut@format@date[2]{%
  \edef\hfut@@date{#2}%
  \def\hfut@@process@date##1-##2\@nil{%
    #1{##1}{##2}%
  }%
  \expandafter\hfut@@process@date\hfut@@date\@nil
}
\newcommand\hfut@date@format@zh[2]{#1 年 \number#2 月}
\newcommand\hfut@date@month[1]{%
  \ifcase\number#1\or
    January\or February\or March\or April\or May\or June\or
    July\or August\or September\or October\or November\or December%
  \fi
}
\newcommand\hfut@date@format@en[2]{\hfut@date@month{#2}, #1}
\newcommand\hfut@date@zh{\hfut@format@date{\hfut@date@format@zh}{\hfut@date}}
\newcommand\hfut@date@en{\hfut@format@date{\hfut@date@format@en}{\hfut@date}}

% 版本 v3.2 开始使用 \cs{hfutsetup} 设置接口，
% 兼容旧版本的命令式设置。
% Reserved for compatibility until 2020-07-01.
\def\hfut@define@term#1#2{%
  \expandafter\gdef\csname #1\endcsname##1{%
    \hfutsetup{#2 = {##1}}%
  }%
}
\hfut@define@term{title}{title}
\hfut@define@term{entitle}{title*}
\hfut@define@term{author}{author}
\hfut@define@term{enauthor}{author*}
\hfut@define@term{major}{speciality}
\hfut@define@term{supervisor}{supervisor}
\gdef\cosupervisor#1{%
  \g@addto@macro\hfut@supervisor{, #1}%
}
\gdef\date#1{\renewcommand\hfut@date@zh{#1}}
\gdef\endate#1{\renewcommand\hfut@date@en{#1}}
\hfut@define@term{professionaltype}{professional-type}
\hfut@define@term{enprofessionaltype}{professional-type*}
\hfut@define@term{secretlevel}{secret-level}
\hfut@define@term{ensecretlevel}{secret-level*}
\hfut@define@term{secretyear}{secret-year}
\gdef\keywords#1{\renewcommand\hfut@keywords@text{#1}}
\gdef\enkeywords#1{\renewcommand\hfut@keywords@en@text{#1}}

% 定义一些常量。
\ifhfut@degree@doctor
  \newcommand\hfut@thesis@name{博士学位论文}
  \newcommand\hfut@degreetype@name{博士}
  \newcommand\hfut@thesis@name@en{A Dissertation Submitted to \par
  Hefei University of Technology \par
  in accordmance with the requirement \par
  for the Degree of Doctor of Philosophy}
  \newcommand\hfut@thesis@name@encover{DOCTORAL DISSERTATION}
\else
  \ifhfut@degree@master
    \newcommand\hfut@thesis@name{硕士学位论文}
    \newcommand\hfut@thesis@name@en{A Dissertation Submitted for the Degree of Master}
    \newcommand\hfut@thesis@name@encover{MASTER'S DISSERTATION}
  \else
    \newcommand\hfut@thesis@name{本科毕业设计（论文）}
    \newcommand\hfut@thesis@name@en{A Dissertation Submitted for the Degree of Bachelor}
    \newcommand\hfut@thesis@name@encover{UNDERGRADUATE THESIS}
  \fi
\fi

\ifhfut@degree@master
  \ifhfut@degree@type@academic
    \newcommand\hfut@degreetype@name{学历硕士}
  \else
    \newcommand\hfut@degreetype@name{专业硕士}
  \fi
\fi

\ifhfut@degree@type@academic
  \ifhfut@degree@doctor
    \newcommand\hfut@speciality@name{学科专业}
  \else
    \newcommand\hfut@speciality@name{专业名称}
  \fi
\else
  \ifhfut@cjk@font@mac
    \providecommand\lishu{\CJKfamily{zhli}}
  \else
    \ifhfut@cjk@font@windows
      \setCJKfamilyfont{zhli}{LiSu}
      \providecommand\lishu{\CJKfamily{zhli}}
    \else
      \hfut@warning{LiShu font is required}
      \providecommand\lishu{\sffamily}
    \fi
  \fi
  \newcommand\hfut@speciality@name{专业名称}
\fi

% 定义校徽颜色
\definecolor{hfutred}{cmyk}{0.3,1,0.95,0.05}

% 添加 PDF 书签，在 \pkg{hyperref} 载入后才有效。
\newcommand\hfut@pdfbookmark{\@gobble}

% 重定义 \env{titlepage} 环境，不修改页码。
\renewenvironment{titlepage}{%
  \cleardoublepage
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse\newpage
  \fi
  \thispagestyle{empty}%
}{%
  \if@restonecol\twocolumn \else \newpage \fi
}

% TODO: 做一些定义用以实现：不定长, 自动换行且有定长下划线的“论文标题”
% from:
% https://github.com/CTeX-org/forum/issues/208
% https://syvshc.github.io/2021-08-04-thesis-title/
% https://zhuanlan.zhihu.com/p/51494365

% inner temp length
\newlength\@tempTitleHt
\newlength\@tempTitleMaxWd

% length used as parameters， "Wd" is a shorthand for "Width"
\newlength\titleSingleLineMaxWd
\newlength\titleMultiLineMaxWd
\newlength\titleLRExtraWd
\newlength\titleSepWd

\setlength\titleSingleLineMaxWd{8.5cm}
\setlength\titleMultiLineMaxWd{7cm}
\setlength\titleLRExtraWd{0em}
\setlength\titleSepWd{.5em}

% main macro, using a simple table
% \newcommand{\multilingualTitles}[2]{%
%   \par
%   {\noindent\centering
%   \begin{tabular}{r @{\hspace{\titleSepWd}} p{\titleSingleLineMaxWd}}
%   	中文标题           & \titleBox{#1} \\
%   	                 &               \\[-10pt]
%   	Title in English & \titleBox{#2}
%   \end{tabular}\par}%
% }

% draw a fixed-width underline
\newcommand{\titleUnderline}{%
  \rule[-.3em]{\titleSingleLineMaxWd + 2\titleLRExtraWd}{.5pt}}

% title content typesetter
\newcommand\titleBox[1]{%
  \setlength\@tempTitleMaxWd\titleSingleLineMaxWd
  % Measure the total height of #1 subject to \titleSingleLineMaxWd.
  % Here \@titleBox is necessary when #1 contains "\\".
  \settototalheight\@tempTitleHt{\@titleBox{#1}}%
  \ifdim\@tempTitleHt=0pt%
    % case 1: #1 causes empty output
    \titleUnderline
  \else
    % Change to LR mode, for inserting a zero-width box right after.
    \leavevmode
    % note: Use \normalbaseineskip instead of \baselineskip, 
    %       since the latter is set to 0pt inside tabular env.
    \ifdim\@tempTitleHt>\normalbaselineskip
      % case 2: #1 is fit for multilines, or contains `\\`, hence
      %         \titleMultiLineMaxWd is used instead, and the total 
      %         height of #1 subject to new max width is re-measured.
      \setlength\@tempTitleMaxWd\titleMultiLineMaxWd
      \settototalheight\@tempTitleHt{\@titleBox{#1}}%
      % \rlap{\smash{...}} typesets content of its argument normally 
      % but sets it into a zero sized box. Here \@titleBox set 
      % (possiblly) multi-line text into a single box, since \smash 
      % only takes in argument spreading one line.
      %
      % Every line of title content needs an underline, hense we do
      % a loop to typeset one underline for every line the title 
      % content actually spreads.
      \rlap{\smash{\@titleBox{%
        \@whiledim\@tempTitleHt>0pt%
        \leavevmode
        % 
        \do{%
          \rlap{\titleUnderline}\\%
          \addtolength\@tempTitleHt{-\normalbaselineskip}%
        }%
      }}}%
      % Insert h-offset to manually center the title content.
      \hspace{\dimexpr\titleLRExtraWd + .5\titleSingleLineMaxWd - .5\titleMultiLineMaxWd\relax}%
      \@titleBox{\centering #1}%
    \else
      % case 3: #1 is fit for one line
      \rlap{\titleUnderline}%
      \hspace{\titleLRExtraWd}%
      \@titleBox{\centering #1}%
    \fi
  \fi
}

% common operations on every title content
\newcommand{\@titleBox}[1]{%
  \parbox[t]{\@tempTitleMaxWd}{#1}}

\newlength{\lwtm}
\setlength{\lwtm}{\widthof{论文题目 :}}

% 中文封面：
% 抬头黑体 12 磅；
% 论文类型：研究生黑体 48 磅，本科生黑体42磅；
% 论文类型英文 Times New Roman 22 磅；
% 封面信息 宋体 16 磅
% 论文题目黑体 26 磅加粗居中，单倍行距；
% 作者姓名宋体 16 磅，单倍行距；
% 注意这里的“单倍行距”的地方开启了“对齐到网格”，所以实际行距有所偏差，
% 所以只能使用直尺测量。
\newcommand\hfut@speciality@sse{软件工程}
% 生成空的下划线
\newcommand\hfut@underline[2][3.4cm]{\underline{\hb@xt@ #1{\hss#2\hss}}}
\newcommand\hfut@makecover{%
  \hfutsetup{language=chinese}%
  \begin{titlepage}%
    \hfut@pdfbookmark{封面}%
    \centering
    \ifhfut@degree@bachelor
      \ifx\hfut@secret@level\@empty
        {\sffamily\bfseries\fontsize{12bp}{19.5bp}\selectfont
        学\hspace{2\ccwd}号：\hfut@underline{\hfut@stuID} \hfill
        密\hspace{1em}级：\hfut@underline{公开} \par}
      \else
        {\sffamily\bfseries\fontsize{12bp}{19.5bp}\selectfont
        学\hspace{2\ccwd}号：\hfut@underline{\hfut@stuID} \hfill
        密\hspace{1em}级：\hfut@underline{\hfut@secret@level\bigstar\hfut@secret@year} \par}
      \fi
      \vskip 1.15cm%
    \else
      \ifx\hfut@secret@level\@empty
        {\sffamily\bfseries\fontsize{12bp}{19.5bp}\selectfont
        单位代码：\hfut@underline{10359} \hfill
        密\hspace{1em}级：\hfut@underline{公开} \par
        学\hspace{2\ccwd}号：\hfut@underline{\hfut@stuID} \hfill
        分类号：\hfut@underline{\hfut@clc} \par}
      \else
        {\sffamily\bfseries\fontsize{12bp}{19.5bp}\selectfont
        单位代码：\hfut@underline{10359} \hfill
        密\hspace{1em}级：\hfut@underline{\hfut@secret@level\bigstar\hfut@secret@year} \par
        学\hspace{2\ccwd}号：\hfut@underline{\hfut@stuID} \hfill
        分类号：\hfut@underline{\hfut@clc} \par}
      \fi
      \vskip 1.8cm%
    \fi

    \includegraphics[height=1.4cm]{figures/hfut-name.pdf}\par
    \vskip 0.3cm
    {\bfseries\fontsize{22bp}{22bp}\selectfont Hefei University of Technology\par}
    \ifhfut@degree@bachelor
      \vskip 1.1cm%
      {\sffamily\bfseries\fontsize{42bp}{42bp}\selectfont
      \hfut@thesis@name\par}%
      \vskip 0.6cm
    \else
      \vskip 1.0cm%
      {\sffamily\bfseries\fontsize{48bp}{48bp}\selectfont
      \hfut@thesis@name\par}%
      \vskip 0.5cm
    \fi
    {\bfseries\fontsize{22bp}{22bp}\selectfont
    \hfut@thesis@name@encover \par}%
    \ifhfut@degree@master
      \vskip 3.5cm
    \else
      \vskip 0.9cm%
      \includegraphics[height=3.6cm]{figures/hfut-badge.pdf}%
    \fi
    \ifhfut@degree@bachelor
      \vskip 1.5cm
    \else
      \vskip 2.3cm
    \fi
    \renewcommand\arraystretch{1.5}
    \ifhfut@degree@bachelor
      {\fontsize{16bp}{20bp}\selectfont
      \begin{tabular}{>{\fontsize{16bp}{20bp}\rmfamily\bfseries\selectfont}l>{\rmfamily\fontsize{16bp}{20bp}\selectfont}c}%
        类\hspace{2\ccwd}型：& \hfut@ugtype \\
        \cline{2-2}
        题\hspace{2\ccwd}目：& \hfut@title \\
        \cline{2-2}
        \hfut@speciality@name：& \hfut@speciality\\
        \cline{2-2}
        入学年份：& \hfut@hfuteryear \\
        \cline{2-2}
        学生姓名：& \hfut@author \\
        \cline{2-2}
        指导教师：& \hfut@supervisor@names \\
        \cline{2-2}
        学院名称：& \hfut@department \\
        \cline{2-2}
        完成时间：& \hfut@date@zh \\
        \cline{2-2}
      \end{tabular}\par}%
    \else
      \begin{tabular}{>{\rmfamily\bfseries\fontsize{16bp}{20bp}\selectfont}lp{8.5cm}}%
        论文题目：& \multirow[t]{2}{8.5cm}{
          \centering\linespread{1.5}\fontsize{16bp}{20bp}\selectfont
          \hfut@title} \\
          \cline{2-2}
                & \\
        \cline{2-2}
      \end{tabular}
      \renewcommand\arraystretch{1.5}
      \begin{tabular}{>{\bfseries\fontsize{16bp}{20bp}\selectfont}l>{\centering\arraybackslash\fontsize{16bp}{20bp}\selectfont}p{8.5cm}}
        \ifhfut@degree@master
          学位类别：& \hfut@degreetype@name\\
          \cline{2-2}
        \fi
        \hfut@speciality@name：& \hfut@speciality\\
        \cline{2-2}
        作者姓名：& \hfut@author \\
        \cline{2-2}
        导师姓名：& \hfut@supervisor@names \\
        \cline{2-2}
        完成时间：& \hfut@date@zh \\
        \cline{2-2}
      \end{tabular}\par%
      \fi
      \renewcommand\arraystretch{1}
  \end{titlepage}%
  \hfut@reset@main@language
}

\newcommand{\underlineFixlen}[2][4.85cm]{\underline{\makebox[#1][c]{#2}}}

% 博士学位论文 题名页
\newcommand\hfut@makephdtitle{%
  \hfutsetup{language=chinese}%
  \begin{titlepage}%
    \hfut@pdfbookmark{题名页}%
    \centering
    \ifx\hfut@secret@level\@empty
      {\sffamily\bfseries\fontsize{12bp}{20bp}\selectfont
      单位代码：\hfut@underline{10359} \hfill
      密\hspace{1em}级：\hfut@underline{公开} \par
      学\hspace{2\ccwd}号：\hfut@underline{\hfut@stuID} \hfill
      分类号：\hfut@underline{\hfut@clc} \par}
    \else
      {\sffamily\bfseries\fontsize{12bp}{20bp}\selectfont
      单位代码：\hfut@underline{10359} \hfill
      密\hspace{1em}级：\hfut@underline{\hfut@secret@level\bigstar\hfut@secret@year} \par
      学\hspace{2\ccwd}号：\hfut@underline{\hfut@stuID} \hfill
      分类号：\hfut@underline{\hfut@clc} \par}
    \fi
    
    \vskip 2.1cm
    {\sffamily\bfseries\fontsize{22bp}{27.5bp}\selectfont
    博\hspace{0.5\ccwd}士\hspace{0.5\ccwd}学\hspace{0.5\ccwd}位\hspace{0.5\ccwd}论\hspace{0.5\ccwd}文\par}%
    \vskip 1.3cm
    \renewcommand\arraystretch{1.5}
    \begin{tabular}{@{}p{11.4cm}@{}}%
        \multirow[t]{2}{11.4cm}{
        \centering\linespread{1.5}\bfseries\fontsize{16bp}{24bp}\selectfont
        \hfut@title} \\
      \cline{1-1}
              \\
      \cline{1-1}
    \end{tabular}
    \vskip 1.5cm%
    {\linespread{1.25}
    \bfseries\fontsize{16bp}{16bp}\selectfont
    \uline{\hfut@title@en}\par}%
    \vskip 3.5cm%
    {\linespread{1.5}\fontsize{15bp}{15bp}\selectfont
      \textbf{作者姓名：}\underlineFixlen{\hfut@author} \hfill \textbf{导师姓名：}\underlineFixlen{\hfut@supervisor@names} \par
      \textbf{申请学位：}\underlineFixlen{\hfut@applydegree} \hfill \textbf{培养单位：}\underlineFixlen{\hfut@school} \par
      \textbf{学科专业：}\underlineFixlen{\hfut@speciality} \hfill \textbf{研究方向：}\underlineFixlen{\hfut@research} \par
      \textbf{提交日期：}\underlineFixlen{\hfut@date@zh} \hfill \textbf{答辩日期：}\underlineFixlen{\hfut@defensedate} \par
    }
    \vskip 1.3cm
    \renewcommand\arraystretch{1.5}
    \begin{tabular}{@{}>{\fontsize{15bp}{22.5bp}\selectfont}p{15.9cm}@{}}%
      \textbf{答辩委员会主席：} \hfut@phd@chairman \\
      \cline{1-1}
      \textbf{评\hspace{2\ccwd}阅\hspace{2\ccwd}人：} \hfut@phd@member  \\
      \cline{1-1}
    \end{tabular}
    \renewcommand\arraystretch{1}
    \vfill

    {\fontsize{15bp}{15bp}\selectfont\hfut@date@zh}

  \end{titlepage}%
}


\newcommand\hfut@makezhtitle{%
  \hfutsetup{language=chinese}%
  \begin{titlepage}%
    \hfut@pdfbookmark{中文内封页}%
    \centering
    {\sffamily\fontsize{22bp}{40bp}\selectfont
      合\hspace{1.5\ccwd}肥\hspace{1.5\ccwd}工\hspace{1.5\ccwd}业\hspace{1.5\ccwd}大\hspace{1.5\ccwd}学\par}%
    \vskip 1.8cm%
    \ifhfut@degree@master
      {\sffamily\bfseries\fontsize{22bp}{30bp}\selectfont
      \hfut@degreetype@name 学位论文\par}% 空格不可忽略
    \else
      {\sffamily\bfseries\fontsize{22bp}{30bp}\selectfont
      \hfut@thesis@name\par}%
    \fi
    \vskip 1.8cm%
    {\bfseries\fontsize{22bp}{30bp}\selectfont
    \hfut@title\par}%
    \ifhfut@degree@bachelor
      \vskip 6.5cm
    \else
      \vskip 8cm%
    \fi
      \begin{tabular}{>{\fontsize{16bp}{16bp}\rmfamily\bfseries\selectfont}l>{\centering\arraybackslash\fontsize{16bp}{16bp}\rmfamily\selectfont}p{8.4cm}}%
        \ifhfut@degree@bachelor
          学生姓名：& \hfut@author \\
          \cline{2-2}\\
          学生学号：& \hfut@stuID \\
          \cline{2-2}\\
          指导教师：& \hfut@supervisor@names \\
          \cline{2-2}\\
          \hfut@speciality@name：& \hfut@speciality\\
          \cline{2-2}\\
          学院名称：& \hfut@department \\
          \cline{2-2}
        \else
          \ifhfut@degree@doctor
            作者姓名：& \hfut@author\\
            \cline{2-2}\\
            申请学位：& \hfut@applydegree \\
            \cline{2-2}\\
            研究方向：& \hfut@research \\
            \cline{2-2}\\
            \hfut@speciality@name：& \hfut@speciality\\
            \cline{2-2}\\
            指导教师：& \hfut@supervisor@names \\
            \cline{2-2}
          \else
            \ifx\hfut@advisor\@empty
              作者姓名：& \hfut@author \\
              \cline{2-2}\\
              指导教师：& \hfut@supervisor@names \\
              \cline{2-2}\\
              学科专业：& \hfut@speciality \\
              \cline{2-2}\\
              研究方向：& \hfut@research \\
              \cline{2-2}
            \else
              作者姓名：& \hfut@author \\
              \cline{2-2}\\
              指导教师：& \hfut@supervisor@names \\
              \cline{2-2}\\
                & \hfut@advisor@names \\
              \cline{2-2}\\
              专业名称：& \hfut@speciality \\
              \cline{2-2}\\
              研究方向：& \hfut@research \\
              \cline{2-2}
            \fi
          \fi
        \fi
    \end{tabular}\par%
    \vfill
    {\fontsize{15bp}{15bp}\selectfont\hfut@date@zh}
  \end{titlepage}%
  \hfut@reset@main@language
}

% 英文内封页
\newcommand\hfut@makeentitle{%
  \hfutsetup{language=english}%
  \begin{titlepage}%
    \hfut@pdfbookmark{English inner cover}%
    \centering
    \vspace*{0.5cm}%
    {\fontsize{16bp}{30bp}\selectfont
    \hfut@thesis@name@en\par}%
    \vskip 2.0cm%
    {\bfseries\fontsize{18bp}{30bp}\selectfont
    \hfut@title@en\par}%
    \vskip 1.2cm%
    {\fontsize{16bp}{30bp}\selectfont
    By\par
    \hfut@author@en\par}%
    \ifhfut@degree@doctor
      \vskip 7.0cm
    \else
      \vskip 10.0cm
    \fi
    {\fontsize{16bp}{31bp}\selectfont
    Hefei University of Technology\par
    Hefei, Anhui, P.R.China\par
    \hfut@date@en\par}%
  \end{titlepage}%
  \hfut@reset@main@language
}

% 重新定义 \cs{maketitle}，调用 \cs{hfut@makezhtitle}, \cs{hfut@makeentitle}
% 分别生成封面，中、英文标题页。
\renewcommand\maketitle{%
  \newgeometry{margin=2.54cm}%
  \pagenumbering{Alph}%
  \pagestyle{empty}%
  \hfut@makecover
  \ifhfut@degree@doctor
    \hfut@makephdtitle
  \fi
  \hfut@makezhtitle
  \hfut@makeentitle
  \restoregeometry
  \pagestyle{plain}%
}

\newcommand\signaturepage{%
  \begin{titlepage}%
    \hfut@pdfbookmark{答辩委员签名页}%
    \null
    {\centering\sffamily\bfseries\fontsize{22bp}{33bp}\selectfont
    合\hspace{0.5\ccwd}肥\hspace{0.5\ccwd}工\hspace{0.5\ccwd}业\hspace{0.5\ccwd}大\hspace{0.5\ccwd}学\par}
    \vskip 0.8cm
    {\fontsize{16bp}{30bp}\selectfont
    本论文经答辩委员会全体委员审查，确认符合合肥工业大学\hfut@degreetype@name 学位论文质量要求。\par}
    \vskip 2.5cm
    {\centering\fontsize{16bp}{24bp}\selectfont
    \textbf{答辩委员会签名（工作单位、职称、姓名）}\par}
    \vskip 1.0cm
    {\fontsize{16bp}{16bp}\selectfont
    主席：\hfut@sign@chairman \par}
    \vskip 1.0cm
    {\fontsize{16bp}{16bp}\selectfont
    委员：\parbox[t]{10.5cm}{\linespread{2.0}\selectfont\hfut@sign@member} \par}
    \vfill
    {\fontsize{16bp}{16bp}\selectfont
    导师：\hfut@sign@supervisor }
  \end{titlepage}%
}

\ifhfut@degree@bachelor
  \let\signaturepage\relax
\fi
% Reserved for compatibility until 2020-07-01.
\let\makestatement\signaturepage


% \subsection{原创性声明}

% 定义原创性声明
\newcommand\hfut@originality@master{%
  本人郑重声明：所呈交的学位论文是本人在导师指导下进行独立研究
  工作所取得的成果。据我所知，除了文中特别加以标注和致谢的内容
  外，论文中不包含其他人已经发表或撰写过的研究成果，也不包含为
  获得\underline{\hspace{0.5\ccwd}合肥工业大学\hspace{0.5\ccwd}}或
  其他教育机构的学位或证书而使用过的材料。对本文成果做出贡献的
  个人和集体，本人已在论文中作了明确的说明，并表示谢意。\par%
  学位论文中表达的观点纯属作者本人观点，与合肥工业大学无关。}
\newcommand\hfut@authorization@master{%
  本学位论文作者完全了解\underline{\hspace{0.5\ccwd}合肥工业大学\hspace{0.5\ccwd}}有关保留、使用学位论文%
  的规定，即：除保密期内的涉密学位论文外，学校有权保存并向国家%
  有关部门或机构送交论文的复印件和电子光盘，允许论文被查阅或借%
  阅。本人授权\underline{\hspace{0.5\ccwd}合肥工业大学\hspace{0.5\ccwd}}可以将本学位论文的全部或部分内容%
  编入有关数据库，允许采用影印、缩印或扫描等复制手段保存、汇编%
  学位论文。\par%
  （保密的学位论文在解密后适用本授权书）}

\newcommand\hfut@originality@bachelor{%
  本人郑重声明：所呈交的毕业设计（论文）是本人在指导教师指导下
  进行独立研究工作所取得的成果。据我所知，除了文中特别加以标注
  和致谢的内容外，设计（论文）中不包含其他人已经发表或撰写过的
  研究成果，也不包含为获得\underline{\hspace{0.5\ccwd}合肥工业大学\hspace{0.5\ccwd}}或
  其他教育机构的学位或证书而使用过的材料。对本文成果做出贡献的
  个人和集体，本人已在设计（论文）中作了明确的说明，并表示谢意。\par%
  毕业设计（论文）中表达的观点纯属作者本人观点，与合肥工业大学无关。}
\newcommand\hfut@authorization@bachelor{%
  本学位论文作者完全了解\underline{\hspace{0.5\ccwd}合肥工业大学\hspace{0.5\ccwd}}有关保留、使用毕业设计（论文）的规定，即：除保密期内的涉密设计（论文）外，学校有权
  保存并向国家有关部门或机构送交设计（论文）的复印件和电子光盘，
  允许设计（论文）被查阅或借阅。本人授权\underline{\hspace{0.5\ccwd}合肥工业大学\hspace{0.5\ccwd}}可以将本毕业设计（论文）的全部或部分内容编入有关数据库，允许采用影
  印、缩印或扫描等复制手段保存、汇编毕业设计（论文）。\par%
  （保密的毕业设计（论文）在解密后适用本授权书）}
  %
  

\newcommand\copyrightpage{%
  \begin{titlepage}%
    \hfut@pdfbookmark{原创性和授权使用声明}%
    \null
    \renewcommand\arraystretch{1.5}
    \ifhfut@degree@bachelor
      {\centering\sffamily\fontsize{18bp}{18bp}\selectfont
      \textbf{毕业设计（论文）独创性声明}\par}%
      \vskip 1.0cm%
      \hfut@originality@bachelor\par
      \vskip 0.9cm%
      毕业设计（论文）作者签名：\hfill%
      签字日期：\hspace{3\ccwd}年\hspace{2\ccwd}月\hspace{2\ccwd}日\par
      \vskip 2.33cm%
      {\centering\sffamily\fontsize{18bp}{18bp}\selectfont
      \textbf{毕业设计（论文）版权使用授权书}\par}%
      \vskip 1.0cm%
      \hfut@authorization@bachelor\par
      \vskip 1.0cm%
      \begin{tabular}{@{}p{6.5cm}p{6.5cm}@{}}%
        学位论文作者签名：& 指导教师签名：\\
        签名日期：\hspace{3\ccwd}年\hspace{2\ccwd}月\hspace{2\ccwd}日 & 签名日期：\hspace{3\ccwd}年\hspace{2\ccwd}月\hspace{2\ccwd}日
      \end{tabular}\par
    \else
      {\centering\sffamily\fontsize{18bp}{18bp}\selectfont
      \textbf{学位论文独创性声明}\par}%
      \vskip 1.25cm%
      \hfut@originality@master\par
      \vskip 1.1cm%
      学位论文作者签名：\hfill%
      签字日期：\hspace{3\ccwd}年\hspace{2\ccwd}月\hspace{2\ccwd}日\par
      \vskip 2.8cm%
      {\centering\sffamily\fontsize{18bp}{18bp}\selectfont
      \textbf{学位论文版权使用授权书}\par}%
      \vskip 1.25cm%
      \hfut@authorization@master\par
      \vskip 1.2cm%
      \begin{tabular}{@{}p{6.5cm}p{6.5cm}@{}}%
        学位论文作者签名：& 指导教师签名：\\
        签名日期：\hspace{3\ccwd}年\hspace{2\ccwd}月\hspace{2\ccwd}日 & 签名日期：\hspace{3\ccwd}年\hspace{2\ccwd}月\hspace{2\ccwd}日\\
      \end{tabular}\par
      \vskip 0.6cm
      \renewcommand\arraystretch{1.1}
      \begin{tabular}{@{}p{6.5cm}p{6.5cm}@{}}%
        论文作者毕业去向 & \\
        工作单位：& \\
        联系电话：& E-mail：\\
        通讯地址：& 邮政编码：
      \end{tabular}\par
      \renewcommand\arraystretch{1}
    \fi
  \end{titlepage}%
}

% Reserved for compatibility until 2020-07-01.
\let\makestatement\copyrightpage


% \subsection{章节标题}

% 标题最多允许使用五级。
\setcounter{secnumdepth}{5}

% 研究生规定章题为两字时中间空两字，三字时空一字，四字时空半字，四字以上不空。
% 这里用 \LaTeX3 的 \cs{str\_count:N} 判断字数。
% 注意，\pkg{stringstrings} 宏包会导致范数命令 \verb+\|+ 被修改。
\newcount\hfut@titlelength
\DeclareRobustCommand\hfut@spacetitle[1]{%
  \hfut@titlelength=\csname str_count:N\endcsname{#1}%
  \begingroup
    \ifhfut@degree@graduate
      \ifcase\hfut@titlelength
      \or\or
        \ziju{2}%
      \or
        \ziju{1}%
      \or
        \ziju{0.5}%
      \fi
    \else
      \if@mainmatter\else
        \ifcase\hfut@titlelength
        \or\or
          \ziju{1}%
        \or\or
          \ziju{0.5}%
        \fi
      \fi
    \fi
    #1%
  \endgroup
}

% 五级节标题和脚注需要使用带圈的数字，这里使用 \cs{hfut@circlefont} ：
\newcommand\hfut@textcircled[1]{%
  \ifnum\value{#1}<21\relax
    {\symbol{\numexpr\value{#1} + "245F\relax}}%
  \else
    \hfut@error{Cannot display more than 20 footnotes}%
  \fi
}

% 用 \pkg{ctex} 的接口设置全部章节标题格式。

% 各章标题：黑体 16 磅加粗居中，行距为单倍行距，段前 1 行，段后 1 行，
% 章序号与章名间空一字。

% 由于 Word 模板中使用“单倍行距”，还“对齐到网格”，这在 TeX 中不容易实现。
% 所以目前按照默认的行距。

% 注意 \pkg{ctex} v2.4.3 以下版本的bug会导致章节标题前后的距离的实际值偏大。
% 另外 \pkg{ctex} v2.2 前的beforeskip的符号有特殊意义。
    
\ctexset{
  chapter = {
    format = {
        \centering
        \if@mainmatter
          \fontsize{16bp}{16bp}\sffamily\bfseries\selectfont
        \else
          \fontsize{18bp}{16bp}\rmfamily\bfseries\selectfont
        \fi
    },
    nameformat  = {},
    name        = {第,章},
    titleformat = {},
    number      = \chinese{chapter},
    aftername   = \hspace{0.5\ccwd},
    beforeskip  = {
      \if@mainmatter
        16bp
      \else
        9bp
      \fi
    },
    %tocline     = {
    %  \if@mainmatter
    %    %\if \@chapapp \appendixname
    %    \ifhfut@appendix
    %      {附录~\arabic{chapter}~~#2}
    %    \else
    %      {第\chinese{chapter}章~#2}
    %    \fi
    %  \else
    %    \CTEXnumberline{#1}#2
    %  \fi
    %},
    afterskip   = {
      \if@mainmatter
        16bp
      \else
        24bp
      \fi
    },
    fixskip     = true,
  },
}

% 一级节标题：黑体，小四号，左对齐
% 序号与题名间空一字。
\ctexset{
  section = {
    format     = \sffamily\fontsize{12bp}{15.6bp}\selectfont,
    aftername  = \hspace{0.5\ccwd},
    beforeskip = 7.8bp,
    afterskip  = 7.8bp,
  },
  %
  % 二级节标题：宋体，加黑，小四号，左对齐
  % 序号与题名间空一字。
  subsection = {
    format     = \rmfamily\bfseries\fontsize{12bp}{15.6bp}\selectfont,
    aftername  = \hspace{0.5\ccwd},
    beforeskip = 7.8bp,
    afterskip  = 7.8bp,
  },
  %
  % 三级及以下节标题的格式没有具体规定，按照数学学院推荐的方案：
  % 使用宋体 12 磅，左缩进两字，行距 20 磅，段前段后 0 磅，序号(n)与题名间空半字宽。
  subsubsection = {
    format     = \rmfamily\fontsize{12bp}{15.6bp}\selectfont,
    number     = (\arabic{subsubsection}),
    aftername  = \hspace{0.5\ccwd},
    beforeskip = \z@,
    afterskip  = \z@,
    indent     = 2\ccwd,
  },
  %
  % 采用西文式段标题，runin=true
  paragraph = {
    format     = \rmfamily\bfseries\fontsize{12bp}{20bp}\selectfont,
    number     = {},
    name       = {},
    aftername  = {},
    beforeskip = \z@,
    afterskip  = \ccwd, 
    indent     = 2\ccwd,
    runin      = true,
  },
  %
  % 采用西文式子段标题，runin=true
  subparagraph = {
    format     = \rmfamily\fontsize{12bp}{20bp}\selectfont,
    number     = {},
    name       = {},
    aftername  = {},
    beforeskip = \z@,
    afterskip  = \ccwd, 
    indent     = 2\ccwd,
    runin      = true,
  },
}

\ifhfut@degree@bachelor
  \ifhfut@main@language@english
    \hfutsetup{section-style = arabic}
  \fi
\fi
\hfut@option@hook{main-language}{%
  \ifhfut@degree@bachelor
    \ifhfut@main@language@english
      \hfutsetup{section-style = arabic}%
    \fi
  \fi
}

% 在研究生格式的基础上再设置本科生的章节标题格式。
\ifhfut@degree@bachelor
  \setcounter{secnumdepth}{4}
  \ctexset{
  %
  % 论文的致谢、目录、摘要和参考文献等标题用小二号（18 bp）黑体字，居中，
  % 这通过 \cs{if@mainmatter} 区分。
  % 正文中的标题分章、节、段三级；章、节标题居中，段标题居左，
  % 分别用三号（16 bp）黑体、小四（12 bp）黑体、小四（12 bp）黑体。
    chapter = {
      name = {},
      format = {
        \centering
        \if@mainmatter
          \fontsize{16bp}{22bp}\sffamily\bfseries\selectfont
        \else
          \fontsize{18bp}{22bp}\rmfamily\bfseries\selectfont
        \fi
      },
      nameformat  = \rmfamily\bfseries,
      number      = \thechapter,
      aftername   = \hspace{\ccwd},
      beforeskip  = {
        \if@mainmatter
          22bp
        \else
          11bp
        \fi
      },
      afterskip   = {
        \if@mainmatter
          22bp
        \else
          33bp
        \fi
      },
      fixskip     = true,
    },
    section = {
      format = \sffamily\fontsize{12bp}{22bp}\selectfont,
      beforeskip = 11bp,
      afterskip  = 11bp, 
      nameformat = \rmfamily\bfseries,
    },
    subsection = {
      format     = \rmfamily\bfseries\fontsize{12bp}{22bp}\selectfont,
      beforeskip = 11bp,
      afterskip  = 11bp, 
      nameformat = \rmfamily\bfseries\selectfont,
      indent     = \z@,
    },
    subsubsection = {
      format     = \rmfamily\fontsize{12bp}{22bp}\selectfont,
      number     = (\arabic{subsubsection}),
      aftername  = \hspace{0.5\ccwd},
      beforeskip = \z@,
      afterskip  = \z@,
      indent     = 2\ccwd,
    },
    paragraph = {
      format     = \rmfamily\bfseries\fontsize{12bp}{22bp}\selectfont,
      number     = {},
      name       = {},
      aftername  = {},
      beforeskip = \z@,
      afterskip  = \ccwd, 
      indent     = 2\ccwd,
      runin      = true,
    },
    subparagraph = {
      format     = \rmfamily\fontsize{12bp}{22bp}\selectfont,
      number     = {},
      name       = {},
      aftername  = {},
      beforeskip = \z@,
      afterskip  = \ccwd, 
      indent     = 2\ccwd,
      runin      = true,
    },
  }
  %
  % 本科生的阿拉伯数字式标题的格式与研究生几乎一致，只有中文数字式需要修改。
  \ifhfut@section@style@arabic\else
    \ctexset{
      chapter = {
        name = {},
        %number = \chinese{chapter}
      },
      section = {
        %name   = {第,节},
        %number = \chinese{section},
      },
      subsection = {
        %number    = \chinese{subsection},
        %aftername = {、},
      },
    }
  \fi
\fi

% 默认的 \cs{chapter*} 生成的章标题没有编号、不更改页眉，
% 也不添加进目录或 PDF 书签。
% 然而像摘要、目录、符号说明这样的章节，它们不需要编号、不加入目录，
% 但是需要修改页眉，并且加入 PDF 标签。
% 所以我们新定义 \cs{hfut@chapter} 用于处理这些章节。%
\NewDocumentCommand\hfut@chapter{o m}{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \IfValueTF{#1}{%
    \hfut@pdfbookmark{#1}%
    \chaptermark{#1}%
  }{%
    \hfut@pdfbookmark{#2}%
    \chaptermark{#2}%
  }%
  \chapter*{#2}}
  %
  %
  % \subsection{摘要}
  %
  % 中文摘要环境。
  % 判断 \cs{hfut@tocloaded} 是为了防止本科生未调整摘要位置时的目录页码缺失。
\newcommand\hfut@keywords@text{%
  \hfut@clist@use{\hfut@keywords}{；}%
}
\newcommand\hfut@keywords@en@text{%
  \hfut@clist@use{\hfut@keywords@en}{; }%
}
\newenvironment{abstract}{%
  \hfutsetup{language=chinese}%
  \ifhfut@degree@graduate
    \pagestyle{plain}
    \ctexset{chapter/format=\centering\Large\selectfont\bfseries}%
    \hfut@chapter[摘要]{摘\hspace{\ccwd}要}%
  \else
    \pagestyle{plain}
    \hfut@chapter[摘要]{摘\hspace{\ccwd}要}%
    % \ifhfut@tocloaded\else
    %   本科生需要手动将摘要置于目录后。\par
    % \fi
  \fi
}{
  \pagestyle{plain}
  \par\null\par\noindent
  \textbf{关键词：}\hfut@keywords@text\par
  \hfut@reset@main@language
}

% 英文摘要环境
\newenvironment{abstract*}{%
  \hfutsetup{language=english}%
  \ctexset{chapter/format=\centering\Large\selectfont\bfseries}%
  \setlength{\parindent}{1em}
  \ifhfut@degree@graduate
    \hfut@chapter[Abstract]{ABSTRACT}%
    \pagestyle{plain}
  \else
    \begingroup
      \pagestyle{plain}%
      \hfut@chapter[Abstract]{ABSTRACT}%
    \endgroup
  \fi
}{
  %\pagestyle{plain}
  \par\null\par\noindent
  \textbf{KEYWORDS:} \hfut@keywords@en@text\par
  \ifhfut@degree@graduate
    \cleardoublepage
  \fi
  \hfut@reset@main@language
}

% Reserved for compatibility until 2020-07-01.
\newenvironment{enabstract}{%
  \begin{abstract*}%
}{%
  \end{abstract*}%
}


% \subsection{目录}

% 判断是否已经加载目录，用于提醒本科生更改摘要和致谢的顺序。
\newif\ifhfut@tocloaded

% 判断是否在附录中
\newif\ifhfut@appendix

% 研究生规定目录另面起；
% 本科生规定从正文起标页码。
\renewcommand\tableofcontents{%
  \ifhfut@degree@bachelor
    \cleardoublepage
    %\pagenumbering{arabic}%
    \pagestyle{plain}%
    \hfut@tocloadedtrue
  \else
    \pagestyle{plain}%
  \fi
  \hfut@chapter{\contentsname}%
  \@starttoc{toc}%
}

% 下面用 \pkg{titletoc} 宏包设置目录内容的格式。
% 先定义目录线：
\newcommand\hfut@leaders{\titlerule*[9bp]{\textperiodcentered}}

% 各章目录要求宋体 12 磅，单倍行距，段前 6 磅，段后 0 磅，两端对齐，
% 页码右对齐，章序号与章名间空一字。
% 但是 Word 模板中实际是行距 20 磅。
\ifhfut@degree@graduate
  \titlecontents{chapter}
    [\z@]{\bfseries\normalsize}
    {\contentspush{\thecontentslabel\hspace{0.5\ccwd}}}{}
    {\normalsize\hfut@leaders\contentspage}
    %
    % 一级节标题目录要求宋体 12 磅，单倍行距，左缩进一字，段前 6 磅，段后 0 磅，
    % 两端对齐，页码右对齐，序号与题名间空一字。
    % Word 模板中实际是行距 20 磅，段前 0 磅。
  \titlecontents{section}
    [2\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel\hspace{0.5\ccwd}}}{}
    {\normalsize\hfut@leaders\contentspage}
    %
    % 二级节标题目录要求宋体 12 磅，单倍行距，左缩进两字，段前 6 磅，段后 0 磅，
    % 两端对齐，页码右对齐，序号与题名间空一字。
    % Word 模板中实际是行距 20 磅，段前 0 磅。
  \titlecontents{subsection}
    [4\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel\hspace{0.5\ccwd}}}{}
    {\normalsize\hfut@leaders\contentspage}
    %
    % 本科生的目录使用小四宋体（同正文字体），其他同研究生的格式相近。
\else
  \titlecontents{chapter}
    [\z@]{\bfseries\normalsize}
    {\contentspush{\thecontentslabel\unskip\hspace{0.5\ccwd}}}{}
    {\hfut@leaders\contentspage}
  \titlecontents{section}
    [2\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel\hspace{0.5\ccwd}}}{}
    {\hfut@leaders\contentspage}
  \titlecontents{subsection}
    [4\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel\hspace{0.5\ccwd}}}{}
      %\ifhfut@section@style@arabic\hspace{\ccwd}\else 、\fi}}{}
    {\hfut@leaders\contentspage}
\fi

% 本科生要求目录中正文每章前多空一行，而目录、附录等章则不需要空行，
% 所以不能简单判断 \cs{if@mainmatter}，需要重新定义 \cs{mainmatter} 等命令。
% \newif\ifhfut@addtocspace
% \ifhfut@degree@bachelor
%   \hfut@addtocspacetrue
%   \g@addto@macro\frontmatter{\hfut@addtocspacefalse}%
%   \g@addto@macro\mainmatter{\hfut@addtocspacetrue}%
%   \g@addto@macro\backmatter{\hfut@addtocspacefalse}%
%   \g@addto@macro\appendix{\hfut@addtocspacefalse}%
% \fi

% 处理本科生在目录中添加空行。
% \renewcommand\chapter{%
%   \if@openright\cleardoublepage\else\clearpage\fi
%   \thispagestyle{\CTEX@chapter@pagestyle}%
%   \global\@topnum\z@
%   \@afterindenttrue
%   \ifhfut@degree@bachelor
%     \ifhfut@addtocspace
%       \addtocontents{toc}{\protect\addvspace{12bp}}%
%     \fi
%   \fi
%   \secdef\@chapter\@schapter
% }

% 研究生要求图、表的清单须另页起。
\newlength{\hfut@lof@label@width}
\newcommand\hfut@set@lof@format{%
  \settowidth{\hfut@lof@label@width}{\figurename~9.99}%
  \addtolength{\hfut@lof@label@width}{0.5\ccwd}%
  \titlecontents{figure}%
    [\hfut@lof@label@width]{\normalsize}%
    {\contentslabel[\figurename~\thecontentslabel]{\hfut@lof@label@width}}{}%
    {\hfut@leaders\contentspage}%
  \titlecontents{table}%
    [\hfut@lof@label@width]{\normalsize}%
    {\contentslabel[\tablename~\thecontentslabel]{\hfut@lof@label@width}}{}%
    {\hfut@leaders\contentspage}%
}
\hfut@set@lof@format
\hfut@option@hook{main-language}{\hfut@set@lof@format}
\renewcommand\listoffigures{%
  \ifhfut@degree@graduate
    \cleardoublepage
  \fi
  \hfut@chapter{\listfigurename}%
  \@starttoc{lof}%
}
\renewcommand\listoftables{%
  \ifhfut@degree@graduate
    \cleardoublepage
  \fi
  \hfut@chapter{\listtablename}%
  \@starttoc{lot}%
}


% \subsection{符号说明}

% 研究生规定符号说明另页起，标题字体字号等同论文正文，
\newenvironment{notation}{%
  \ifhfut@degree@graduate
    \cleardoublepage
    \pagestyle{plain}%
  \fi
  \hfut@chapter{\hfut@notation@name}%
}{%
  \ifhfut@degree@graduate
    \clearpage
    \pagestyle{plain}%
  \fi
}%
\newcommand*\notationlabel[1]{#1\hfil}%
\newenvironment{notationlist}[1]{%
  \list{}{%
    \itemsep 3bp%
    \labelwidth #1\relax%
    \labelsep 1em%
    \leftmargin\labelwidth
    \advance\leftmargin\labelsep
    \advance\leftmargin 3em%
    \rightmargin 3em%
    \let\makelabel\notationlabel
  }%
}{%
  \endlist
}


% \subsection{正文}

% \cs{sloppy} 可以减少“overfull boxes”。
\sloppy

% 禁止扩大段间距。（\href{https://github.com/ustctug/ustcthesis/issues/209}{
%   ustctug/ustcthesis\#209}）
\raggedbottom

% 段间距 0 磅。
\setlength{\parskip}{\z@}

% 首段缩进。
\ctexset{autoindent=2}

% 首段缩进。
\let\@afterindentfalse\@afterindenttrue
\@afterindenttrue

% URL 的字体设为保持原样。
\urlstyle{same}

% 使用 \pkg{xurl} 宏包的方法，增加 URL 可断行的位置。
\def\UrlBreaks{%
  \do\/%
  \do\a\do\b\do\c\do\d\do\e\do\f\do\g\do\h\do\i\do\j\do\k\do\l%
     \do\m\do\n\do\o\do\p\do\q\do\r\do\s\do\t\do\u\do\v\do\w\do\x\do\y\do\z%
  \do\A\do\B\do\C\do\D\do\E\do\F\do\G\do\H\do\I\do\J\do\K\do\L%
     \do\M\do\N\do\O\do\P\do\Q\do\R\do\S\do\T\do\U\do\V\do\W\do\X\do\Y\do\Z%
  \do0\do1\do2\do3\do4\do5\do6\do7\do8\do9\do=\do/\do.\do:%
  \do\*\do\-\do\~\do\'\do\"\do\-}
\Urlmuskip=0mu plus 0.1mu

% 脚注用带圈的数字：
\renewcommand\thefootnote{\hfut@textcircled{footnote}}

% LaTeX 默认脚注按章计数，即每章的开始才重置脚注计数器；我们修改为按页计数。
% 简单的|\@addtoreset{footnote}{page}|并不可靠，
% \footnote{\url{https://texfaq.org/FAQ-footnpp.html}}
% 所以我们使用 \pkg{footmisc} 宏包。

% 脚注线长为版心宽度的四分之一：
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.25\textwidth
  \kern2.6\p@}
  %
  % 注文缩进两字：
\renewcommand\@makefntext[1]{%
  \parindent 2\ccwd\relax
  \noindent
  \hb@xt@2\ccwd{\hss\@makefnmark}#1}


% \subsection{列表}
% \label{sec:list}

% 调整列表中各项之间过大的间距。
\setlength\partopsep{\z@}
\newcommand\hfut@nolistsep{%
  \parsep 0\p@ \@plus.2\p@
  \topsep 0\p@ \@plus.2\p@
  \itemsep0\p@ \@plus.2\p@
}
\def\@listi{\leftmargin\leftmargini
            \hfut@nolistsep}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \hfut@nolistsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \hfut@nolistsep}


% \subsection{浮动体}

% \LaTeX{} 对放置浮动体的要求比较强，这里按照 UK TeX FAQ 的建议
% \footnote{\url{https://texfaq.org/FAQ-floats}} 对其适当放宽。
\renewcommand\topfraction{.85}
\renewcommand\bottomfraction{.7}
\renewcommand\textfraction{.15}
\renewcommand\floatpagefraction{.66}
\renewcommand\dbltopfraction{.66}
\renewcommand\dblfloatpagefraction{.66}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}

% 修改默认的浮动体描述符为 |htb|。
\def\fps@figure{h}
\def\fps@table{h}

% 用 \pkg{caption} 宏包设置图、表的格式：

% 图号、图题置于图的下方，宋体 10.5 磅居中，单倍行距，段前 6 磅，段后 12 磅，
% 图号与图题文字之间空一字，图号、图题加粗。
% 图注位于图的下方，左缩进两字，续行悬挂缩进左对齐，两端对齐。

% 表号、表题置于表的上方，黑体 10.5 磅居中，单倍行距，段前 6 磅，段后 6 磅，
% 表号与表题文字之间空一字，表号、表题加粗。
% 表注左缩进两字，续行悬挂缩进左对齐，两端对齐。
\setlength{\floatsep}{6bp}
\setlength{\textfloatsep}{6bp}
\setlength{\intextsep}{12bp}

% 由于 LaTeX2e kernel 的问题，图表等浮动体与文字前后的距离不一致，需要进行 patch。
% 参考 \href{https://github.com/tuna/thuthesis/issues/614}{tuna/thuthesis/issues\#614}、
% \url{https://www.zhihu.com/question/46618031} 和
% \url{https://tex.stackexchange.com/a/40363/82731}。
%    \begin{macrocode}
\patchcmd{\@addtocurcol}%
  {\vskip \intextsep}%
  {\edef\save@first@penalty{\the\lastpenalty}\unpenalty
   \ifnum \lastpenalty = \@M  % hopefully the OR penalty
     \unpenalty
   \else
     \penalty \save@first@penalty \relax % put it back
   \fi
   \ifnum\outputpenalty <-\@Mii
     \addvspace\intextsep
     \vskip\parskip
   \else
     \addvspace\intextsep
   \fi}%
  {}{\hfut@patch@error{\@addtocurcol}}
\patchcmd{\@addtocurcol}%
  {\vskip\intextsep \ifnum\outputpenalty <-\@Mii \vskip -\parskip\fi}%
  {\ifnum\outputpenalty <-\@Mii
     \aftergroup\vskip\aftergroup\intextsep
     \aftergroup\nointerlineskip
   \else
     \vskip\intextsep
   \fi}%
  {}{\hfut@patch@error{\@addtocurcol}}
\patchcmd{\@getpen}{\@M}{\@Mi}
  {}{\hfut@patch@error{\@getpen}}

\DeclareCaptionFont{hfut}{%
  \ifhfut@language@chinese
    \fontsize{10.5bp}{13.65bp}\selectfont
  \else
    \fontsize{10.5bp}{12.075bp}\selectfont
  \fi
}

\captionsetup{
  font           = hfut,
  labelsep       = quad,
  skip           = 6bp,
  figureposition = bottom,
  tableposition  = top,
}
% graduate的图表标题不需要加粗
% \ifhfut@degree@graduate
%   \captionsetup{font+=bf}
%   \captionsetup[table]{font+=sf}
% \fi

% 硕博需要中英文双标题
\captionsetup[figure][bi-second]{name=Fig} %设置图的英文编号前缀
\captionsetup[table][bi-second]{name=Tab} %设置表的英文编号前缀

% 新定义了 \cs{note} 来生成图表的附注。
% 如果用 \cs{caption} 生成图表的附注会导致图表的序号有误；
% 如果用 \cs{bicaption} 会导致表注无法置于表后，而且对齐方式不对。
\newcommand\note[1]{%
  \begingroup
    \captionsetup{
      font          = hfut,
      margin        = 2\ccwd,
      position      = bottom,
    }%
    \caption*{#1}%
  \endgroup
}

% 表格默认字号略小
\patchcmd\@floatboxreset{%
  \normalsize
}{%
  \small
}{}{\hfut@patch@error{\@floatboxreset}}

% 对 \pkg{longtable} 跨页表格进行相同的设置。
%
% 在 Word 模板中按照正确的设置（需要去掉文档网格），
% 中文模板每页能装下 1 行标题、1 行表头、30 行表身，
% 英文模板每页能装下 1 行标题、1 行表头、33 行表身。
%    \begin{macrocode}
\AtEndOfPackageFile*{longtable}{
  \AtBeginEnvironment{longtable}{%
    \small
  }
}


% \subsection{参考文献}

\PassOptionsToPackage{compress}{natbib}

\AtEndOfPackageFile*{natbib}{
  % 定义几种引用文献的标注样式。
  \newcommand\bibstyle@super{\bibpunct{[}{]}{,}{s}{,}{\textsuperscript{,}}}
  \newcommand\bibstyle@inline{\bibpunct{[}{]}{,}{n}{,}{,}}
  \newcommand\bibstyle@authoryear{\bibpunct{(}{)}{;}{a}{,}{,}}
  \@namedef{bibstyle@author-year}{\bibstyle@authoryear}
  %
  % 几种种引用样式，与 \file{bst} 文件名保持一致，
  % 这样在使用 \cs{bibliographystyle} 选择参考文献表的样式时也会设置对应的引用样式。
  \@namedef{bibstyle@hfutthesis-numerical}{\bibstyle@super}
  \@namedef{bibstyle@hfutthesis-authoryear}{\bibstyle@authoryear}
  \@namedef{bibstyle@hfutthesis-graduate}{\bibstyle@super}
  %
  % 如果载入 `natbib` 前设置了 `cite-style`，这里先进行配置。
  % https://github.com/ustctug/ustcthesis/issues/327
  \ifx\hfut@cite@style\@empty\else
    \citestyle{\hfut@cite@style}%
  \fi
  %
  % 定义接口 cite-style 切换引用样式。
  \hfut@option@hook{cite-style}{%
    \ifx\@begindocumenthook\@undefined
    \citestyle{\hfut@cite@style}%
    \fi
  }
  %
  % 如果文献序号作为叙述文字的一部分，需要临时将文献序号与正文平排
  \DeclareRobustCommand\inlinecite{\@inlinecite}
  \def\@inlinecite#1{\begingroup\let\@cite\NAT@citenum\citep{#1}\endgroup}
  %
  % 修改引用的样式。
  % 这里在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
  %
  % 将 super 式 \cs{citep} 引用的页码置于括号外。
  \renewcommand\NAT@citesuper[3]{\ifNAT@swa
    \if*#2*\else#2\NAT@spacechar\fi
    % \unskip\kern\p@\textsuperscript{\NAT@@open#1\NAT@@close}%
    %  \if*#3*\else\NAT@spacechar#3\fi\else #1\fi\endgroup}
    \unskip\kern\p@\textsuperscript{\NAT@@open#1\NAT@@close\if*#3*\else#3\fi}%
    \else #1\fi\endgroup}
  %
  % 将 numbers 式 \cs{citep} 引用的页码置于括号外并改为上标。
  \renewcommand\NAT@citenum%
      [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\NAT@spacechar\fi
          % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close\else#1\fi\endgroup}
          #1\NAT@@close\textsuperscript{\if*#3*\else#3\fi}\else#1\fi\endgroup}
  %
  % 在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
  \def\NAT@citexnum[#1][#2]#3{%
    \NAT@reset@parser
    \NAT@sort@cites{#3}%
    \NAT@reset@citea
    \@cite{\def\NAT@num{-1}\let\NAT@last@yr\relax\let\NAT@nm\@empty
      \@for\@citeb:=\NAT@cite@list\do
      {\@safe@activestrue
      \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
      \@safe@activesfalse
      \@ifundefined{b@\@citeb\@extra@b@citeb}{%
        {\reset@font\bfseries?}
          \NAT@citeundefined\PackageWarning{natbib}%
        {Citation `\@citeb' on page \thepage \space undefined}}%
      {\let\NAT@last@num\NAT@num\let\NAT@last@nm\NAT@nm
        \NAT@parse{\@citeb}%
        \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
          \let\NAT@name=\NAT@all@names
          \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
        \fi
        \ifNAT@full\let\NAT@nm\NAT@all@names\else
          \let\NAT@nm\NAT@name\fi
        \ifNAT@swa
        \@ifnum{\NAT@ctype>\@ne}{%
          \@citea
          \NAT@hyper@{\@ifnum{\NAT@ctype=\tw@}{\NAT@test{\NAT@ctype}}{\NAT@alias}}%
        }{%
          \@ifnum{\NAT@cmprs>\z@}{%
          \NAT@ifcat@num\NAT@num
            {\let\NAT@nm=\NAT@num}%
            {\def\NAT@nm{-2}}%
          \NAT@ifcat@num\NAT@last@num
            {\@tempcnta=\NAT@last@num\relax}%
            {\@tempcnta\m@ne}%
          \@ifnum{\NAT@nm=\@tempcnta}{%
            \@ifnum{\NAT@merge>\@ne}{}{\NAT@last@yr@mbox}%
          }{%
            \advance\@tempcnta by\@ne
            \@ifnum{\NAT@nm=\@tempcnta}{%
              % 在顺序编码制下，\pkg{natbib} 只有在三个以上连续文献引用才会使用连接号，
              % 这里修改为允许两个引用使用连接号。
              % 参考 https://tex.stackexchange.com/a/86991/82731 。
              %
              % \ifx\NAT@last@yr\relax
              %   \def@NAT@last@yr{\@citea}%
              % \else
              %   \def@NAT@last@yr{--\NAT@penalty}%
              % \fi
              \def@NAT@last@yr{-\NAT@penalty}%
            }{%
              \NAT@last@yr@mbox
            }%
          }%
          }{%
          \@tempswatrue
          \@ifnum{\NAT@merge>\@ne}{\@ifnum{\NAT@last@num=\NAT@num\relax}{\@tempswafalse}{}}{}%
          \if@tempswa\NAT@citea@mbox\fi
          }%
        }%
        \NAT@def@citea
        \else
          \ifcase\NAT@ctype
            \ifx\NAT@last@nm\NAT@nm \NAT@yrsep\NAT@penalty\NAT@space\else
              \@citea \NAT@test{\@ne}\NAT@spacechar\NAT@mbox{\NAT@super@kern\NAT@@open}%
            \fi
            \if*#1*\else#1\NAT@spacechar\fi
            \NAT@mbox{\NAT@hyper@{{\citenumfont{\NAT@num}}}}%
            \NAT@def@citea@box
          \or
            \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
          \or
            \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
          \or
            \NAT@hyper@citea@space\NAT@alias
          \fi
        \fi
      }%
      }%
        \@ifnum{\NAT@cmprs>\z@}{\NAT@last@yr}{}%
        \ifNAT@swa\else
          % 将 numerical 式 \cs{citet} 引用的页码置于括号外并改为上标。
          %
          % \@ifnum{\NAT@ctype=\z@}{%
          %   \if*#2*\else\NAT@cmt#2\fi
          % }{}%
          \NAT@mbox{\NAT@@close}%
          \@ifnum{\NAT@ctype=\z@}{%
            \if*#2*\else\textsuperscript{#2}\fi
          }{}%
        \fi
    }{#1}{#2}%
  }%
  %
  % 将 author-year 式 \cs{citep} 引用的页码置于括号外并改为上标：
  \renewcommand\NAT@cite%
      [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\NAT@spacechar\fi
          % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close\else#1\fi\endgroup}
          #1\NAT@@close\if*#3*\else\textsuperscript{#3}\fi\else#1\fi\endgroup}
  %
  % 调整 author-year 式 \cs{citet} 引用的页码。
  \def\NAT@citex%
    [#1][#2]#3{%
    \NAT@reset@parser
    \NAT@sort@cites{#3}%
    \NAT@reset@citea
    \@cite{\let\NAT@nm\@empty\let\NAT@year\@empty
      \@for\@citeb:=\NAT@cite@list\do
      {\@safe@activestrue
      \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
      \@safe@activesfalse
      \@ifundefined{b@\@citeb\@extra@b@citeb}{\@citea%
        {\reset@font\bfseries ?}\NAT@citeundefined
                  \PackageWarning{natbib}%
        {Citation `\@citeb' on page \thepage \space undefined}\def\NAT@date{}}%
      {\let\NAT@last@nm=\NAT@nm\let\NAT@last@yr=\NAT@year
        \NAT@parse{\@citeb}%
        \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
          \let\NAT@name=\NAT@all@names
          \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
        \fi
      \ifNAT@full\let\NAT@nm\NAT@all@names\else
        \let\NAT@nm\NAT@name\fi
      \ifNAT@swa\ifcase\NAT@ctype
        \if\relax\NAT@date\relax
          \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}\NAT@date}%
        \else
          \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
              \ifx\NAT@last@yr\NAT@year
                \def\NAT@temp{{?}}%
                \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
                {Multiple citation on page \thepage: same authors and
                year\MessageBreak without distinguishing extra
                letter,\MessageBreak appears as question mark}\fi
                \NAT@hyper@{\NAT@exlab}%
              \else\unskip\NAT@spacechar
                \NAT@hyper@{\NAT@date}%
              \fi
          \else
            \@citea\NAT@hyper@{%
              \NAT@nmfmt{\NAT@nm}%
              \hyper@natlinkbreak{%
                \NAT@aysep\NAT@spacechar}{\@citeb\@extra@b@citeb
              }%
              \NAT@date
            }%
          \fi
        \fi
      \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
      \or\@citea\NAT@hyper@{\NAT@date}%
      \or\@citea\NAT@hyper@{\NAT@alias}%
      \fi \NAT@def@citea
      \else
        \ifcase\NAT@ctype
          \if\relax\NAT@date\relax
            \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
          \else
          \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
              \ifx\NAT@last@yr\NAT@year
                \def\NAT@temp{{?}}%
                \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
                {Multiple citation on page \thepage: same authors and
                year\MessageBreak without distinguishing extra
                letter,\MessageBreak appears as question mark}\fi
                \NAT@hyper@{\NAT@exlab}%
              \else
                \unskip\NAT@spacechar
                \NAT@hyper@{\NAT@date}%
              \fi
          \else
            \@citea\NAT@hyper@{%
              \NAT@nmfmt{\NAT@nm}%
              \hyper@natlinkbreak{\NAT@spacechar\NAT@@open\if*#1*\else#1\NAT@spacechar\fi}%
                {\@citeb\@extra@b@citeb}%
              \NAT@date
            }%
          \fi
          \fi
        \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
        \or\@citea\NAT@hyper@{\NAT@date}%
        \or\@citea\NAT@hyper@{\NAT@alias}%
        \fi
        \if\relax\NAT@date\relax
          \NAT@def@citea
        \else
          \NAT@def@citea@close
        \fi
      \fi
      }}\ifNAT@swa\else
        % 将 author-year 式 \cs{citet} 引用的页码置于括号外并改为上标。
        %
        % \if*#2*\else\NAT@cmt#2\fi
        \if\relax\NAT@date\relax\else\NAT@@close\fi
        \if*#2*\else\textsuperscript{#2}\fi
      \fi}{#1}{#2}}
  %
  % 为了将参考文献加入目录和 pdf 书签，重新定义 \pkg{natbib} 的 \cmd{bibsection}
  % 另外如果调用了 \pkg{chapterbib} 或者使用了 \opt{sectionbib} 参数，
  % 需要使用节标题 \cs{section}。
  \newcommand\hfut@bib@chapter{%
    \@mainmatterfalse
    \ifhfut@degree@bachelor
      \ctexset{
        chapter/format = {
          \centering\fontsize{16bp}{22bp}\sffamily\bfseries\selectfont
        },
        chapter/beforeskip  = 11bp,
        chapter/afterskip   = 11bp,
      }
    \fi
    \chapter{\bibname}%
  }%
  \newcommand\hfut@bib@section{%
    \begingroup
      \ctexset{section/numbering=false}%
      \section{\bibname}%
    \endgroup
  }%
  \@ifpackagewith{chapterbib}{sectionbib}{%
    \hfut@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
  }{}%
  \@ifpackageloaded{chapterbib}{%
    \let\bibsection\hfut@bib@section
  }{%
    \@ifxundefined\NAT@sectionbib{%
      \let\bibsection\hfut@bib@chapter
    }{%
      \let\bibsection\hfut@bib@section
    }%
  }%
  %
  % 参考文献列表格式：宋体 10.5 磅，行距 20 磅，续行缩进2.5字符，左对齐。
  \renewcommand\bibfont{%
    \fontsize{10.5bp}{20bp}\selectfont
  }
  \setlength{\bibsep}{0\p@ \@plus.2\p@}
  \renewcommand\@biblabel[1]{[#1]\hfill}
  \setlength{\bibhang}{2.5\ccwd}
}


% biblatex 宏包的配置

\AtEndOfPackageFile*{biblatex}{
  \AtBeginDocument{
    \ifthenelse{\equal{\blx@bbxfile}{apa}}{\def\bibname{REFERENCES}}{}
    \ifthenelse{\equal{\blx@bbxfile}{apa6}}{\def\bibname{REFERENCES}}{}
    \ifthenelse{\equal{\blx@bbxfile}{mla}}{\def\bibname{WORKS CITED}}{}
    \ifthenelse{\equal{\blx@bbxfile}{mla-new}}{\def\bibname{WORKS CITED}}{}
  }
  \DeclareRobustCommand\inlinecite{\parencite}
  \defbibheading{bibliography}[\bibname]{%
    \@mainmatterfalse
    \chapter{\bibname}%
  }
  \renewcommand\bibfont{%
    \fontsize{10.5bp}{20bp}\selectfont
  }
  \setlength{\bibitemsep}{0\p@ \@plus.2\p@}
  \setlength{\bibhang}{2.5\ccwd}
}

% \subsection{附录}

% 定义了一个满足要求的致谢环境：
\newenvironment{acknowledgements}{%
  \@mainmatterfalse
  \ifhfut@degree@graduate
    \hfut@chapter[致谢]{\hfut@acknowledgements@name}%
  \else
    \chapter{致谢}%
  \fi
}{}


% 兼容旧版本中“acknowledgments”的拼法。
% Reserved for compatibility until 2020-07-01.
\newenvironment{acknowledgments}{%
  \begin{acknowledgements}%
}{%
  \end{acknowledgements}%
}

% TODO 发表成果环境格式：
\newenvironment{publications}{%
  \@mainmatterfalse
  \ctexset{
    chapter/format = \centering\sffamily\bfseries\fontsize{18bp}{18bp}\selectfont,
    chapter/beforeskip  = 9bp,
    chapter/afterskip   = 27bp,
    section/name = {,）},
    section/nameformat = {},
    section/aftername = {},
    section/format = \sffamily\bfseries\fontsize{12bp}{20bp}\selectfont\bfseries,
    section/beforeskip  = 10bp,
    section/afterskip   = 10bp,
  }
  \chapter{\hfut@publication@name}%
  \renewcommand\thesection{\arabic{section}}
  \setenumerate[1]{itemsep = 0pt, parsep = 0pt, label = （\arabic*）}
  \setcounter{tocdepth}{0}
  \setcounter{section}{0}
}{}


% \subsection{其他宏包的设置}

% 这些宏包并非格式要求，但是为了方便同学们使用，在这里进行简单设置。


% \subsubsection{\pkg{hyperref} 宏包}

\AtEndOfPackageFile*{hyperref}{
  \hypersetup{
    bookmarksnumbered  = true,
    bookmarksopen      = true,
    bookmarksopenlevel = 1,
    linktoc            = all,
    unicode            = true,
    psdextra           = true,
  }
  %
  % 如果为 \opt{pdf} 样式，设置 hyperlink 颜色
  \ifhfut@output@electronic
    \hypersetup{
      colorlinks = true,
      allcolors  = red,
    }
  \else
    \hypersetup{hidelinks}
  \fi
  %
  % 填写 PDF 元信息。
  \AtBeginDocument{%
    \ifhfut@main@language@chinese
      \hypersetup{
        pdftitle  = \hfut@title,
        pdfauthor = \hfut@author,
      }%
    \else
      \hypersetup{
        pdftitle  = \hfut@title@en,
        pdfauthor = \hfut@author@en,
      }%
    \fi
  }
  %
  % 添加 PDF 书签
  %
  \newcounter{hfut@bookmarknumber}
  \renewcommand\hfut@pdfbookmark[1]{%
    \phantomsection
    \stepcounter{hfut@bookmarknumber}%
    \pdfbookmark[0]{#1}{hfutchapter.\thehfut@bookmarknumber}%
  }
  %
  % 在 PDF 字符串中去掉换行，以减少 \pkg{hyperref} 的警告信息。
  \pdfstringdefDisableCommands{
    \let\\\@empty
    \let\hspace\@gobble
  }
  %
  % \pkg{hyperref} 与 \pkg{unicode-math} 存在一些兼容性问题，见
  % \href{https://github.com/ustctug/ustcthesis/issues/223}{%
  %   ustctug/ustcthesis\#223}，
  % \href{https://github.com/ho-tex/hyperref/pull/90}{ho-tex/hyperref\#90} 和
  % \href{https://github.com/ustctug/ustcthesis/issues/235}{%
  %   ustctug/ustcthesis/\#235}。
  \@ifpackagelater{hyperref}{2019/04/27}{}{%
    \g@addto@macro\psdmapshortnames{\let\mu\textmu}%
  }
  %
  % 设置中文的 \cs{autoref}。
  % \footnote{\url{https://tex.stackexchange.com/a/66150/82731}}
  \ifhfut@language@chinese
    \def\equationautorefname~#1\null{公式~(#1)\null}
    \def\footnoteautorefname{脚注}
    \def\itemautorefname~#1\null{第~#1~项\null}
    \def\figureautorefname{图}
    \def\tableautorefname{表}
    \def\partautorefname~#1\null{第~#1~部分\null}
    \def\appendixautorefname{附录}
    \def\chapterautorefname~#1\null{第~#1~章\null}
    \def\sectionautorefname~#1\null{第~#1~节\null}
    \def\subsectionautorefname~#1\null{第~#1~小节\null}
    \def\subsubsectionautorefname~#1\null{第~#1~小小节\null}
    \def\paragraphautorefname~#1\null{第~#1~段\null}
    \def\subparagraphautorefname~#1\null{第~#1~小段\null}
    \def\theoremautorefname{定理}
    \def\HyRef@autopageref#1{\hyperref[{#1}]{第~\pageref*{#1} 页}}
  \fi
}


% \subsubsection{\pkg{amsthm} 宏包}

\AtEndOfPackageFile*{amsthm}{
  \newtheoremstyle{hfutplain}
    {}{}
    {}{2\ccwd}
    {\bfseries}{}
    {\ccwd}{}
  \theoremstyle{hfutplain}
  % 定义新的定理
  \ifhfut@language@chinese
    \newcommand\hfut@assertion@name{断言}
    \newcommand\hfut@assumption@name{假设}
    \newcommand\hfut@axiom@name{公理}
    \newcommand\hfut@corollary@name{推论}
    \newcommand\hfut@definition@name{定义}
    \newcommand\hfut@example@name{例}
    \newcommand\hfut@lemma@name{引理}
    \newcommand\hfut@proof@name{证明}
    \newcommand\hfut@proposition@name{命题}
    \newcommand\hfut@remark@name{注}
    \newcommand\hfut@theorem@name{定理}
  \else
    \newcommand\hfut@assertion@name{Assertion}
    \newcommand\hfut@assumption@name{Assumption}
    \newcommand\hfut@axiom@name{Axiom}
    \newcommand\hfut@corollary@name{Corollary}
    \newcommand\hfut@definition@name{Definition}
    \newcommand\hfut@example@name{Example}
    \newcommand\hfut@lemma@name{Lemma}
    \newcommand\hfut@proof@name{Proof}
    \newcommand\hfut@proposition@name{Proposition}
    \newcommand\hfut@remark@name{Remark}
    \newcommand\hfut@theorem@name{Theorem}
  \fi
  \newtheorem{theorem}             {\hfut@theorem@name}    [chapter]
  \newtheorem{assertion}  [theorem]{\hfut@assertion@name}
  \newtheorem{axiom}      [theorem]{\hfut@axiom@name}
  \newtheorem{corollary}  [theorem]{\hfut@corollary@name}
  \newtheorem{lemma}      [theorem]{\hfut@lemma@name}
  \newtheorem{proposition}[theorem]{\hfut@proposition@name}
  \newtheorem{assumption}          {\hfut@assumption@name} [chapter]
  \newtheorem{definition}          {\hfut@definition@name} [chapter]
  \newtheorem{example}             {\hfut@example@name}    [chapter]
  \newtheorem*{remark}             {\hfut@remark@name}
  % \pkg{amsthm} 单独定义了 proof 环境，这里重新定义以满足格式要求。
  % 原本模仿 \pkg{amsthm} 写成 |\item[\hskip\labelsep\hskip2\ccwd #1\hskip\ccwd]|，
  % 但是却会多出一些间隙。
  \renewenvironment{proof}[1][\hfut@proof@name]{\par
    \pushQED{\qed}%
    \normalfont \topsep6\p@\@plus6\p@\relax
    \trivlist
      \item\relax\hskip2\ccwd
      \textbf{#1}
      \hskip\ccwd\ignorespaces
    }{%
    \popQED\endtrivlist\@endpefalse
  }
  \renewcommand\qedsymbol{\hfut@qed}
}


% \subsubsection{\pkg{algorithm2e} 宏包}

% 按章节编号。
\PassOptionsToPackage{algochapter}{algorithm2e}

\AtEndOfPackageFile*{algorithm2e}{
  \ifhfut@language@chinese
    \SetAlgorithmName{算法}{算法}{算法清单}
  \else
    \SetAlgorithmName{Algorithm}{Algorithm}{List of Algorithms}
  \fi
  %
  % 设置算法环境的格式。
  \SetAlCapSkip{6bp}
  \SetAlCapFnt{\small}
  \SetAlCapNameFnt{\small}
  \ifhfut@degree@graduate
    \SetAlCapNameSty{textbf}
  \fi
  \SetAlgoCaptionSeparator{\unskip\hspace*{\ccwd}}
  %
  % 设置算法清单的格式
  \renewcommand\listofalgocfs{%
    \ifhfut@degree@graduate
      \cleardoublepage
    \fi
    \hfut@chapter{\listalgorithmcfname}%
    \@starttoc{loa}%
  }
  \titlecontents{algocf}
    [2.3em]{\normalsize}
    {\contentslabel{2.3em}}{}
    {\hfut@leaders\contentspage}
  \contentsuse{algocf}{loa}
}


% \subsubsection{\pkg{nomencl} 宏包}

\AtEndOfPackageFile*{nomencl}{
  \let\nomname\hfut@notation@name
  \def\thenomenclature{%
    \ifhfut@degree@graduate
      \cleardoublepage
      \pagestyle{headings}%
    \fi
    \hfut@chapter{\hfut@notation@name}%
    \nompreamble
    \list{}{%
      \labelwidth\nom@tempdim
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemsep\nomitemsep
      \let\makelabel\nomlabel}}
  \def\endthenomenclature{%
    \endlist
    \nompostamble
    \ifhfut@degree@graduate
      \clearpage
      \pagestyle{plain}%
    \fi
  }
}


% \subsubsection{\pkg{siunitx} 宏包}

\AtEndOfPackageFile*{siunitx}{
  \sisetup{
    group-minimum-digits = 4,
    separate-uncertainty = true,
    inter-unit-product   = \ensuremath{{}\cdot{}},
  }
  \newcommand\hfut@set@siunitx@language{%
  \ifhfut@language@chinese
    \sisetup{
      list-final-separator = { 和 },
      list-pair-separator  = { 和 },
      range-phrase         = {～},
        }%
      \else
        \sisetup{
          list-final-separator = {, and },
          list-pair-separator  = { and },
          range-phrase         = { to },
        }%
  \fi
  }
  \hfut@set@siunitx@language
  \hfut@option@hook{language}{\hfut@set@siunitx@language}
}

% \subsubsection{\pkg{chapterbib} 宏包}

\AtEndOfPackageFile*{chapterbib}{
  \@ifpackageloaded{natbib}{%
    \@ifpackagewith{chapterbib}{sectionbib}{%
      \hfut@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
    }{}%
    \renewcommand\bibsection{%
      \begingroup
        \ctexset{section/numbering=false}%
        \section{\bibname}%
      \endgroup
    }
  }{}
}
