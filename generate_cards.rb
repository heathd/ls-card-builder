$LOAD_PATH << File.dirname(__FILE__) + "/lib/"
require 'card_renderer'

card = CardRenderer.new(File.dirname(__FILE__) + "/card_yml/1-2-4-all.yml")
card.render
card.save_as("hello.pdf")
