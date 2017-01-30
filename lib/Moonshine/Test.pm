package Moonshine::Test;

use strict;
use warnings;
use Test::More;
use Scalar::Util qw/blessed/;
use Params::Validate qw/:all/;
use B qw/svref_2object/;
use Exporter 'import';

our @EXPORT = qw/render_me moon_test_one sunrise/;

our %EXPORT_TAGS = (
    all     => [qw/render_me moon_test_one sunrise/],
    element => [qw/render_me sunrise/]
);

use feature qw/switch/;
no if $] >= 5.018, warnings => 'experimental::smartmatch';

=head1 NAME

Moonshine::Test - Test!

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

    use Moonshine::Test qw/:all/;

    moon_test_one(
        test      => 'scalar',
        meth      => \&Moonshine::Util::append_str,
        args      => [
            'first', 'second'       
        ],
        args_list => 1,
        expected  => 'first second',
    );

    sunrise(1);

=head1 EXPORT

=head2 all

=over 

=item moon_test_one

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
        test      => 'render_me',
        instance  => Moonshine::Component->new(),
        func      => 'button',
        args      => { 
            data  => '...'
        },
        expected  => '<button>...</button>',
    );

=head2 Instructions

Valid instructions moon_test_one accepts

=head3 test/expected

    test     => 'like'
    expected => 'a horrible death'
    ....
    like($test_outcome, qr/$expected/, "function: $func is like - $expected");

moon_test_one can currently run the following tests.

=over

=item ref - is_deeply - expected [] or {}

=item scalar - is - expected '',

=item hash - is_deeply - expected {},

=item array - is_deeply - expected [],

=item obj - blessed /o\ - expected '',

=item like - like - '',

=item true - is - 1,

=item false - is - 0,

=item undef - is - undef

=item ref_key_scalar - is - '' (requires key)

=item ref_key_ref - is_deeply - [] or {} (requires key)

=item ref_key_like - like - ''

=item ref_index_scalar - is - '' (requires index)

=item ref_index_ref - is_deeply - [] or {} (required index)

=item ref_index_like - like - ''

=back

=head3 catch

when you want to catch exceptions....

    catch => 1,

defaults the instruction{test} to like.

=head3 instance

    my $instance = Moonshine::Element->new();
    instance => $instance,

=head3 func

call a function from the instance
    
    instance => $instance,
    func     => 'render'

=head3 meth

    meth => \&Moonshine::Element::render,
    
=head3 args

    {} or []

=head3 args_list

    args      => [qw/one, two/],
    args_list => 1,

=cut

sub moon_test_one {
    my %instruction = validate_with(
        params => \@_,
        spec   => {
            instance  => 0,
            meth      => 0,
            func      => 0,
            args      => { default => {} },
            args_list => 0,
            test      => 0,
            expected  => 0,
            catch     => 0,
            key       => 0,
            index     => 0,
        }
    );

    my @test      = ();
    my $test_name = '';
    my @expected  = $instruction{expected};

    if ( $instruction{catch} ) {
        $test_name = 'catch';
        exists $instruction{test} or $instruction{test} = 'like';
        eval { _run_the_code( \%instruction ) };
        @test = $@;
    }
    else {
        @test      = _run_the_code( \%instruction );
        $test_name = shift @test;
    }

    if ( not exists $instruction{test} ) {
        ok(0);
        diag 'No instruction{test} passed to moon_test_one';
        return;
    }

    given ( $instruction{test} ) {
        when ('ref') {
            return is_deeply( $test[0], $expected[0],
                "$test_name is ref - is_deeply" );
        }
        when ('ref_key_scalar') {
            return exists $instruction{key}
                ? is( $test[0]->{$instruction{key}}, $expected[0], "$test_name is ref - has scalar key: $instruction{key} - is - $expected[0]")
                : ok(0, "No key passed to test - ref_key_scalar - testing - $test_name");
        }
        when ('ref_key_like') {
            return exists $instruction{key}
                ? like( $test[0]->{$instruction{key}}, qr/$expected[0]/, "$test_name is ref - has scalar key: $instruction{key} - like - $expected[0]")
                : ok(0, "No key passed to test - ref_key_like - testing - $test_name");
        }
        when ('ref_key_ref') {
            return exists $instruction{key}
                ? is_deeply( $test[0]->{$instruction{key}}, $expected[0], 
                        "$test_name is ref - has ref key: $instruction{key} - is_deeply - ref" )
                : ok(0, "No key passed to test - ref_key_ref - testing - $test_name");
        }
        when ('ref_index_scalar') {
            return exists $instruction{index}
                ? is( $test[0]->[$instruction{index}], $expected[0], "$test_name is ref - has scalar index: $instruction{index} - is - $expected[0]")
                : ok(0, "No index passed to test - ref_index_scalar - testing - $test_name");
        }
        when ('ref_index_ref') {
         return exists $instruction{index}
                ? is_deeply( $test[0]->[$instruction{index}], $expected[0], 
                        "$test_name is ref - has ref index: $instruction{index} - is_deeply - ref" )
                : ok(0, "No index passed to test - ref_index_ref - testing - $test_name");
        }
        when ('scalar') {
            return is( $test[0], $expected[0],
                sprintf "%s is scalar - is - %s", $test_name, $expected[0]);
        }
        when ('hash') {
            return is_deeply( {@test}, $expected[0],
                "$test_name is hash - reference - is_deeply" );
        }
        when ('array') {
            return is_deeply( \@test, $expected[0],
                "$test_name is array - reference - is_deeply" );
        }
        when ('obj') {
            return is( blessed $test[0],
                $expected[0],
                "$test_name is Object - blessed - is - $expected[0]" );
        }
        when ('like') {
            return like( $test[0], qr/$expected[0]/,
                "$test_name is like - $expected[0]" );
        }
        when ('true') {
            return is($test[0], 1, "$test_name is true - 1"); 
        }
        when ('false') {
            return is($test[0], 0, "$test_name is false - 0");
        }
        when ('undef') {
            return is($test[0], undef, "$test_name is undef"); 
        }
        when ('render') {
            return render_me(
                instance => $test[0],
                expected => $expected[0],
            );
        }
        default {
            ok(0);
            diag "Unknown instruction{test}: $_ passed to moon_test_one";
            return;
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
        func => 'div',
        args     => { data => 'echo' },
        expected => '<div>echo</div>',
    );

=cut

sub render_me {
    my %instruction = validate_with(
        params => \@_,
        spec   => {
            instance => 0,
            func     => 0,
            meth     => 0,
            args     => { default => {} },
            expected => { type => SCALAR },
        }
    );

    my ( $test_name, $instance ) = _run_the_code( \%instruction );

    return is( $instance->render,
        $instruction{expected}, "render $test_name: $instruction{expected}" );
}

sub _run_the_code {
    my $instruction = shift;

    my $test_name;
    if ( my $func = $instruction->{func} ) {
        $test_name = "function: ${func}";
        return defined $instruction->{args_list}
          ? (
            $test_name,
            $instruction->{instance}->$func( @{ $instruction->{args} } )
          )
          : (
            $test_name, $instruction->{instance}->$func( $instruction->{args} )
          );
    }
    elsif ( my $meth = $instruction->{meth} ) {
        my $meth_name = svref_2object($meth)->GV->NAME;
        $test_name = "method: ${meth_name}";
        return
          defined $instruction->{args_list}
          ? ( $test_name, $meth->( @{ $instruction->{args} } ) )
          : ( $test_name, $meth->( $instruction->{args} ) );
    }
    elsif ( exists $instruction->{instance} ) {
        $test_name = 'instance';
        return ( $test_name, $instruction->{instance} );
    }

    die('instruction passed to _run_the_code must have a func, meth or instance'
    );
}

=head2 sunrise

    sunrise(); # done_testing();

=cut

sub sunrise {
    my $done_testing = done_testing(shift);
    diag explain $done_testing;
    diag sprintf(
        '                         
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
       -             -        -      -      --   -             -',
        shift // ' \o/ '
    );
    return $done_testing;
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

1;    # End of Moonshine::Test
