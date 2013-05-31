class ImportCsv

  attr_accessor :file, :model

  def initialize(file,model)
    @file = file
    @model = model
  end

  require 'csv'
  def import
    csv_text = File.read(@file)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      row = row.to_hash.with_indifferent_access
      @model.singularize.camelize.constantize.create!(row.to_hash.symbolize_keys)
    end
  end

end
