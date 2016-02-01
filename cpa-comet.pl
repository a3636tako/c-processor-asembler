#!/usr/bin/perl
use strict;
use warnings;
use utf8;

#
# C-Processor-Asembler
#

my %OPCODE = ( 
	"NOP"    =>   {OP => 0x00, R => 0, XR => 0, ADR => 0, R_LIST=>[[],[],[],[],[]], W_LIST=>[[],[],[],[],[]]},
	"LD"     =>   {OP => 0x10, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["ADR"],[],[]], W_LIST=>[[],[],[],[],["R"]]},
	"ST"     =>   {OP => 0x11, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R"],[],[]], W_LIST=>[[],[],[],[],["ADR"]]},
	"LEA"    =>   {OP => 0x12, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],[],[],[]], W_LIST=>[[],[],[],["FR"],["R"]]},
	"ADD"    =>   {OP => 0x20, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R", "ADR"],[],[]], W_LIST=>[[],[],[],["FR"],["R"]]},
	"SUB"    =>   {OP => 0x21, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R", "ADR"],[],[]], W_LIST=>[[],[],[],["FR"],["R"]]},
	"ADDADR" =>   {OP => 0x22, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R"],[],[]], W_LIST=>[[],[],[],[],["R"]]},
	"SUBADR" =>   {OP => 0x23, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R"],[],[]], W_LIST=>[[],[],[],[],["R"]]},
	"AND"    =>   {OP => 0x30, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R", "ADR"],[],[]], W_LIST=>[[],[],[],["FR"],["R"]]},
	"OR"     =>   {OP => 0x31, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R", "ADR"],[],[]], W_LIST=>[[],[],[],["FR"],["R"]]},
	"EOR"    =>   {OP => 0x32, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R", "ADR"],[],[]], W_LIST=>[[],[],[],["FR"],["R"]]},
	"CPA"    =>   {OP => 0x40, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R", "ADR"],[],[]], W_LIST=>[[],[],[],["FR"],[]]},
	"CPL"    =>   {OP => 0x41, R => 1, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["R", "ADR"],[],[]], W_LIST=>[[],[],[],["FR"],[]]},
	"JPZ"    =>   {OP => 0x60, R => 0, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["FR"],[],[]], W_LIST=>[[],[],[],[],["PC"]]},
	"JMI"    =>   {OP => 0x61, R => 0, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["FR"],[],[]], W_LIST=>[[],[],[],[],["PC"]]},
	"JNZ"    =>   {OP => 0x62, R => 0, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["FR"],[],[]], W_LIST=>[[],[],[],[],["PC"]]},
	"JZE"    =>   {OP => 0x63, R => 0, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],["FR"],[],[]], W_LIST=>[[],[],[],[],["PC"]]},
	"JMP"    =>   {OP => 0x64, R => 0, XR => 1, ADR => 1, R_LIST=>[["PC"],["XR"],[],[],[]], W_LIST=>[[],[],[],[],["PC"]]},
);

my %OPTION = (
	"type" => "memory",

	"o" => "Rom.vhd"
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
my %memLabel;
my %labelHash;

parse_source();
#for (@memory){
#	printf "%08x\n", $_;
#}

foreach my $key (keys %memLabel){
	my $l = $memLabel{$key};
	if(!exists $labelHash{$l}){
		printf STDERR "Undefined Label : \"$l\"\n";
		exit(-1);
	}
	$memory[$key] = ($memory[$key] & 0xffff0000) | $labelHash{$l};
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
	my @depend;

	while(my $line = <$fh>){
		$linenum++;
		chomp($line);
		#コメントを削除
		$line =~ s/;.*$//;
		#先頭の空白を削除
		$line =~ s/^\s*//;
		
		next if(!length $line);
		
		my $llflg = 0;
		my @terms = split /\s+/, $line;
		my ($label, $op, $opr);
		$op = shift @terms;

		if(!exists $OPCODE{$op}){
			#先頭が命令でなければラベルとみなす
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
				$llflg = 1;
			}
		}

		my $ophash = $OPCODE{$op};
		my @oprand = split /,/, join("", @terms);
		my ($opr_r, $opr_adr, $opr_xr, $label_flg) = (0, 0, 0, 0);
		if($ophash->{R}){
			my $head = shift @oprand;
			if(!($head =~ /GR(\d+)/)){
				printf STDERR "Line $linenum : invalid gr : $head \n";
				exit(-1);
			}
			$opr_r = $1;
			if($opr_r >= 16){
				printf STDERR "Line $linenum : over gr : $head \n";
				exit(-1);
			}
		}

		if($ophash->{ADR}){
			my $head = shift @oprand;
			if($head =~ /^\d+$/){
				$opr_adr = $1;	
			}elsif($head =~ /^0x([0-9a-fA-F]+)/){
				$opr_adr = hex($1);
			}elsif($head =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/){
				$opr_adr = $head;
				$label_flg = 1;
			}else{
				printf STDERR "Line $linenum : Invalid operand \"$head\"\n";
				exit(-1);
			}
		}

		if($ophash->{XR}){
			if($#oprand == -1){
				$opr_xr = 0;
			}else{
				my $head = shift @oprand;
				if(!($head =~ /GR(\d+)/)){
					printf STDERR "Line $linenum : invalid xr : $head \n";
					exit(-1);
				}
			
				$opr_xr = $1;
				if($opr_r >= 16 || $opr_xr <= 0){
					printf STDERR "Line $linenum : over gr : $head \n";
					exit(-1);
				}
			}
		}

		my $rlist = $ophash->{R_LIST};
		my $wlist = $ophash->{W_LIST};
		my $conflg = 1;
		LOOP:while($conflg){
			my $idx = $#memory + 1;
			for(my $i = 0; $i < 5; $i++){
				for(my $j = $i; $j < 5; $j++){
					if(intersection($rlist->[$i], $depend[$idx + $j], $opr_r, $opr_xr, $opr_adr)){
						push @memory, 0;
						push @memoryComment, "NOP";
						next LOOP;
					}
				}
			}
			$conflg = 0;
		}
		{
			my $idx = $#memory + 1;
			for(my $i = 0; $i < 5; $i++, $idx++){
				push @{$depend[$idx]}, @{$wlist->[$i]};
			}
		}

		$labelHash{$label} = $#memory + 1 if ($llflg);

		my $inst = $ophash->{OP} << 24;
		$inst = $inst | ($opr_r << 20);
		$inst = $inst | ($opr_xr << 16);
		$inst = $inst | ($opr_adr & 0xffff) if(!$label_flg);

		$memLabel{$#memory + 1} = $opr_adr if($label_flg);

		push @memory, $inst;
		push @memoryComment, "$op\tGR$opr_r,\t$opr_adr,\tGR$opr_xr";
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

entity CometPROM is
  port(
    reset   : in std_logic;
    address : in std_logic_vector(15 downto 0);
    data    : out std_logic_vector(31 downto 0)
  );
end;

architecture RTL of CometPROM is
  type rom_type is array (0 to 1023) of std_logic_vector (31 downto 0); 
  signal ROM : rom_type; 

  constant CODE : rom_type := (
OUTPUT
	for(my $i = 0; $i < 1023; $i++){
		my $val = exists $memory[$i] ? $memory[$i] : 0;
		printf $out "x\"%08x\", ", $val;
		if(($i + 1) % 8 == 0){
			print $out "\n";
		}
	}
	my $val = exists $memory[1023] ? $memory[1023] : 0;
	printf $out "x\"%08x\"  ", $val;
	print $out "\n";

print $out <<'OUTPUT';
  );

begin
  process(reset) begin
    if (reset = '0') then 
      ROM <= CODE;
    end if;
  end process;

  process(address) begin
     data <= ROM( CONV_INTEGER(address) );
  end process;

end RTL;
OUTPUT

	close $out;
}

sub intersection {
	my ($arr1, $arr2, $r, $xr, $adr) = @_;
	foreach my $a (@{$arr1}){
		my $cmp;
		if($a eq "R"){
			$cmp = $r."R";
		}elsif($a eq "XR"){
			next if($xr == 0);
			$cmp = $xr."R";
		}

		foreach my $b (@{$arr2}){
			if($a eq $b){
				return 1;
			}
		}
	}
	return 0;
}
