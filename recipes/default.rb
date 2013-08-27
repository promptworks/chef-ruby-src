#
# Cookbook Name:: ruby-src
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

packages = value_for_platform_family(
             "rhel"    => %w[openssl-devel zlib-devel readline-devel  libyaml-devel],
             "default" => %w[libssl-dev    zlib1g-dev libreadline-dev libyaml-dev]
           )

packages.each do |dev_pkg|
  package dev_pkg
end

remote_file "#{Chef::Config[:file_cache_path]}/ruby-#{node[:ruby][:version]}.tar.gz" do
  source "http://ftp.ruby-lang.org/pub/ruby/#{node[:ruby][:version][0..2]}/ruby-#{node[:ruby][:version]}.tar.gz"
  checksum node[:ruby][:checksum] if  node[:ruby][:checksum]
  not_if "#{node[:ruby][:prefix]}/bin/ruby -v | grep \"#{node[:ruby][:version].gsub('-', '')}\""
end

bash "install_ruby" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar --no-same-owner -zxf ruby-#{node[:ruby][:version]}.tar.gz
    cd ruby-#{node[:ruby][:version]}/
    ./configure #{node[:ruby][:configure_opts]}
    make #{node[:ruby][:make_opts]}
    make install
    #{node[:ruby][:prefix]}/bin/gem install bundler
  EOH
  not_if "#{node[:ruby][:prefix]}/bin/ruby -v | grep \"#{node[:ruby][:version].gsub('-', '')}\""
end
