# Create a stub certificate object that reports its expiration date
# as the provided Time, or 1 day from now by default
def stub_certificate(name = "certificate", valid = true)
  name.tap do |cert|
    allow(cert).to receive(:id).and_return("cert_id")
    allow(cert).to receive(:valid?).and_return(valid)
    allow(cert).to receive(:display_name).and_return("name")
    allow(cert).to receive(:certificate_content).and_return(Base64.encode64("download_raw"))
  end
end
