require 'rails_helper'

RSpec.describe 'Application Configuration has limited actions and does NOT require :id', type: :routing do

  let(:new)  { 'ny' }
  let(:edit) { 'redigera' }

  app_config_path = 'admin/app_configuration'
  controller_name = 'admin_only/app_configuration'


  it "/#{app_config_path}/redigera = #edit - use the Singleton ApplicationConfiguration" do
    assert_routing({path: "#{app_config_path}/#{edit}", method: :get}, {controller: controller_name, action: 'edit'})
  end

  it "/#{app_config_path}/id/redigera = #edit" do
    assert_routing({path: "#{app_config_path}/1/#{edit}", method: :get}, {controller: controller_name, action: 'edit', id: '1'})
  end

  it "/#{app_config_path} = #show - use the Singleton ApplicationConfiguration"  do
    assert_routing({path: "#{app_config_path}", method: :get}, {controller: controller_name, action: 'show'})
  end

  it "/#{app_config_path}/id = #show" do
    assert_routing({path: "#{app_config_path}/1", method: :get}, {controller: controller_name, action: 'show', id: '1'})
  end

  it "put /#{app_config_path} = #update - use the Singleton ApplicationConfiguration" do
    assert_routing({path: "#{app_config_path}", method: :put}, {controller: controller_name, action: 'update'})
  end

  it "put /#{app_config_path}/id = #update" do
    assert_routing({path: "#{app_config_path}/1", method: :put}, {controller: controller_name, action: 'update', id: '1'})
  end

end
