# Create a stub certificate object that reports its expiration date
# as the provided Time, or 1 day from now by default
def stub_certificate(expires = Time.now.utc + 86_400)
  "certificate".tap do |cert|
    allow(cert).to receive(:id).and_return("cert_id")
    allow(cert).to receive(:download_raw).and_return("download_raw")
    allow(cert).to receive(:name).and_return("name")
    allow(cert).to receive(:can_download).and_return(true)
    allow(cert).to receive(:expires).and_return(expires)
  end
end
