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

  it 'treats paras with specific text as headings' do
    expect(TextFormatter.new("Invitation").format.first).to have_key(:color)
    expect(TextFormatter.new("People").format.first).to have_key(:color)
    expect(TextFormatter.new("Space & Materials").format.first).to have_key(:color)
    expect(TextFormatter.new("String With").format.first).to have_key(:color)
    expect(TextFormatter.new("Something else").format.first).not_to have_key(:color)
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
    Invitation
    Body para
    
    People
    More
    STUFF

    formatted = TextFormatter.new(text).format
    expect(formatted.map {|f| f[:text]}).to eq(["Invitation\n", "Body para\n", "\n", "People\n", "More\n"])
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

  it 'renders a list with Ask: prefix' do
    text = <<~STUFF
    Ask:
    - one
    - two
    - three
    STUFF

    formatted = TextFormatter.new(text).format
    expect(formatted.map {|f| f[:text]}).to eq(["Ask:\n", "• one\n", "• two\n", "• three\n"])
  end
end
