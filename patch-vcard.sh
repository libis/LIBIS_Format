#! /bin/env bash
ls --zero ./vendor/bundle/ruby/*/gems/vpim*/lib/vpim/vcard.rb | xargs -0 -I {} sh -c "grep -qxF '# encoding: ISO-8859-1' {} || sed -i '1i # encoding: ISO-8859-1' {}"
