use strict;
use warnings;
use diagnostics;
use Data::Dumper;
use File::Basename;
# include local module
use FindBin qw($Bin);
use lib "$Bin/perl5/lib/perl5";
use lib "$Bin/perl5/lib/perl5/x86_64-linux-gnu-thread-multi";
use Getopt::Long;
use Spreadsheet::Read;
use Template;
use lib "$Bin";
use Register;

# get arguments
my %args;
GetOptions(\%args,
           "input=s",
           "output=s"
) or die "Usage ./script.pl --input input.xls(x)";

# mandotary check
die "Missing --input!" unless $args{input};

# check input file  exist
my $input = $args{input};
if ( !-e $input) {
    die "File not exist!";
}
my @error;
# remove extension for register file name
my $basename = basename($input);
(my $registerFileName = $basename) =~ s/\.[^.]+$//;
#if is not valid
unless (validate($registerFileName, 'name')) {
    $registerFileName = "register_File";
    push @error, "register file name error";
}

# Read input File
my $book  = ReadData($input);
my @rows = Spreadsheet::Read::rows ($book->[1]);
# first 6 row is unnecessary
splice @rows, 0, 6;

# calculate base address for registers' offset
#my $address = $book->[1]->{cell}->[2];
#my $baseAddress = min(grep { defined && $_ =~ /^(\d)+$/ } @$address);
# hardcoded since dialog wants like that
my $baseAddress = 0;

my (@registers, $register, $i);
$i = 7;
foreach my $row (@rows) {
    # if first col is empty, it's a field, otherwise register
    if ($row->[0]) {
        # excel column format
        # 0     1       2       3       4       5
        # name  address                         description
        if($register) {
            #push if we create new register
            push @registers, $register->deref();
        }
        validate_register($row);
        $register = new Register(
            $row->[0],
            $row->[5],
            $row->[1] - $baseAddress
        );
    } else {
        # excel column format
        # 0     1       2        3       4       5
        #       name    range    reset   access  description
        # range format [end:start]
        validate_field($row);
        my ($offset, $width) = Register::parse_range($row->[2]);
        $register->add_field(
            $row->[1],
            $row->[5],
            $offset,
            $width,
            $row->[3],
            $row->[4]
        );
    }
    $i++;
}
push @registers, $register->deref();

# run template and generate xml
my $tt = Template->new({
    ABSOLUTE => 1
});

my $templateData = {
    name => $registerFileName,
    addressOffset => $baseAddress,
    range => scalar @registers,
    registers => \@registers
};

my $size = scalar(@error);
if ($size > 0) {
    print "<errors>\n";
    foreach my $err (@error) {
        print "\t<error>$err</error>\n";
    }
    print "</errors>";
} else {
    if ($args{output}) {
        $tt->process("$Bin/ipxact_template.tt", $templateData, $args{output}) || die $tt->error;
        print "saved to $args{output}\n";
    } else {
        my $xml = $tt->process("$Bin/ipxact_template.tt", $templateData) || die $tt->error;
    }
}


sub validate_register {
    my ($row) = @_;
    unless (validate($row->[0], 'name')) {
        push @error, "register name is not valid at $i";
    }
    unless (validate($row->[1], 'number')) {
        push @error, "register adress is not valid at $i";
    }
}

sub validate_field {
    my ($row) = @_;
    unless (validate($row->[1], 'name')) {
        push @error, "field name is not valid at $i";
    }
    if ($row->[3]) {
        unless (validate($row->[3], 'number')) {
            push @error, "field reset is not valid at $i";
        }
    }
}

sub validate {
    my ($value, $type) = @_;
    if (defined $type) {
        $type = lc($type);
        if ($type eq "name") {
            return $value =~ /^[a-zA-Z_:]([a-zA-Z0-9_:.])*$/;
        } elsif ($type eq "number") {
            return $value =~ /^([+]?(0x)?[0]*[0-9a-f]+[kmgt]?)$/i;
        }
    }
}