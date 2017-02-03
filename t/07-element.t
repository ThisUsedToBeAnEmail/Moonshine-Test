use Moonshine::Test qw/:all/;
use Moonshine::Element;
moon_test({
    name => 'build',
    build => {
        class => 'Moonshine::Element',
        args => {
            tag => 'p',
            data => ['hello'],
        }
    },
    instructions => [
        {
            test => 'render',
            expected => '<p>hello</p>',
        },
        {
            test => 'scalar',
            func => 'text',
            expected => 'hello',
        },
        {
            test => 'obj',
            func => 'add_before_element',
            args => {
                tag => 'p',
                data => ['one'],
                class => 'two',
            },
            expected => 'Moonshine::Element',
            subtest => [
                 {
                    test => 'scalar',
                    func => 'tag',
                    expected => 'p',
                 },
                 {
                    test => 'scalar',
                    func => 'text',
                    expected => 'one',
                 },
                 {
                    test => 'scalar',
                    func => 'class',
                    expected => 'two',
                 },
                 {
                    test => 'render',
                    expected => '<p class="two">one</p>',
                 }
            ],
        },
    ]
});
=pod
        {
            test => 'render',
            expected => '<p class="two">one</p><p>hello</p>',
        },
        {
            test => 'obj',
            func => 'add_after_element',
            args => {
                tag => 'p',
                data => ['four'],
                class => 'three',
            },
            expected => 'Moonshine::Element',
            subtest => [
                 {
                    test => 'scalar',
                    func => 'tag',
                    expected => 'p',
                 },
                 {
                    test => 'scalar',
                    func => 'text',
                    expected => 'four',
                 },
                 {
                    test => 'scalar',
                    func => 'class',
                    expected => 'three',
                 },
                 {
                    test => 'render',
                    expected => '<p class="three">four</p>',
                 }
            ],
        },
        {
            test => 'render',
            expected => '<p class="two">one</p><p>hello</p><p class="three">four</p>'
        },
        {
            test => 'scalar',
            func => 'text',
            expected => 'hello',
        }
=cut


sunrise(1);
