describe Spaceship do
  it "#should pass rubocop code style checks" do
    puts "Running rubocop..."
    `rubocop -o /tmp/spaceship_rubocop`
    output = File.read("/tmp/spaceship_rubocop")
    expect(output.include? "no offenses detected").to be(true)
  end
end
