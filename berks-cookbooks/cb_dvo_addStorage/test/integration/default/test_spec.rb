# # encoding: utf-8

# Inspec test for recipe cb_dvo_addStorage::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources

require_relative '../../../libraries/deep_traverse.rb'
require_relative '../../../libraries/select_unassigned_storage_classes.rb'
require_relative '../../../libraries/storage_classes_set.rb'

describe 'deep_traverse' do
  it 'should traverse a hash and return all key pairs' do
    @test_hash = { 'addStorage' => { 'storage_class' => 'standard' }, 'test1' => { 'storage_class' => 'standard' }, 'test2' => { 'hi5' => { 'storage_class' => 'premium' } }, 'test3' => { 'hi10' => { 'storage_class' => 'premium' } } }
    expect(deep_traverse(@test_hash)).to eq(['test3'] => { 'hi10' => { 'storage_class' => 'premium' } }, %w(test3 hi10) => { 'storage_class' => 'premium' }, %w(test3 hi10 storage_class) => 'premium', ['test2'] => { 'hi5' => { 'storage_class' => 'premium' } }, %w(test2 hi5) => { 'storage_class' => 'premium' }, %w(test2 hi5 storage_class) => 'premium', ['test1'] => { 'storage_class' => 'standard' }, %w(test1 storage_class) => 'standard', ['addStorage'] => { 'storage_class' => 'standard' }, %w(addStorage storage_class) => 'standard')
  end
end

describe 'select_unassigned_storage_classes' do
  it 'should get any key pairs that have storage_class attributes that have not been set' do
    @test_dvo = { 'storage' => { 'some_app' => { 'storage_class_set' => false }, 'some_app2' => { 'storage_class_set' => true } } }
    @test_dvo_user = { 'some_app' => { 'storage_class' => 'standard' }, 'some_app2' => { 'storage_class' => 'premium' } }
    @expected_response = { %w(some_app storage_class) => 'standard' }
    expect(select_unassigned_storage_class_attributes(@test_dvo, @test_dvo_user)).to eq(@expected_response)
  end

  it 'should also handle attributes directly within dvo/dvo_user' do
    @test_dvo = { 'storage' => { 'storage_class_set' => false } }
    @test_dvo_user = { 'storage_class' => 'standard' }
    @expected_response = { ['storage_class'] => 'standard' }
    expect(select_unassigned_storage_class_attributes(@test_dvo, @test_dvo_user)).to eq(@expected_response)
  end
end

describe 'storage_classes_set?' do
  it 'should identify if any storage class attributes need to be evaluated' do
    @test_dvo = { 'storage' => { 'some_app' => { 'storage_class_set' => false }, 'some_app2' => { 'storage_class_set' => true } } }
    @test_dvo_user = { 'some_app' => { 'storage_class' => 'standard' }, 'some_app2' => { 'storage_class' => 'premium' } }
    expect(storage_classes_set?(@test_dvo, @test_dvo_user)).to eq(false)
  end

  it 'should also identify if all storage class attributes are already evaluated' do
    @test_dvo = { 'storage' => { 'some_app' => { 'storage_class_set' => true }, 'some_app2' => { 'storage_class_set' => true } } }
    @test_dvo_user = { 'some_app' => { 'storage_class' => 'standard' }, 'some_app2' => { 'storage_class' => 'premium' } }
    expect(storage_classes_set?(@test_dvo, @test_dvo_user)).to eq(true)
  end
end
