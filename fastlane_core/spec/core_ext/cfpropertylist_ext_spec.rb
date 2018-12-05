require "fastlane_core/core_ext/cfpropertylist"

describe "Extension to CFPropertyList" do
  let(:array) { [1, 2, 3] }
  let(:hash) { ["key" => "value"] }

  it "adds a #to_binary_plist method to Array" do
    expect(array).to respond_to(:to_binary_plist)
  end

  it "adds a #to_binary_plist method to Hash" do
    expect(hash).to respond_to(:to_binary_plist)
  end

  it "produces an XML plist from an Array" do
    new_data = Plist.parse_xml(array.to_plist)
    expect(new_data).to eq(array)
  end

  it "produces an XML plist from a Hash" do
    new_data = Plist.parse_xml(hash.to_plist)
    expect(new_data).to eq(hash)
  end
end
