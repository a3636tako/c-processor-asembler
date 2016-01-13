#!/usr/bin/perl
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
	"DC"  =>    {OP => 0x00, OPR => 1},
	"LDSP" =>   {OP => 0xda, OPR => 2},
	"LDBR" =>   {OP => 0xfb, OPR => 0},
	"LDXA" =>   {OP => 0xe2, OPR => 0},
	"LDXB" =>   {OP => 0xe3, OPR => 0},
	"STXA" =>   {OP => 0xf1, OPR => 0},
	"STXB" =>   {OP => 0xf5, OPR => 0},
	"PUSHA" =>  {OP => 0x10, OPR => 0},
	"PUSHB" =>  {OP => 0x11, OPR => 0},
	"PUSHBR" => {OP => 0x12, OPR => 0},
	"CALL" =>   {OP => 0x13, OPR => 2},
	"POPA" =>   {OP => 0x18, OPR => 0},
	"POPB" =>   {OP => 0x19, OPR => 0},
	"POPBR" =>  {OP => 0x1a, OPR => 0},
	"RET" =>    {OP => 0x1b, OPR => 0},
);

my %OPTION = (
	"type" => "memory",

	"o" => "memory.txt"
);



#
# START
#

parse_args(\%OPTION);

if($#ARGV == -1){
	print STDERR "Usage : perl cpa.pl [option] source\n";
	exit(-2);
}

my $filename = $ARGV[0];
my $outputfile = $OPTION{"o"};

my @memory;
my @memoryComment;
my %memLabelH;
my %memLabelL;
my %labelHash;

parse_source();

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

output_rom();

sub parse_args{
	my $args = shift;
	while($#ARGV >= 0){
		if($ARGV[0] =~ /-(.+)/){
			shift @ARGV;
			$$args{$1} = shift @ARGV;
		}else{
			last;
		}
	}
}

sub parse_source{
	open my $fh, '<', $filename or die "$filename : $!";
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
}

sub output_memory{

	open my $out, ">", $outputfile or die "$outputfile : $!";

	for(my $i = 0; $i <= $#memory; $i++){
		printf $out "%04x\t%02x", $i, $memory[$i];
		if($memoryComment[$i] ne ""){
			print $out "\t--$memoryComment[$i]";
		}
		print $out "\n";
	}

	close $out;


}


sub output_rom{
	open my $out, ">", $outputfile or die "$outputfile : $!";
	print $out <<'OUTPUT';
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ROM is
  port(
    address : in std_logic_vector(15 downto 0);
    read    : in std_logic;
    cs      : in std_logic;
    reset   : in std_logic;
    data    : out std_logic_vector(7 downto 0)
  );
end;

architecture RTL of ROM is
  type rom_type is array (0 to 1023) of std_logic_vector (7 downto 0); 
  signal ROM : rom_type; 

  constant CODE : rom_type := (
OUTPUT
	for(my $i = 0; $i < 1023; $i++){
		my $val = exists $memory[$i] ? $memory[$i] : 0;
		printf $out "x\"%02x\", ", $val;
		if(($i + 1) % 16 == 0){
			print $out "\n";
		}
	}
	my $val = exists $memory[1023] ? $memory[1023] : 0;
	printf $out "x\"%02x\"  ", $val;
	print $out "\n";

print $out <<'OUTPUT';
  );

begin
  process(reset) begin
    if(reset = '0') then
      ROM <= CODE;
    end if;
  end process;

  process(read, cs, address) begin
    if(read = '0' and cs = '0') then
      data <= ROM( CONV_INTEGER(address) );
    end if;
  end process;
end RTL;
OUTPUT
	close $out;
}
