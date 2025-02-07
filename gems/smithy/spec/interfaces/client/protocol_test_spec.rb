# TODO: THIS IS TEMPORARY FOR DEBUGGING!

describe 'Component: Client', rbs_test: true do
  before(:all) do
    @tmpdir = SpecHelper.generate(['Rpcv2Cbor'], :client, fixture: 'protocol_tests/rpcv2_cbor')
  end

  after(:all) do
    SpecHelper.cleanup(['Rpcv2Cbor'], @tmpdir)
  end

  it 'generates' do
    puts Rpcv2Cbor
  end
end
