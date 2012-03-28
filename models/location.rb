class Location
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String
  property :address,    String
  property :distance,   String
  property :created_at, DateTime
  
  belongs_to :list
end
