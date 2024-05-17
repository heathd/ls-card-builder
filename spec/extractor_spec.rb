require File.dirname(__FILE__) + "/../extractor.rb"

RSpec.describe Extractor do
  subject { described_class.new(card_front, card_back) }

  context "1-2-4-all card" do
    let(:card_front) {
      File.dirname(__FILE__) + "/../cards/1-2-4-all-front.svg"
    }
    let(:card_back) {
      File.dirname(__FILE__) + "/../cards/1-2-4-all-back.svg"
    }

    it "extracts the title" do
      expect(subject.title).to eq("1-2-4-All")
    end

    it "extracts the purpose statement" do
      expect(subject.purpose_statement).to eq("Engage everyone simultaneously in generating questions, ideas and suggestions")
    end

    it "extracts the card type" do
      expect(subject.card_type).to eq("Reveal")
    end

    it "extracts the duration" do
      expect(subject.duration).to eq("12 min")
    end

    it "extracts the body" do
      expected_body = <<~BODY
        Invitation
        Ask a question in response to the presentation of an issue, or about a problem to resolve or a proposal put forward

        People
        Start alone, then in pairs, then groups of four, then the whole group

        Space & Materials
        - Space for people to work face-to-face in pairs and foursomes
        - Paper for participants to record observations and insights
        - Chairs and tables (optional)
        BODY
      expect(subject.body).to eq(expected_body)
    end

    it "extracts the back body" do
      expected_back_body = <<~BODY
      Steps
      Silent self-reflection by individuals on a shared challenge, framed as a question

      Generate ideas in pairs, building on ideas from self-reflection

      Share and develop ideas from your pair in foursomes (notice similarities and differences)

      Each group shares one important idea with all (repeat cycle as needed)
      BODY
      expect(subject.back_body).to eq(expected_back_body.strip)
    end

    it "extracts the timings" do
      expect(subject.timings).to eq(["1 min", "2 min", "4 min", "5 min"])
    end

    it "extracts the 'string with' statement" do
      expect(subject.string_with).to eq("String With\nDesign Storyboards, Improv Prototyping, Ecocycle Planning")
    end

    it "extracts the filename" do
      expect(subject.filename).to eq('1-2-4-all')
    end

    it "emits a data structure for a card" do
      expect(subject.card_data).to eq(
        {
          title: subject.title,
          purpose_statement: subject.purpose_statement,
          card_type: subject.card_type,
          duration: subject.duration,
          body: subject.body,
          back_body: subject.back_body,
          timings: subject.timings,
          string_with: subject.string_with
        }
      )
    end
  end

  context "15% card" do
    let(:card_front) {
      File.dirname(__FILE__) + "/../cards/15-percent-solutions-front.svg"
    }
    let(:card_back) {
      File.dirname(__FILE__) + "/../cards/15-percent-solutions-back.svg"
    }

    it "extracts the title" do
      expect(subject.title).to eq("15% Solutions")
    end

    it "extracts the body" do
      expected_body = [
        'Invitation',
        'In connection with their personal challenge or their group’s challenge, ask:',
        '- “What is your 15 percent?”',
        '- “Where do you have discretion and freedom to act?”',
        '- “What can you do without more resources or authority?”',
        '',
        'People',
        'Start alone, then groups of 2 to 4 people',
        '',
        'Space & Materials',
        'Chairs for people to sit in groups',
        ''
        ].join("\n")
      expect(subject.body).to eq(expected_body)
    end
  end
end
