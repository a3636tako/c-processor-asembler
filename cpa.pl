use strict;
use warnings;
use utf8;

#
# C-Processor-Asembler
#

my %OPCODE(
	"SETIXH" => {OP => 0xd0, OPR => 1},
	"SETIXL" => {OP => 0xd1, OPR => 1},
	"LDIA" =>   {OP => 0xd8, OPR => 1},
	"LDIB" =>   {OP => 0xd9, OPR => 1},
	"LDDA" =>   {OP => 0xe0, OPR => 0},
	"LDDB" =>   {OP => 0xe1, OPR => 0},
	"STDA" =>   {OP => 0xf0, OPR => 0},
	"STDB" =>   {OP => 0xf4, OPR => 0},
	"STDI" =>   {OP => 0xf8, OPR => 1},
	"ADDA" =>   {OP => 0x80, OPR => 0},
	"SUBA" =>   {OP => 0x81, OPR => 0},
	"ANDA" =>   {OP => 0x82, OPR => 0},
	"ORA"  =>   {OP => 0x83, OPR => 0},
	"NOTA" =>   {OP => 0x84, OPR => 0},
	"INCA" =>   {OP => 0x85, OPR => 0},
	"DECA" =>   {OP => 0x86, OPR => 0},
	"ADDB" =>   {OP => 0x90, OPR => 0},
	"SUBB" =>   {OP => 0x91, OPR => 0},
	"ANDB" =>   {OP => 0x92, OPR => 0},
	"ORB" =>    {OP => 0x93, OPR => 0},
	"NOTB" =>   {OP => 0x98, OPR => 0},
	"INCB" =>   {OP => 0x99, OPR => 0},
	"DECB" =>   {OP => 0x9a, OPR => 0},
	"CMP" =>    {OP => 0xa1, OPR => 0},
	"NOP" =>    {OP => 0x00, OPR => 0},
	"JP" =>     {OP => 0x60, OPR => 2},
	"JPC" =>    {OP => 0x40, OPR => 2},
	"JPZ" =>    {OP => 0x50, OPR => 2}
);

my $filename = $ARGV[0];

open my $fh, '<', $filename or die "$filename : $!";

my @memory;
my @memoryComment;
my %memLabelH;
my %memLabelL;
my %labelHash;
my $linenum = 0;
while(my $line = <$fh>){
	$linenum++;
	chomp($line);
	#コメントを削除
	$line =~ s/;.*$//;
	#先頭の空白を削除
	$line =~ s/^\s*//;
	
	next if($line = '');
		
	my @terms = split $line;
	my ($label, $op, $opr);
	$op = shift @terms;
	if(!exists $OPCODE{$op}){
		$label = $op;
		if($#terms == -1 || (!exists $OPCOD{$op = shift @terms})){
			print STDERR "Line $linenum : Undefined OPCODE \"$op\"\n";
			exit(-1);
		}


		if($label ~= /^\d+$/){
            #10進数
 
        }elsif($label ~= /^0x[0-9a-fA-F]+/){
            #16進数
 
        }elsif($label ~= /^[a-zA-Z_][a-zA-Z0-9_]*$/){
            #ラベル
            if(exists $labelHash{$label}){
                printf STDERR "Line $linenum : Duplicade Label \"$label\"\n";
                exit(-1);
            }
            $labelHash{$label} = $#memory + 1;
		}

	}

	push @memory, $OPCODE{$op}{OP};
	push @memoryComment, $op;
	if($OPCODE{$OP}{OPR} == 0){
		if($#terms >= 0){
			printf STDERR "Line $linenum : Invalid Operand \"$op\"\n";
			exit(-1);
		}

	}else{
		if($#terms >= 1){
			printf STDERR "Line $linenum : Invalid Operand \"$op\"\n";
			exit(-1);
		}

		my $opr = shift @terms;
		if($opr ~= /^\d+$/){
            #10進数
 
        }elsif($opr ~= /^0x[0-9a-fA-F]+/){
            #16進数
 
        }elsif($opr ~= /^[a-zA-Z_][a-zA-Z0-9_]*$/){
            #ラベル
			$memLabel{$#memory + 1} = $opr;
		}


	}elsif($OPCODE{$OP}{OPR} == 2){
		if($#terms >= 1){
			printf STDERR "Line $linenum : Invalid Operand \"$op\"\n";
			exit(-1);
		}

	}else{
		printf STDERR "Line $linenum : Internal Error\n";
		exit(-1);
	}


}






close my $fh;






