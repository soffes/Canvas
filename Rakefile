# frozen_string_literal: true

PROJECT = 'Canvas.xcodeproj'
SWIFTLINT_VERSION = '0.39.2'
XCODE_SHORT_VERSION = '11.5'
XCODE_VERSION = '11E608c'
XCODEGEN_VERSION = '2.15.1'

desc 'Generate the Xcode project'
task project: :'check:xcodegen' do
  sh 'xcodegen --quiet'
end

desc 'Bootstrap the project'
task bootstrap: %i[check:xcode project]
task :default => :bootstrap

desc 'Run swiftlint'
task :lint do
  sh 'swiftlint'
end

desc 'Clean everything'
task :clean do
  sh %(rm -rf #{PROJECT})
end

namespace :check do
  desc 'Check Xcode version'
  task :xcode do
    # Check for Xcode
    unless (path = `xcode-select -p`.chomp)
      fail %(Xcode is not installed. Please install Xcode #{XCODE_SHORT_VERSION} from https://developer.apple.com/download)
    end

    # Check Xcode version
    info_path = File.expand_path path + '/../Version'
    unless (version = `defaults read #{info_path} ProductBuildVersion`.chomp) == XCODE_VERSION
      fail %(Xcode #{version} is installed. Xcode #{XCODE_VERSION} was expected. Please install Xcode #{XCODE_SHORT_VERSION} from https://developer.apple.com/download)
    end
  end

  desc 'Check XcodeGen version'
  task :xcodegen do
    unless (version = `xcodegen version`.chomp.sub('Version: ', '')) == XCODEGEN_VERSION
      fail %(XcodeGen #{XCODEGEN_VERSION} isnt’t installed. You can install with `brew install xcodegen`. You may need to update Homebrew with `brew update` first.)
    end
  end

  desc 'Check swiftlint version'
  task :swiftlint do
    unless (version = `swiftlint version`.chomp) == SWIFTLINT_VERSION
      fail %(swiftline #{SWIFTLINT_VERSION} isnt’t installed. You can install with `brew install swiftlint`. You may need to update Homebrew with `brew update` first.)
    end
  end
end
