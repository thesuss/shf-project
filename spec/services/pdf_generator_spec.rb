require 'spec_helper'

require_relative File.join('..', '..', 'app', 'services','pdf_generator')

RSpec.describe PdfGenerator do
  let(:subject) { described_class.instance }

  let(:simple_HTML) { '<h1>Heading One</h1><p> This is just some text</p' }
  let(:simple_options) { { page_size: 'Letter' } }


  describe 'pdf' do

    it 'calls with_new_builder with a block that sends :to_pdf to the pdfkit that with_new_builder provides' do
      builder_double = instance_double(PDFKit, to_pdf: '')
      allow(subject).to receive(:with_new_builder).and_yield(builder_double)
      expect(builder_double).to receive(:to_pdf)
      subject.pdf(simple_HTML, simple_options)
    end
  end

  describe 'pdf_file' do
    it 'calls with_new_builder with a block that sends .to_file(the given filename)  with the pdfkit that with_new_builder provides' do
      builder_double = instance_double(PDFKit, to_file: '')
      given_fn = './output.pdf'
      allow(subject).to receive(:with_new_builder).and_yield(builder_double)
      expect(builder_double).to receive(:to_file).with(given_fn)
      subject.pdf_file(simple_HTML, given_fn, simple_options)
    end
  end

  describe 'with_new_builder' do
    let(:given_block) { Proc.new {} }
    let(:builder_double) { instance_double(PDFKit, to_pdf: '') }

    before(:each) { allow(subject).to receive(:timestamp).and_return("#{Time.now}") }


    it 'provides PDFKit with the given HTML source' do
      expect(PDFKit).to receive(:new).with(simple_HTML, Hash)
      subject.with_new_builder(simple_HTML, simple_options, &given_block)
    end

    it 'merges the given options with the defaults' do
      expect(subject).to receive(:default_options).and_return({})
      subject.with_new_builder(simple_HTML, simple_options) { |yielded_pdfkit|  yielded_pdfkit }
    end

    it 'adds the timestamp to the default options in the timestamp_position' do
      expect(subject).to receive(:timestamp).and_return("#{Time.now}")
      subject.with_new_builder(simple_HTML, simple_options) { |yielded_pdfkit|  yielded_pdfkit }
    end

    it 'yields to the given block, providing new instance of PDFKit' do
      result_pdfkit = nil
      allow(subject).to receive(:with_new_builder).and_yield(builder_double)
      subject.with_new_builder(simple_HTML, simple_options) { |yielded_pdfkit| result_pdfkit = yielded_pdfkit }
      expect(result_pdfkit).to eq(builder_double)
    end
  end


  it 'timestamp_position is header-right' do
    expect(subject.timestamp_position).to eq 'header-right'
  end
end
