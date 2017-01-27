package Moonshine::Test;

use 5.006;
use strict;
use warnings;
use Test::More;
use Scalar::Util qw/blessed/;
use Params::Validate qw/:all/;

use Exporter 'import';

our @EXPORT = qw/render_me moon_test_one sunrise/;

our %EXPORT_TAGS = ( all => [qw/render_me moon_test_one sunrise/], element => [qw/render_me sunrise/] );

use feature qw/switch/;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

=head1 NAME

Moonshine::Test - The great new Moonshine::Test!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Moonshine::Test;


=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head2 all

=over 

=item render_me

=item done_testing

=back

=head2 element

=over 

=item render_me

=item done_testing

=back

=head1 SUBROUTINES/METHODS

=head2 moon_test_one

    moon_test_one(
        instance  => 0,
        meth      => 0,
        function  => 0,
        args      => { },
        args_list => 0,
        test      => 0,
        expected  => 1,
    );

=cut

sub moon_test_one {
    my %instruction = validate_with(
        params => \@_,
        spec   => {
            instance  => 0,
            meth      => 0,
            function  => 0,
            args      => { default => {} },
            args_list => 0,
            test      => 0,
            expected  => 1,
            catch     => 0,
        }
    );

    my @test = ();
    my $test_name = '';
    my @expected = $instruction{expected};

    if ($instruction{catch}) {
        $test_name = 'catch';
        exists $instruction{test} or $instruction{test} = 'like';
        eval { _run_the_code(\%instruction) };
        @test = $@;
    }
    else {
        @test = _run_the_code(\%instruction);
        $test_name = shift @test;
    }
    
    given ( $instruction{test} ) {
        when (/ref/){
            return is_deeply($test[0], $expected[0], "$test_name is ref - is_deeply");
        }
        when (/scalar/){
            return is($test[0], $expected[0], "$test_name is scalar - is - $expected[0]");
        }
        when (/hash/){
            return is_deeply(%{@test}, %{@expected}, "$test_name is hash - reference - is_deeply");
        }
        when (/array/){
            return is_deeply(\@test, \@expected, "$test_name is array - reference - is_deeply");
        }
        when (/obj/){
            return is(blessed $test[0], $expected[0], "$test_name is Object - blessed - is - $expected[0]");
        }
        when (/like/) {
            return like($test[0], $expected[0], "$test_name is like - $expected[0]"); 
        }
        when (/render/){
            return render_me(
                instance     => $test[0], 
                expected     => $expected[0],
            );
        }
        default {
            diag explain \%instruction;
            ok(0);
        }
    }
}

=head2 render_me

Test render directly on a Moonshine::Element.

    render_me(
        instance => $element,
        expected => '<div>echo</div>'
    );

Or test a function..

    render_me(
        instance => $instance,
        function => 'div',
        args     => { data => 'echo' },
        expected => '<div>echo</div>',
    );

=cut

sub render_me {
    my %instruction = validate_with(
        params => \@_,
        spec   => {
            instance => 1,
            function => 0,
            args     => { default => {} },
            expected => { type => SCALAR },
        }
    );

    my ($test_name, $instance) = _run_the_code(\%instruction);

    return is( $instance->render,
        $instruction{expected}, "render $test_name: $instruction{expected}" );
}

=head2 _run_the_code

    _run_the_code({
        instance => ''
        function => '',
        ...
        meth => '',
    });

=cut

sub _run_the_code {
    my $instruction = shift;

    my $test_name;
    if (my $function = $instruction->{function}) {
        $test_name = "function: ${function}";
        return defined $instruction->{args_list}
          ? ($test_name, $instruction->{instance}->$function(@{ $instruction->{args} }))
          : ($test_name, $instruction->{instance}->$function( $instruction->{args} ));
    }
    elsif(my $meth = $instruction->{meth}) {
        my $cv = svref_2object($meth);
        my $gv = $cv->GV;
        my $meth_name = $gv->NAME;
        $test_name = "meth: ${meth_name}";
        return defined $instruction->{args_list}
          ? ($test_name, $meth->( @{ $instruction->{args} } ))
          : ($test_name, $meth->( $instruction->{args} ));
    }
    elsif(exists $instruction->{instance}) {
        $test_name = 'instance';
        return ($test_name, $instruction->{instance});    
    }
    
    diag explain $instruction;
    die;
}

=head2 sunrise

    sunrise(); # done_testing();

=cut

sub sunrise {
    diag sprintf('                         
                                    %s
            ^^                   @@@@@@@@@
       ^^       ^^            @@@@@@@@@@@@@@@
                            @@@@@@@@@@@@@@@@@@              ^^
                           @@@@@@@@@@@@@@@@@@@@
 ---- -- ----- -------- -- &&&&&&&&&&&&&&&&&&&& ------- ----------- ---
 -         --   -  -       -------------------- -       --     -- -
   -      --      -- -- --  ------------- ----  -     ---    - ---  - --
   -  --     -         -      ------  -- ---       -- - --  -- -
 -  -       - -      -           -- ------  -      --  -             --
       -             -        -      -      --   -             -', '\o/');
    return done_testing();
}

=head1 AUTHOR

LNATION, C<< <thisusedtobeanemail at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moonshine-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Moonshine-Test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Moonshine::Test


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Moonshine-Test>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Moonshine-Test>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Moonshine-Test>

=item * Search CPAN

L<http://search.cpan.org/dist/Moonshine-Test/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2017 Robert Acock.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Moonshine::Test
