#
# Copyright:: Copyright (c) 2014-2020, Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Common cleanup routines for ruby apps (InSpec, Workstation, Chef, etc)
#
# Heavily borrowed from ruby-cleanup script in omnibus-software
# macOS signing fails on double bundler check in ruby-cleanup so forking it here
#
require "fileutils"

name "ruby-cache-cleanup"
default_version "1.0.0"

license :project_license
skip_transitive_dependency_licensing true

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Clear the now-unnecessary git caches, docs, and build information
  block "Delete bundler git cache, docs, and build info" do
    gemdir = shellout!("#{install_dir}/embedded/bin/gem environment gemdir", env: env).stdout.chomp

    remove_directory "#{gemdir}/cache"
    remove_directory "#{gemdir}/doc"
    remove_directory "#{gemdir}/build_info"
  end

  block "Remove leftovers from compiling gems" do
    # find the embedded ruby gems dir and clean it up for globbing
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/".tr('\\', "/")

    # find gem_make.out and mkmf.log files
    Dir.glob(Dir.glob("#{target_dir}/**/{gem_make.out,mkmf.log}")).each do |f|
      puts "Deleting #{f}"
      File.delete(f)
    end
  end

  # Clean up docs
  delete "#{install_dir}/embedded/docs"
  delete "#{install_dir}/embedded/share/man"
  delete "#{install_dir}/embedded/share/doc"
  delete "#{install_dir}/embedded/share/gtk-doc"
  delete "#{install_dir}/embedded/ssl/man"
  delete "#{install_dir}/embedded/man"
  delete "#{install_dir}/embedded/share/info"
  delete "#{install_dir}/embedded/info"

  block "Remove leftovers from compiling gems" do
    gemdir = shellout!("#{install_dir}/embedded/bin/gem environment gemdir", env: env).stdout.chomp

    # find gem_make.out and mkmf.log files
    Dir.glob("#{gemdir}/extensions/**/{gem_make.out,mkmf.log}").each do |f|
      puts "Deleting #{f}"
      File.delete(f)
    end
  end

  block "Removing random non-code files from installed gems" do
    gemdir = shellout!("#{install_dir}/embedded/bin/gem environment gemdir", env: env).stdout.chomp

    # find the embedded ruby gems dir and clean it up for globbing
    files = %w{
      .codeclimate.yml
      .concourse.yml
      .coveralls.yml
      .document
      .ebert.yml
      .gemtest
      .gitignore
      .gitmodules
      .hound.yml
      .irbrc
      .pelusa.yml
      .rock.yml
      .rspec
      .rubocop.yml
      .rubocop_*.yml
      .ruby-gemset
      .ruby-version
      .rvmrc
      .travis.yml
      .yardopts
      .yardstick.yml
      appveyor.yml
      ARCHITECTURE.md
      CHANGELOG
      CHANGELOG.md
      CHANGELOG.rdoc
      CHANGELOG.txt
      CHANGES
      CHANGES.md
      CHANGES.txt
      Code-of-Conduct.md
      CODE_OF_CONDUCT.md
      CONTRIBUTING.md
      CONTRIBUTING.rdoc
      CONTRIBUTORS.md
      FAQ.txt
      Guardfile
      GUIDE.md
      HISTORY
      HISTORY.md
      History.rdoc
      HISTORY.txt
      INSTALL
      ISSUE_TEMPLATE.md
      JSON-Schema-Test-Suite
      Manifest
      Manifest.txt
      MIGRATING.md
      README
      README.*md
      readme.erb
      README.markdown
      README.rdoc
      README.txt
      README_INDEX.rdoc
      THANKS.txt
      TODO
      TODO*.md
      UPGRADING.md
    }

    Dir.glob(Dir.glob("#{gemdir}/gems/*/{#{files.join(",")}}")).each do |f|
      puts "Deleting #{f}"
      if File.directory?(f)
        # recursively removes files and the dir
        FileUtils.remove_dir(f)
      else
        File.delete(f)
      end
    end
  end
end