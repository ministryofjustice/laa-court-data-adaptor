# typed: false
# frozen_string_literal: true

require "rubocops/urls"

describe RuboCop::Cop::FormulaAudit::Urls do
  subject(:cop) { described_class.new }

  let(:formulae) {
    [{
      "url" => "https://ftpmirror.gnu.org/lightning/lightning-2.1.0.tar.gz",
      "msg" => 'Please use "https://ftp.gnu.org/gnu/lightning/lightning-2.1.0.tar.gz" instead of https://ftpmirror.gnu.org/lightning/lightning-2.1.0.tar.gz.',
      "col" => 2,
    }, {
      "url" => "https://fossies.org/linux/privat/monit-5.23.0.tar.gz",
      "msg" => "Please don't use fossies.org in the url (using as a mirror is fine)",
      "col" => 2,
    }, {
      "url" => "http://tools.ietf.org/tools/rfcmarkup/rfcmarkup-1.119.tgz",
      "msg" => "Please use https:// for http://tools.ietf.org/tools/rfcmarkup/rfcmarkup-1.119.tgz",
      "col" => 2,
    }, {
      "url" => "https://apache.org/dyn/closer.cgi?path=/apr/apr-1.7.0.tar.bz2",
      "msg" => "https://apache.org/dyn/closer.cgi?path=/apr/apr-1.7.0.tar.bz2 should be " \
               "`https://www.apache.org/dyn/closer.lua?path=apr/apr-1.7.0.tar.bz2`",
      "col" => 2,
    }, {
      "url" => "http://search.mcpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz",
      "msg" => "http://search.mcpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz should be " \
               "`https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz`",
      "col" => 2,
    }, {
      "url" => "http://ftp.gnome.org/pub/GNOME/binaries/mac/banshee/banshee-2.macosx.intel.dmg",
      "msg" => "http://ftp.gnome.org/pub/GNOME/binaries/mac/banshee/banshee-2.macosx.intel.dmg should be " \
               "`https://download.gnome.org/binaries/mac/banshee/banshee-2.macosx.intel.dmg`",
      "col" => 2,
    }, {
      "url" => "git://anonscm.debian.org/users/foo/foostrap.git",
      "msg" => "git://anonscm.debian.org/users/foo/foostrap.git should be " \
               "`https://anonscm.debian.org/git/users/foo/foostrap.git`",
      "col" => 2,
    }, {
      "url" => "ftp://ftp.mirrorservice.org/foo-1.tar.gz",
      "msg" => "Please use https:// for ftp://ftp.mirrorservice.org/foo-1.tar.gz",
      "col" => 2,
    }, {
      "url" => "ftp://ftp.cpan.org/pub/CPAN/foo-1.tar.gz",
      "msg" => "ftp://ftp.cpan.org/pub/CPAN/foo-1.tar.gz should be `http://search.cpan.org/CPAN/foo-1.tar.gz`",
      "col" => 2,
    }, {
      "url" => "http://sourceforge.net/projects/something/files/Something-1.2.3.dmg",
      "msg" => "Use https://downloads.sourceforge.net to get geolocation (url is " \
               "http://sourceforge.net/projects/something/files/Something-1.2.3.dmg).",
      "col" => 2,
    }, {
      "url" => "https://downloads.sourceforge.net/project/foo/download",
      "msg" => "Don't use /download in SourceForge urls (url is " \
               "https://downloads.sourceforge.net/project/foo/download).",
      "col" => 2,
    }, {
      "url" => "https://sourceforge.net/project/foo",
      "msg" => "Use https://downloads.sourceforge.net to get geolocation " \
               "(url is https://sourceforge.net/project/foo).",
      "col" => 2,
    }, {
      "url" => "http://prdownloads.sourceforge.net/foo/foo-1.tar.gz",
      "msg" => <<~EOS.chomp,
        Don't use prdownloads in SourceForge urls (url is http://prdownloads.sourceforge.net/foo/foo-1.tar.gz).
                See: http://librelist.com/browser/homebrew/2011/1/12/prdownloads-is-bad/
      EOS
      "col" => 2,
    }, {
      "url" => "http://foo.dl.sourceforge.net/sourceforge/foozip/foozip_1.0.tar.bz2",
      "msg" => "Don't use specific dl mirrors in SourceForge urls (url is " \
               "http://foo.dl.sourceforge.net/sourceforge/foozip/foozip_1.0.tar.bz2).",
      "col" => 2,
    }, {
      "url" => "http://downloads.sourceforge.net/project/foo/foo/2/foo-2.zip",
      "msg" => "Please use https:// for http://downloads.sourceforge.net/project/foo/foo/2/foo-2.zip",
      "col" => 2,
    }, {
      "url" => "http://http.debian.net/debian/dists/foo/",
      "msg" => <<~EOS,
        Please use a secure mirror for Debian URLs.
        We recommend:
          https://deb.debian.org/debian/dists/foo/
      EOS
      "col" => 2,
    }, {
      "url" => "https://mirrors.kernel.org/debian/pool/main/n/nc6/foo.tar.gz",
      "msg" => "Please use " \
               "https://deb.debian.org/debian/ for " \
               "https://mirrors.kernel.org/debian/pool/main/n/nc6/foo.tar.gz",
      "col" => 2,
    }, {
      "url" => "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mkcue/foo.tar.gz",
      "msg" => "Please use " \
               "https://deb.debian.org/debian/ for " \
               "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mkcue/foo.tar.gz",
      "col" => 2,
    }, {
      "url" => "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
      "msg" => "Please use " \
               "https://deb.debian.org/debian/ for " \
               "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
      "col" => 2,
    }, {
      "url" => "https://www.mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
      "msg" => "Please use " \
               "https://deb.debian.org/debian/ for " \
               "https://www.mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
      "col" => 2,
    }, {
      "url" => "http://foo.googlecode.com/files/foo-1.0.zip",
      "msg" => "Please use https:// for http://foo.googlecode.com/files/foo-1.0.zip",
      "col" => 2,
    }, {
      "url" => "git://github.com/foo.git",
      "msg" => "Please use https:// for git://github.com/foo.git",
      "col" => 2,
    }, {
      "url" => "git://gitorious.org/foo/foo5",
      "msg" => "Please use https:// for git://gitorious.org/foo/foo5",
      "col" => 2,
    }, {
      "url" => "http://github.com/foo/foo5.git",
      "msg" => "Please use https:// for http://github.com/foo/foo5.git",
      "col" => 2,
    }, {
      "url" => "https://github.com/foo/foobar/archive/master.zip",
      "msg" => "Use versioned rather than branch tarballs for stable checksums.",
      "col" => 2,
    }, {
      "url" => "https://github.com/foo/bar/tarball/v1.2.3",
      "msg" => "Use /archive/ URLs for GitHub tarballs (url is https://github.com/foo/bar/tarball/v1.2.3).",
      "col" => 2,
    }, {
      "url" => "https://codeload.github.com/foo/bar/tar.gz/v0.1.1",
      "msg" => <<~EOS,
        Use GitHub archive URLs:
          https://github.com/foo/bar/archive/v0.1.1.tar.gz
        Rather than codeload:
          https://codeload.github.com/foo/bar/tar.gz/v0.1.1
      EOS
      "col" => 2,
    }, {
      "url" => "https://central.maven.org/maven2/com/bar/foo/1.1/foo-1.1.jar",
      "msg" => "https://central.maven.org/maven2/com/bar/foo/1.1/foo-1.1.jar should be " \
               "`https://search.maven.org/remotecontent?filepath=com/bar/foo/1.1/foo-1.1.jar`",
      "col" => 2,
    }, {
      "url"         => "https://brew.sh/example-darwin.x86_64.tar.gz",
      "msg"         => "https://brew.sh/example-darwin.x86_64.tar.gz looks like a binary package, " \
                       "not a source archive; homebrew/core is source-only.",
      "col"         => 2,
      "formula_tap" => "homebrew-core",
    }, {
      "url"         => "https://brew.sh/example-darwin.amd64.tar.gz",
      "msg"         => "https://brew.sh/example-darwin.amd64.tar.gz looks like a binary package, " \
                       "not a source archive; homebrew/core is source-only.",
      "col"         => 2,
      "formula_tap" => "homebrew-core",
    }, {
      "url" => "cvs://brew.sh/foo/bar",
      "msg" => "Use of the cvs:// scheme is deprecated, pass `:using => :cvs` instead",
      "col" => 2,
    }, {
      "url" => "bzr://brew.sh/foo/bar",
      "msg" => "Use of the bzr:// scheme is deprecated, pass `:using => :bzr` instead",
      "col" => 2,
    }, {
      "url" => "hg://brew.sh/foo/bar",
      "msg" => "Use of the hg:// scheme is deprecated, pass `:using => :hg` instead",
      "col" => 2,
    }, {
      "url" => "fossil://brew.sh/foo/bar",
      "msg" => "Use of the fossil:// scheme is deprecated, pass `:using => :fossil` instead",
      "col" => 2,
    }, {
      "url" => "svn+http://brew.sh/foo/bar",
      "msg" => "Use of the svn+http:// scheme is deprecated, pass `:using => :svn` instead",
      "col" => 2,
    }]
  }

  context "When auditing urls" do
    it "with offenses" do
      formulae.each do |formula|
        allow_any_instance_of(RuboCop::Cop::FormulaCop).to receive(:formula_tap)
                                                       .and_return(formula["formula_tap"])
        source = <<~RUBY
          class Foo < Formula
            desc "foo"
            url "#{formula["url"]}"
          end
        RUBY
        expected_offenses = [{ message:  formula["msg"],
                               severity: :convention,
                               line:     3,
                               column:   formula["col"],
                               source:   source }]

        inspect_source(source)

        expected_offenses.zip(cop.offenses.reverse).each do |expected, actual|
          expect(actual.message).to eq(expected[:message])
          expect(actual.severity).to eq(expected[:severity])
          expect(actual.line).to eq(expected[:line])
          expect(actual.column).to eq(expected[:column])
        end
      end
    end

    it "with offenses in stable/devel/head block" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url "https://foo.com"

          devel do
            url "git://github.com/foo.git",
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use https:// for git://github.com/foo.git
                :tag => "v1.0.0-alpha.1",
                :revision => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
            version "1.0.0-alpha.1"
          end
        end
      RUBY
    end

    it "with duplicate mirror" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url "https://ftpmirror.fnu.org/foo/foo-1.0.tar.gz"
          mirror "https://ftpmirror.fnu.org/foo/foo-1.0.tar.gz"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ URL should not be duplicated as a mirror: https://ftpmirror.fnu.org/foo/foo-1.0.tar.gz
        end
      RUBY
    end
  end
end

describe RuboCop::Cop::FormulaAudit::PyPiUrls do
  subject(:cop) { described_class.new }

  context "when a pypi URL is used" do
    it "reports an offense for pypi.python.org urls" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url "https://pypi.python.org/packages/source/foo/foo-0.1.tar.gz"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ use the `Source` url found on PyPI downloads page (`https://pypi.org/project/foo/#files`)
        end
      RUBY
    end

    it "reports an offense for short file.pythonhosted.org urls" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url "https://files.pythonhosted.org/packages/source/f/foo/foo-0.1.tar.gz"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ use the `Source` url found on PyPI downloads page (`https://pypi.org/project/foo/#files`)
        end
      RUBY
    end

    it "reports no offenses for long file.pythonhosted.org urls" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url "https://files.pythonhosted.org/packages/a0/b1/a01b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f/foo-0.1.tar.gz"
        end
      RUBY
    end
  end
end

describe RuboCop::Cop::FormulaAudit::GitUrls do
  subject(:cop) { described_class.new }

  context "when a git URL is used" do
    it "reports no offenses with a non-git url" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://foo.com"
        end
      RUBY
    end

    it "reports no offenses with both a tag and a revision" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              tag:      "v1.0.0",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        end
      RUBY
    end

    it "reports no offenses with both a tag, revision and `shallow` before" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              shallow:  false,
              tag:      "v1.0.0",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        end
      RUBY
    end

    it "reports no offenses with both a tag, revision and `shallow` after" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              tag:      "v1.0.0",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
              shallow:  false
        end
      RUBY
    end

    it "reports an offense with no `revision`" do
      expect_offense(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Formulae in homebrew/core should specify a revision for git urls
              tag: "v1.0.0"
        end
      RUBY
    end

    it "reports an offense with no `revision` and `shallow`" do
      expect_offense(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Formulae in homebrew/core should specify a revision for git urls
              shallow: false,
              tag:     "v1.0.0"
        end
      RUBY
    end

    it "reports no offenses with no `tag`" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        end
      RUBY
    end

    it "reports no offenses with no `tag` and `shallow`" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
              shallow:  false
        end
      RUBY
    end

    it "reports no offenses with missing arguments in `head`" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://foo.com"
          head do
            url "https://github.com/foo/bar.git"
          end
        end
      RUBY
    end

    it "reports no offenses with missing arguments in `devel`" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://foo.com"
          devel do
            url "https://github.com/foo/bar.git"
          end
        end
      RUBY
    end

    it "reports no offenses for non-core taps" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git"
        end
      RUBY
    end
  end
end

describe RuboCop::Cop::FormulaAuditStrict::GitUrls do
  subject(:cop) { described_class.new }

  context "when a git URL is used" do
    it "reports no offenses with both a tag and a revision" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              tag:      "v1.0.0",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        end
      RUBY
    end

    it "reports no offenses with both a tag, revision and `shallow` before" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              shallow:  false,
              tag:      "v1.0.0",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        end
      RUBY
    end

    it "reports no offenses with both a tag, revision and `shallow` after" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
              tag:      "v1.0.0",
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
              shallow:  false
        end
      RUBY
    end

    it "reports an offense with no `tag`" do
      expect_offense(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Formulae in homebrew/core should specify a tag for git urls
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        end
      RUBY
    end

    it "reports an offense with no `tag` and `shallow`" do
      expect_offense(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git",
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Formulae in homebrew/core should specify a tag for git urls
              revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
              shallow:  false
        end
      RUBY
    end

    it "reports no offenses with missing arguments in `head`" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://foo.com"
          head do
            url "https://github.com/foo/bar.git"
          end
        end
      RUBY
    end

    it "reports no offenses with missing arguments in `devel`" do
      expect_no_offenses(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          desc "foo"
          url "https://foo.com"
          devel do
            url "https://github.com/foo/bar.git"
          end
        end
      RUBY
    end

    it "reports no offenses for non-core taps" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url "https://github.com/foo/bar.git"
        end
      RUBY
    end
  end
end
