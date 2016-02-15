require "yaml"
require "logger"
require 'fileutils'
require 'json'
require 'plist'
require 'optparse'
require 'socket'
require 'archive/zip'
require 'mixlib/shellout'
require 'semver'
require 'git'
require 'rest-client'

@logger                 = Logger.new(STDOUT)
@logger.datetime_format = "%F %T"
basedir                 = File.dirname(__FILE__)
target_dir              = File.join(basedir, "target")
all_profile             = YAML.load_file(File.join(basedir, "profiles.yaml"))
profile_name            = String.new
dryrun                  = !ENV['dryrun'].nil?
git                     = Git.open(basedir)
@version                = SemVer.find

#
# Detect if this is a jenkins run
#
def jenkins?
  @logger.info "Jenkins Detected: #{not (ENV['WORKSPACE'].nil?)}"
  return !ENV['WORKSPACE'].nil?
end

case
  when ENV["profile"].to_s.length == 0
    profile_name = "development"
  when ENV["profile"] == "null"
    profile_name = "development"
  when ENV["profile"].nil?
    profile_name = "development"
  else
    profile_name = ENV["profile"]
end

profile = all_profile[profile_name]
@logger.info("profile being used: #{profile_name}")
@logger.info("xcode_target: #{profile["xcode_target"]}")

# This is where it all starts, :build
#
task :default => [:build]

#task :build => [:pod_install, :build_pods, :update_info_plist] do
task :build => [:pod_install] do
  @logger.info("configuration: #{@configuration}")
end

task :pod_install do
  @logger.info("pods installing")
  @logger.info("removing Pods dir if present")

  pods_dir = File.join(basedir, "Pods")
  if File.directory?(pods_dir) then
    FileUtils.rm_rf(pods_dir)
    @logger.info("removed: #{pods_dir}")
  end

  @logger.info("removing xcode workspace if present")
  workspace = File.join(basedir, profile["xcode_workspace"])

  if File.directory?(workspace) then
    FileUtils.rm_rf(workspace)
    @logger.info("removed: #{workspace}")
  end

  cmd = Mixlib::ShellOut.new('pod install', :cwd => basedir)
  cmd.run_command

  abort("No workspace, so the pods might not have installed. Have you installed cocoapods?(sudo gem install cocoapods)") unless File.exist?("#{profile["xcode_project"]}.xcworkspace")
end

