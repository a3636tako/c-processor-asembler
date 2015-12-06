# c-processor-asembler

情報科学実験C C-Processor用アセンブラです

## 使い方
perl cpa.pl source [output]

outputを省略するとmemory.txtという名前のファイルに出力します。

## 文法
行ごとに

ラベル 命令 オペランド

という形で記述します。(ラベルとオペランドは省略できる)

ラベルは命令に存在せず、先頭が英数字でない語が使えます。
オペランドにはラベル、10進非負整数、16進非負整数が指定できます。

ラベルを指定した場合、そのラベルがつけられている場所のアドレスとなります。（SETIXHの場合上位8ビット、JP、JPC、JPZの場合16ビット、その他の場合下位8ビット）

先頭に0xをつけた数値は16進数、そうでないものは10進数として解釈されます。

C-Proccessorで使える命令の他にDC(Define Constant)命令が使えます。


## 例
アセンブリプログラムの例

```
	SETIXH	L1  
	SETIXL	L1  
	LDDA  
	LDIB	0x10  
	ADDA  
	SETIXL	L2  
	STDA	
L1	DC	10
L2	DC	0
```

プログラムの出力結果

```
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
```

