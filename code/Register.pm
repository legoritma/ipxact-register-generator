package Register;
use List::Util qw(min);

sub new {
    my $class = shift;
    my ($name, $desc, $offset) = @_;
    my $self = {
        name => $name,
        desc => $desc,
        offset => $offset,
        size => 0,
        reset => 0,
        fields => [],
    };
    bless $self, $class;
    return $self;
}

sub add_field {
    my $self = shift;
    my ($name, $desc, $offset, $width, $reset, $access) = @_;
    my $field = {
        name => $name,
        desc => $desc,
        offset => $offset,
        width => $width,,
        access => access_type($access)
    };
    $self->update_reset(normalize_reset($reset), $offset);
    $self->update_size($width);
    push @{$self->{fields}}, $field;
}

sub update_reset {
    my $self = shift;
    my ($reset, $offset) = @_;
    # if not defined accept it's all zero
    if(defined $reset && $reset ne "") {
        $self->{reset} += ($reset * (2 ** $offset));
    }
}

sub update_size {
    my $self = shift;
    $self->{size} += shift;
}

sub deref {
    my $self = shift;
    my %uhash = %$self;
    return \%uhash;
}

#static funtions
sub access_type {
    my $type = shift;
    if (defined $type) {
        $type = uc($type);
        if ($type eq "RW") {return "read-write";}
        elsif ($type eq "R") {return "read-only";}
        elsif ($type eq "W") {return "write-only";}
        elsif ($type eq "RWO") {return "read-writeOnce";}
        elsif ($type eq "WO") {return "writeOnce";}
    }
    return undef;
}

sub normalize_reset {
    my $value = shift;
    if(defined $value) {
        return ($value =~ /^0x[\da-f]+$/i) ? hex($value) : $value;
    }
    return $value;
}

sub parse_range {
    my (@ranges, $size, $offset, $width);
    @ranges = shift =~ /(\d+)/g;
    $size = scalar(@ranges);
    if ($size == 2) {
        $offset = min(@ranges);
        $width = abs($ranges[0] - $ranges[1]) + 1;
    } else {
        $offset = min(@ranges);
        $width = 1;
    }
    return ($offset, $width);
}

#package included
return 1;