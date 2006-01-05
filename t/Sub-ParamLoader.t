use Test::More tests => 25;
BEGIN { use_ok('Sub::ParamLoader') };

my %B = ('Y'=>1,'N'=>0,'y'=>1,'n'=>0);

sub expect
{
    my ($q,$x,$y,$h,$message)=@_;
    my $subr = $B{$q} ? \&is : \&isnt;
    $subr->($h->{$x},$y,"$message [$x=>$y] ".$q);
}

sub isdef
{
    my ($q,$x,$h,$message)=@_;
    ok ($B{$q}? exists $h->{$x} : ! exists $h->{$x}, "$message [$x] ".$q);
}

    my %DW2Dic =  #-------------- Abbreviations mapping ------------#
    qw(su sunday mo monday tu tuesday we wednesday th thursday fr friday sa saturday);

    my $pl = Sub::ParamLoader->new #============== RULE ============#
    (             #------------------ KEYMASK--'M'------------------#
        'M' =>    # match any prefix-string of a week-day-name with legth
        sub       # not less than 2, ignoring case of characters
        {
            my $ik = shift;
            my $ikl = lc $ik;
            my $ikl2 = substr $ikl,0,2;
            my $res = $DW2Dic{$ikl2};
            return undef unless
            ( defined $res)  && ($ikl eq substr($res,0,length $ikl));
            ucfirst $res;
        },
        'D' => [qw(SUN VII MON I TUE II WED III)] ### DEFAULTS ###
    );

    my $hob = $pl->load qw(We iii Thur iv Fr v  Satur vi Sun vii);
    #        overrides defauts Wednesday,Sunday   #

    {
        my @TEST_EXPECT = qw
        (
            Y Mond I
            Y TUE II
            Y We iii
            Y th  iv
            N Friday5 v
            N saturn vi
            Y sUn    vii
            N MONDY1 I
            Y WEDNES iii
        );
        while ( my @seg = splice @TEST_EXPECT,0,3 )
        {
            expect @seg,$hob,'access';
        }
    }

    {
        my @TEST_EXIST = qw
        (
            Y MONDAY
            N MONDAY1
            N m
            N THI
            Y sun
            N sunrise
            Y frid
            Y friDAY
            N friday5
        );
        while ( my @seg = splice @TEST_EXIST,0,2 )
        {
            isdef @seg,$hob,'exists';
        }
    }