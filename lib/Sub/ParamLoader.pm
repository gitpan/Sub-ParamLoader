package Sub::ParamLoader;

use 5.008007;
our $VERSION = 0.01;
use strict;
no strict 'subs';
use Tie::Hash::KeysMask;

sub new
{
    sub splitmask
    {
        my $mask = shift;
        $mask ? (ref($mask) eq 'ARRY' ? @$mask : ($mask)) : ();
    };

    my $class = shift;
    my %arg = @_;
    my $defo = exists $arg{'D'} ? delete $arg{'D'} : [];

    my @M = exists $arg{'M'} ? splitmask delete $arg{'M'} : ();
    bless [[@$defo],[@M]],$class;
}

sub load
{
    my $self = shift;
    my $hr = @{$self->[1]} ? Tie::Hash::KeysMask->newHASH (@{$self->[1]}) : {};
    %$hr = (@{$self->[0]},@_);
    $hr;
}

1;

__END__

=head1 NAME

Sub::ParamLoader
- Map named argument list into a hash modified according to a rule

=head1 SYNOPSIS

    use Sub::ParamLoader;
    my $pl = Sub::ParamLoader -> new ('D'=>[...],'M'=>...);
    #   parameters specify the rule described below

    my $HashObject = $pl->load(...,key=>value,..); # store named items

    # access as usual with hash
    my $v = $HashObject->{key};
    my @V = delete @$HashObject{..,key,..};

=head1 DESCRIPTION

Arguments of the constructor, keyed by 'D','M', are optional.
Giving a closer view they look like

        'D' => [...,Name(i)=>DefVal(i),...]
        'M' => $mask                      where  $mask = sub {...}
        'M' => [ $mask, P(1),...P(m) ]    or           = \&fmask

The arguments and specifications are exactly as in L<Sub::ParamFrame>
by correspondence of operations :

        Sub::ParamFrame          Sub::ParamLoader
        -----------------------------------------------
        pfrule                   new
        pfload                   load

This class provides base functionality for C<Sub::ParamFrame> which only adds
a final improvement step for subroutine arguments.
Regarding methods C<new & load>, as contents overlap, please refer to the
description of C<pfrule & pfload> in L<Sub::ParamFrame>.
Note that in C<Sub::ParamFrame> C<pfrule> calls
C<Sub::ParamLoader-E<gt>new(...)> storing the created object to
C<$register{$subname}>, C<pfload> invokes C<$register{$subname}-E<gt>load>.

=head1 DEPENDENCIES

This module requires these other modules and libraries:
 C<Tie::Hash::KeysMask>

=head1 EXAMPLE

    use Sub::ParamLoader;

    my @DoW = qw(Monday Tuesday Wednesday Thursday Friday Saturday Sunday);
    my %DW2Dic =  ######### Abbreviations mapping #############
    qw(su sunday mo monday tu tuesday we wednesday th thursday fr friday sa saturday);

    my $pl = Sub::ParamLoader->new #============== RULE ============#
    (             #------------------ KEYMASK--'M'------------------#
        'M' =>    # match any prefix-string of a week-day-name with legth
            sub   # not less than 2, ignoring case of characters
            {
                my $ik = shift;                 my $ikl = lc $ik;
                my $ikl2 = substr $ikl,0,2;     my $res = $DW2Dic{$ikl2};
                return undef unless
                ( defined $res)  && ($ikl eq substr($res,0,length $ikl));
                $res;
            },
        'D' => [qw(SUN VII MON I TUE II WED III)] ### DEFAULTS ###
    );

    my $hob = $pl->load qw(We iii Thur iv Fr v  Satur vi Sun vii);
    #        overrides defauts 'wednesday'=>'III','sunday'=>'VII'   #

    sub bar; sub kvTabPrint;  ######## show variants of access #######
    print bar 7;
    kvTabPrint $hob, @DoW;
    kvTabPrint $hob, qw (mo tu we th fr sa su);
    kvTabPrint $hob, qw (MONDY1 TUE WEDNESD THI FRI SAT suN);
    kvTabPrint $hob, qw (Mond TUE We th Fridy1 saturn sUn);

    ###################### output printing matters ####################
    sub lf() {qq(\n)}
    sub bar
    {
        sub seg() {'-'x10}   sub segv() {seg.'+'}
        my $n = (shift)-1;   (segv x $n).seg.lf;
    }

    sub kvTabPrint ######## output a hash arguments-values table #####
    {
        my $href = shift;
        my $kline = join ' |', map sprintf('%9s',$_),@_;
        my $vline = join ' |', map sprintf('%9s',$href->{$_}||'?'),@_;
        print $kline,lf,$vline,lf,bar(scalar @_);
    }
    ###################################################################

=head4 Output of last call of kvTabPrint:

 ---------+----------+----------+----------+----------+----------+----------
     Mond |      TUE |       We |       th |   Fridy1 |   saturn |      sUn
        I |       II |      iii |       iv |        ? |        ? |      vii
 ---------+----------+----------+----------+----------+----------+----------

=head1 AUTHOR

Josef SchE<ouml>nbrunner E<lt>j.schoenbrunner@onemail.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2005  by Josef SchE<ouml>nbrunner
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut