require 'rspec'

require 'text_formatter'

RSpec.describe 'TextFormatter' do
  it 'adds a newline to the end of a para' do
    formatted = TextFormatter.new("hello").format
    expect(formatted[0][:text]).to eq("hello\n")
  end

  it 'treats text split by newlines as one para' do
    text = <<~TEXT
    Para1
    text
    stuff.
    
    Para2
    things
    more.
    TEXT

    formatted = TextFormatter.new(text).format
    expect(formatted.size).to eq(2)
    expect(formatted.map {|f| f[:text]}).to eq(["Para1 text stuff.\n", "Para2 things more.\n"])
  end

  it 'renders a heading with light grey colour' do
    text = "# Invitation"

    formatted = TextFormatter.new(text).format
    expect(formatted.size).to eq(1)
    expect(formatted.map {|f| f[:text]}).to eq(["Invitation\n"])
    expect(formatted[0]).to have_key(:color)
  end

  it 'renders a heading and body para' do
    text = <<~STUFF
    # Invitation
    
    Body para
    
    STUFF

    formatted = TextFormatter.new(text).format
    expect(formatted.size).to eq(2)
    expect(formatted.map {|f| f[:text]}).to eq(["Invitation\n", "Body para\n"])
    expect(formatted[0]).to have_key(:color)
    expect(formatted[1]).not_to have_key(:color)
  end


  it 'inserts a spacer paragraph when a heading follows another para' do
    text = <<~STUFF
    # Invitation
    
    Body para
    
    # Heading 2

    More
    STUFF

    formatted = TextFormatter.new(text).format
    expect(formatted.map {|f| f[:text]}).to eq(["Invitation\n", "Body para\n", "\n", "Heading 2\n", "More\n"])
  end

  it 'renders a list' do
    text = <<~STUFF
    Here's a list of stuff:

    - one
    - two
    - three
    STUFF

    formatted = TextFormatter.new(text).format
    expect(formatted.map {|f| f[:text]}).to eq(["Here's a list of stuff:\n", "• one\n", "• two\n", "• three\n"])
  end
end
