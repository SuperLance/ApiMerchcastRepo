require 'rails_helper'

RSpec.describe Note, type: :model do
  it "validates correct input" do
    note = Note.new(user: User.new, order: Order.new, text: "test text")
    expect(note.valid?).to be(true)
  end

  it "invalidates missing User" do
    note = Note.new(order: Order.new, text: "test text")
    expect(note.valid?).to be(false)
  end

  it "invalidates missing Order" do
    note = Note.new(user: User.new, text: "test text")
    expect(note.valid?).to be(false)
  end

  it "invalidates missing text" do
    note = Note.new(user: User.new, order: Order.new)
    expect(note.valid?).to be(false)
  end
end
