require 'spec_helper'

require_relative File.join('..', '..', '..', 'app', 'models', 'concerns', 'has_proof_of_membership_image')

# mock Rails just enough to run this without having to load Rails entirely
class MockRailsCache
  def self.read(pom_image_cache_key)
    "read item with #{pom_image_cache_key}"
  end

  def self.write(key, item)
    "write #{item} at #{key}"
  end

  def self.delete(key)
    "deleted item at #{key}"
  end
end


class MockRails
  def self.cache
    MockRailsCache
  end
end


RSpec.describe 'HasProofOfMembershipImage' do
  # use TesterClass class to test the behavior of HasProofOfMembershipImage since it is a concern
  class TesterClass
    include HasProofOfMembershipImage

    # required to construct the cache key
    def id
      42
    end
  end


  let(:subject) { TesterClass.new }
  let(:described_class) { TesterClass }

  before(:each) { allow(subject).to receive(:cache).and_return(MockRailsCache) }

  describe 'proof_of_membership_image' do
    before(:each) { allow(subject).to receive(:pom_image_cache_key).and_return('cache-key') }

    it 'gets the item from the cache at the cache key' do
      # allow(subject).to receive(:Rails).and_return(MockRails)
      expect(subject.send(:cache)).to receive(:read).with('cache-key')
      subject.proof_of_membership_image
    end
  end

  describe 'proof_of_membership_image=' do
    it 'sets the item in the cache to the given item using the cache key' do
      expect(subject).to receive(:pom_image_cache_key).and_return('some-key')
      expect(subject.send(:cache)).to receive(:write).with('some-key', 'blorf')
      subject.proof_of_membership_image = 'blorf'
    end
  end

  describe 'clear_proof_of_membership_image_cache' do
    it 'deletes the item in the cache with the cache key' do
      allow(subject).to receive(:pom_image_cache_key).and_return('cache-key')
      expect(subject.send(:cache)).to receive(:delete).with('cache-key')
      subject.send(:clear_proof_of_membership_image_cache)
    end
  end

  it 'cache key is <class name>_<id>_cache_<cache name>' do
    expect(subject.send(:cache)).to receive(:read).with(/TesterClass_42_cache_cache-name/)
    expect(subject).to receive(:cache_name).and_return('cache-name')
    subject.proof_of_membership_image
  end

  it 'cache name is cache_proof-of-membership-image' do
    expect(subject.send(:cache_name)).to eq 'proof-of-membership-image'
    subject.proof_of_membership_image
  end

  it 'cache is the Rails.cache' do
    expect(subject.send(:cache)).to eq MockRailsCache
  end
end
