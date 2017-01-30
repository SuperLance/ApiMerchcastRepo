require 'rails_helper'

RSpec.describe Printer, type: :model do
  it "validates correct input" do
    printer = Printer.new(printer_type: "Spreadshirt", name: "Test")
    expect(printer.valid?).to be(true)
  end

  it "invalidates missing printer_type" do
    printer = Printer.new(name: "Test")
    expect(printer.valid?).to be(false)
  end

  it "invalidates missing name" do
    printer = Printer.new(printer_type: "Spreadshirt")
    expect(printer.valid?).to be(false)
  end
end
