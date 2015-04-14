require 'spec_helper'

RSpec.describe HelloWorld do
  it "returns Rack triple" do
    expect(subject.response).to eq([200, {}, 'Hello World'])
  end
end

RSpec.describe HelloWorldApp do
  let(:app) { HelloWorldApp }

  it "responds with 200 for call" do
    get '/'
    expect(last_response.ok?).to eq(true)
  end
end