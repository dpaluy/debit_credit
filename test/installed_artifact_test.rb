require "fileutils"
require "open3"
require "tmpdir"
require "test_helper"

class InstalledArtifactTest < ActiveSupport::TestCase
  test "bare require loads the installed gem outside the checkout" do
    checkout = File.expand_path("../..", Rails.root)

    Dir.mktmpdir("debitcredit-installed-artifact") do |tmpdir|
      gem_path = File.join(tmpdir, "debitcredit-ledger-1.0.0.gem")
      gem_home = File.join(tmpdir, "gem-home")
      neutral_dir = File.join(tmpdir, "neutral")
      FileUtils.mkdir_p(neutral_dir)

      build_result = Open3.capture3(
        { "BUNDLE_GEMFILE" => nil },
        Gem.ruby,
        "-S", "gem", "build", "debitcredit-ledger.gemspec",
        chdir: checkout
      )

      assert_predicate build_result[2], :success?, build_result.join
      FileUtils.mv(File.join(checkout, "debitcredit-ledger-1.0.0.gem"), gem_path)

      install_result = Open3.capture3(
        Gem.ruby,
        "-S", "gem", "install", "--install-dir", gem_home,
        "--no-document", "--ignore-dependencies", gem_path,
        chdir: neutral_dir
      )

      assert_predicate install_result[2], :success?, install_result.join

      load_path = Gem.path.join(File::PATH_SEPARATOR)
      script = <<~'RUBY'
        require "debitcredit"
        loaded_path = Gem.loaded_specs.fetch("debitcredit-ledger").full_gem_path
        abort "unexpected gem path: \\#{loaded_path}" unless loaded_path.start_with?(ENV.fetch("GEM_HOME"))
        debitcredit_file = $LOADED_FEATURES.find { |path| path.end_with?("/debitcredit.rb") }
        abort "checkout source loaded" unless debitcredit_file&.start_with?(loaded_path)
        abort "VERSION missing" unless Debitcredit::VERSION == "1.0.0"
        puts loaded_path
      RUBY
      environment = {
        "BUNDLE_GEMFILE" => nil,
        "BUNDLE_BIN_PATH" => nil,
        "RUBYOPT" => nil,
        "RUBYLIB" => nil,
        "GEM_HOME" => gem_home,
        "GEM_PATH" => [gem_home, load_path].join(File::PATH_SEPARATOR)
      }
      result = Open3.capture3(environment, Gem.ruby, "-e", script, chdir: neutral_dir)

      assert_predicate result[2], :success?, result.join
      assert_includes result[0], gem_home
    end
  end
end
