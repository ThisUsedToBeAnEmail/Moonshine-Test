# NAME

Moonshine::Test - Test!

# VERSION

Version 0.06

# SYNOPSIS

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

# EXPORT

## all

- moon\_test\_one
- render\_me
- done\_testing

## element

- render\_me
- done\_testing

# SUBROUTINES/METHODS

## moon\_test\_one

    moon_test_one(
        test      => 'render_me',
        instance  => Moonshine::Component->new(),
        func      => 'button',
        args      => {
            data  => '...'
        },
        expected  => '<button>...</button>',
    );

## Instructions

Valid instructions moon\_test\_one accepts

### test/expected

    test     => 'like'
    expected => 'a horrible death'
    ....
    like($test_outcome, qr/$expected/, "function: $func is like - $expected");

moon\_test\_one can currently run the following tests.

- ref - is\_deeply - expected \[\] or {}
- scalar - is - expected '',
- hash - is\_deeply - expected {},
- array - is\_deeply - expected \[\],
- obj - blessed /o\\ - expected '',
- like - like - '',
- true - is - 1,
- false - is - 0,
- undef - is - undef
- ref\_key\_scalar - is - '' (requires key)
- ref\_key\_ref - is\_deeply - \[\] or {} (requires key)
- ref\_key\_like - like - ''
- ref\_index\_scalar - is - '' (requires index)
- ref\_index\_ref - is\_deeply - \[\] or {} (required index)
- ref\_index\_like - like - ''
- list\_key\_scalar - is - '' (requires key)
- list\_key\_ref - is\_deeply - \[\] or {} (requires key)
- list\_key\_like - like - ''
- list\_index\_scalar - is - '' (requires index)
- list\_index\_ref - is\_deeply - \[\] or {} (required index)
- list\_index\_like - like - ''

### catch

when you want to catch exceptions....

    catch => 1,

defaults the instruction{test} to like.

### instance

    my $instance = Moonshine::Element->new();
    instance => $instance,

### func

call a function from the instance

    instance => $instance,
    func     => 'render'

### meth

    meth => \&Moonshine::Element::render,

### args

    {} or []

### args\_list

    args      => [qw/one, two/],
    args_list => 1,

### index

index - required when testing - ref\_index\_\*

### key

key - required when testing - ref\_key\_\*

## render\_me

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

## sunrise

    sunrise(); # done_testing();

# AUTHOR

LNATION, `<thisusedtobeanemail at gmail.com>`

# BUGS

Please report any bugs or feature requests to `bug-moonshine-test at rt.cpan.org`, or through
the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Moonshine-Test](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Moonshine-Test).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Moonshine::Test

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [http://rt.cpan.org/NoAuth/Bugs.html?Dist=Moonshine-Test](http://rt.cpan.org/NoAuth/Bugs.html?Dist=Moonshine-Test)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Moonshine-Test](http://annocpan.org/dist/Moonshine-Test)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Moonshine-Test](http://cpanratings.perl.org/d/Moonshine-Test)

- Search CPAN

    [http://search.cpan.org/dist/Moonshine-Test/](http://search.cpan.org/dist/Moonshine-Test/)

# ACKNOWLEDGEMENTS

# LICENSE AND COPYRIGHT

Copyright 2017 Robert Acock.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

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
