# c-processor-asembler

$B>pJs2J3X<B83(BC C-Processor$BMQ%"%;%s%V%i$G$9(B

## $B;H$$J}(B
perl cpa.pl source [output]

output$B$r>JN,$9$k$H(Bmemory.txt$B$H$$$&L>A0$N%U%!%$%k$K=PNO$7$^$9!#(B

## $BJ8K!(B
$B9T$4$H$K(B

$B%i%Y%k(B $BL?Na(B $B%*%Z%i%s%I(B

$B$H$$$&7A$G5-=R$7$^$9!#(B($B%i%Y%k$H%*%Z%i%s%I$O>JN,$G$-$k(B)

$B%i%Y%k$OL?Na$KB8:_$;$:!"@hF,$,1Q?t;z$G$J$$8l$,;H$($^$9!#(B
$B%*%Z%i%s%I$K$O%i%Y%k!"(B10$B?JHsIi@0?t!"(B16$B?JHsIi@0?t$,;XDj$G$-$^$9!#(B

$B%i%Y%k$r;XDj$7$?>l9g!"$=$N%i%Y%k$,$D$1$i$l$F$$$k>l=j$N%"%I%l%9$H$J$j$^$9!#!J(BSETIXH$B$N>l9g>e0L(B8$B%S%C%H!"(BJP$B!"(BJPC$B!"(BJPZ$B$N>l9g(B16$B%S%C%H!"$=$NB>$N>l9g2<0L(B8$B%S%C%H!K(B

$B@hF,$K(B0x$B$r$D$1$??tCM$O(B16$B?J?t!"$=$&$G$J$$$b$N$O(B10$B?J?t$H$7$F2r<a$5$l$^$9!#(B

C-Proccessor$B$G;H$($kL?Na$NB>$K(BDC(Define Constant)$BL?Na$,;H$($^$9!#(B


## $BNc(B
$B%"%;%s%V%j%W%m%0%i%`$NNc(B
	SETIXH	L1
	SETIXL	L1
	LDDA
	LDIB	0x10
	ADDA
	SETIXL	L2
	STDA	
L1	DC	10
L2	DC	0

$B%W%m%0%i%`$N=PNO7k2L(B
0000	d0	--SETIXH
0001	00
0002	d1	--SETIXL
0003	0b
0004	e0	--LDDA
0005	d9	--LDIB
0006	10
0007	80	--ADDA
0008	d1	--SETIXL
0009	0c
000a	f0	--STDA
000b	0a
000c	00


