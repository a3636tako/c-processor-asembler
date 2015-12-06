
use strict;
use warnings;
use utf8;

#
# C-Processor-Asembler
#

my %OPCODE = ( 
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
	"JPZ" =>    {OP => 0x50, OPR => 2},
	"DC"  =>    {OP => 0x00, OPR => 1}
);

if($#ARGV == -1){
	print STDERR "Usage : perl cpa.pl source [output]\n";
	exit(-2);
}

my $filename = $ARGV[0];
my $outputfile = "memory.txt";
if($#ARGV >= 1){
	$outputfile = $ARGV[1];
}

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
	
	next if(!length $line);
		
	my @terms = split /\s+/, $line;
	my ($label, $op, $opr);
	$op = shift @terms;
	if(!exists $OPCODE{$op}){
		$label = $op;
		if($#terms == -1 || (!exists $OPCODE{$op = shift @terms})){
			print STDERR "Line $linenum : Undefined OPCODE \"$op\"\n";
			exit(-1);
		}


		if($label =~ /^\d+$/){
            #10進数
 
        }elsif($label =~ /^0x[0-9a-fA-F]+$/){
            #16進数
 
        }elsif($label =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/){
            #ラベル
            if(exists $labelHash{$label}){
                printf STDERR "Line $linenum : Duplicade Label \"$label\"\n";
                exit(-1);
            }
            $labelHash{$label} = $#memory + 1;
		}

	}

	if($op ne "DC"){
		push @memory, $OPCODE{$op}{OP};
		push @memoryComment, $op;
	}

	if($OPCODE{$op}{OPR} == 0){
		if($#terms >= 0){
			printf STDERR "Line $linenum : Invalid Operand \"$op\"\n";
			exit(-1);
		}

	}else{
		if($#terms != 0){
			printf STDERR "Line $linenum : Invalid Operand \"$op\"\n";
			exit(-1);
		}


		my $opr = shift @terms;
		if($opr =~ /^\d+$/){
			if($OPCODE{$op}{OPR} == 1){
				if($opr > 0xff){
					printf STDERR "Line $linenum : Value limit exceeded \"$opr\"\n";
					exit(-1);
				}
				push @memory, $opr;
				push @memoryComment, "";
			}elsif($OPCODE{$op}{OPR} == 2){
				if($opr > 0xffff){
					printf STDERR "Line $linenum : Value limit exceeded \"$opr\"\n";
					exit(-1);
				}
				my $v = $opr >> 8;
				push @memory, $v;
				push @memoryComment, "";
				$v = $opr & 0xff ;
				push @memory, $v;
				push @memoryComment, "";
			}
        }elsif($opr =~ /^0x([0-9a-fA-F]+)/){
			$opr = hex($1);
            #16進数
			if($OPCODE{$op}{OPR} == 1){
				if($opr > 0xff){
					printf STDERR "Line $linenum : Value limit exceeded \"$opr\"\n";
					exit(-1);
				}
				push @memory, $opr;
				push @memoryComment, "";
			}elsif($OPCODE{$op}{OPR} == 2){
				if($opr > 0xffff){
					printf STDERR "Line $linenum : Value limit exceeded \"$opr\"\n";
					exit(-1);
				}
				my $v = $opr >> 8;
				push @memory, $v;
				push @memoryComment, "";
				$v = $opr & 0xff ;
				push @memory, $v;
				push @memoryComment, "";
			}
 
        }elsif($opr =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/){
            #ラベル
			if($op eq 'SETIXH'){
				$memLabelH{$#memory + 1} = $opr;
				push @memory, "";
				push @memoryComment, "";
			}elsif($OPCODE{$op}{OPR} == 1){
				$memLabelL{$#memory + 1} = $opr;
				push @memory, "";
				push @memoryComment, "";
			}elsif($OPCODE{$op}{OPR} == 2){
				$memLabelH{$#memory + 1} = $opr;
				push @memory, "";
				push @memoryComment, "";
				$memLabelL{$#memory + 1} = $opr;
				push @memory, "";
				push @memoryComment, "";

			}else{
				printf STDERR "Line $linenum : Internal Error\n";
				exit(-1);
			}
		}else{
			printf STDERR "Line $linenum : Invalid operand \"$opr\"\n";
			exit(-1);
		}
	}
}

close $fh;

foreach my $key (keys %memLabelH){
	my $l = $memLabelH{$key};
	if(!exists $labelHash{$l}){
		printf STDERR "Undefined Label : \"$l\"\n";
		exit(-1);
	}
	$memory[$key] = ($labelHash{$l} >> 8) & 0xff;
}

foreach my $key (keys %memLabelL){
	my $l = $memLabelL{$key};
	if(!exists $labelHash{$l}){
		printf STDERR "Undefined Label : \"$l\"\n";
		exit(-1);
	}
	$memory[$key] = $labelHash{$l} & 0xff;
}

open my $out, ">", $outputfile or die "$outputfile : $!";

for(my $i = 0; $i <= $#memory; $i++){
	printf $out "%04x\t%02x", $i, $memory[$i];
	if($memoryComment[$i] ne ""){
		print $out "\t--$memoryComment[$i]";
	}
	print $out "\n";
}

close $out;


